// SPDX-License-Identifier: GPL-2.0-only
// SPDX-FileCopyrightText: Copyright (c) 2015-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
/*
 * NVIDIA Tegra Video Input Device
 */

#include <nvidia/conftest.h>

#include <linux/atomic.h>
#include <linux/bitmap.h>
#include <linux/clk.h>
#include <linux/delay.h>
#include <linux/nvhost.h>
#include <linux/lcm.h>
#include <linux/list.h>
#include <linux/nospec.h>
#include <linux/of.h>
#include <linux/of_graph.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/semaphore.h>
#include <linux/arm64-barrier.h>
#include <media/v4l2-ctrls.h>
#include <media/v4l2-event.h>
#include <media/v4l2-dev.h>
#include <media/v4l2-fh.h>
#include <media/v4l2-ioctl.h>
#include <media/v4l2-subdev.h>
#include <media/videobuf2-core.h>
#include <media/videobuf2-dma-contig.h>
#include <media/tegra-v4l2-camera.h>
#include <media/camera_common.h>
#include <media/tegracam_utils.h>
#include <media/tegra_camera_platform.h>
#include <media/v4l2-dv-timings.h>
#include <media/vi.h>

#include <linux/clk/tegra.h>
#define CREATE_TRACE_POINTS
#include <trace/events/camera_common.h>

#include "mipical/mipi_cal.h"

#include <uapi/linux/nvhost_nvcsi_ioctl.h>
#include "nvcsi/nvcsi.h"
#include "nvcsi/deskew.h"

#define TPG_CSI_GROUP_ID	10
#define HDMI_IN_RATE 550000000
/* number of lanes per brick */
#define NUM_LANES_PER_BRICK	4

static s64 queue_init_ts;

static bool tegra_channel_verify_focuser(struct tegra_channel *chan)
{
	char *focuser;

	/*
	 * WAR - to avoid power on/off during open/close for sensor
	 * nodes but not focuser nodes.
	 * add an array when more focusers are available, this logic is
	 * not needed once the focuser is bound to sensor channel
	 */
	focuser = strnstr(chan->video->name, "lc898212", sizeof(chan->video->name));

	return (focuser != NULL);
}

static void gang_buffer_offsets(struct tegra_channel *chan)
{
	int i;
	u32 offset = 0;

	for (i = 0; i < chan->total_ports; i++) {
		switch (chan->gang_mode) {
		case CAMERA_NO_GANG_MODE:
		case CAMERA_GANG_L_R:
		case CAMERA_GANG_R_L:
			offset = chan->gang_bytesperline;
			break;
		case CAMERA_GANG_T_B:
		case CAMERA_GANG_B_T:
			offset = chan->gang_sizeimage;
			break;
		default:
			offset = 0;
		}
		offset = ((offset + TEGRA_SURFACE_ALIGNMENT - 1) &
					~(TEGRA_SURFACE_ALIGNMENT - 1));
		chan->buffer_offset[i] = i * offset;
	}
	spec_bar();
}

static u32 gang_mode_width(enum camera_gang_mode gang_mode,
					unsigned int width)
{
	if ((gang_mode == CAMERA_GANG_L_R) ||
		(gang_mode == CAMERA_GANG_R_L))
		return width >> 1;
	else
		return width;
}

static u32 gang_mode_height(enum camera_gang_mode gang_mode,
					unsigned int height)
{
	if ((gang_mode == CAMERA_GANG_T_B) ||
		(gang_mode == CAMERA_GANG_B_T))
		return height >> 1;
	else
		return height;
}

static void update_gang_mode_params(struct tegra_channel *chan)
{
	chan->gang_width = gang_mode_width(chan->gang_mode,
						chan->format.width);
	chan->gang_height = gang_mode_height(chan->gang_mode,
						chan->format.height);
	chan->gang_bytesperline = ((chan->gang_width *
					chan->fmtinfo->bpp.numerator) /
					chan->fmtinfo->bpp.denominator);
	chan->gang_sizeimage = chan->gang_bytesperline *
					chan->format.height;
	gang_buffer_offsets(chan);
}

static void update_gang_mode(struct tegra_channel *chan)
{
	int width = chan->format.width;
	int height = chan->format.height;

	/*
	 * At present only 720p, 1080p and 4k resolutions
	 * are supported and only 4K requires gang mode
	 * Update this code with CID for future extensions
	 * Also, validate width and height of images based
	 * on gang mode and surface stride alignment
	 */
	if ((width > 1920) && (height > 1080)) {
		chan->gang_mode = CAMERA_GANG_L_R;
		chan->valid_ports = chan->total_ports;
	} else {
		chan->gang_mode = CAMERA_NO_GANG_MODE;
		chan->valid_ports = 1;
	}

	update_gang_mode_params(chan);
}

static u32 get_aligned_buffer_size(struct tegra_channel *chan,
		u32 bytesperline, u32 height)
{
	u32 height_aligned;
	u32 temp_size, size;

	height_aligned = roundup(height, chan->height_align);
	temp_size = bytesperline * height_aligned;
	size = roundup(temp_size, chan->size_align);

	return size;
}

static void tegra_channel_fmt_align(struct tegra_channel *chan,
				const struct tegra_video_format *vfmt,
				u32 *width, u32 *height, u32 *bytesperline)
{
	unsigned int min_bpl;
	unsigned int max_bpl;
	unsigned int align, fmt_align;
	unsigned int temp_bpl;
	unsigned int bpl;
	unsigned int numerator, denominator;
	const struct tegra_frac *bpp = &vfmt->bpp;

	/* Init, if un-init */
	if (!*width || !*height) {
		*width = chan->format.width;
		*height = chan->format.height;
	}

	denominator = (!bpp->denominator) ? 1 : bpp->denominator;
	numerator = (!bpp->numerator) ? 1 : bpp->numerator;
	/* The transfer alignment requirements are expressed in bytes. Compute
	 * the minimum and maximum values, clamp the requested width and convert
	 * it back to pixels.
	 * use denominator for base width alignment when >1.
	 * use bytesperline to adjust width for applicaton related requriements.
	 */
	fmt_align = (denominator == 1) ? numerator : 1;
	align = lcm(chan->width_align, fmt_align);
	align = align > 0 ? align : 1;
	bpl = tegra_core_bytes_per_line(*width, align, vfmt);

	/* Align stride */
	if (chan->vi->fops->vi_stride_align)
		chan->vi->fops->vi_stride_align(&bpl);

	if (!*bytesperline)
		*bytesperline = bpl;

	/* Don't clamp the width based on bpl as stride and width can be
	 * different. Aligned width also may force a sensor mode change other
	 * than the requested one
	 */
	*height = clamp(*height, 1U /*TEGRA_MIN_HEIGHT*/, TEGRA_MAX_HEIGHT);


	/* Clamp the requested bytes per line value. If the maximum bytes per
	 * line value is zero, the module doesn't support user configurable line
	 * sizes. Override the requested value with the minimum in that case.
	 */
	min_bpl = bpl;
	max_bpl = rounddown(TEGRA_MAX_WIDTH, chan->stride_align);
	temp_bpl = roundup(*bytesperline, chan->stride_align);

	*bytesperline = clamp(temp_bpl, min_bpl, max_bpl);
}

/* Check if sensor mode is interlaced and the type of interlaced mode */

static void tegra_channel_set_interlace_mode(struct tegra_channel *chan)
{
	struct v4l2_subdev *sd = NULL;
	struct camera_common_data *s_data = NULL;
	struct device_node *node = NULL;
	struct sensor_mode_properties *s_mode = NULL;

	if (chan->subdev_on_csi) {
		sd = chan->subdev_on_csi;
		s_data = to_camera_common_data(sd->dev);
		node = sd->dev->of_node;
	}

	if (s_data != NULL && node != NULL) {
		int idx = s_data->mode_prop_idx;

		if (idx < s_data->sensor_props.num_modes) {
			s_mode = &s_data->sensor_props.sensor_modes[idx];
			chan->is_interlaced =
				s_mode->control_properties.is_interlaced;
			if (chan->is_interlaced) {
				if (s_mode->control_properties.interlace_type)
					chan->interlace_type = Interleaved;
				else
					chan->interlace_type = Top_Bottom;
			}
		}
	}
}

static void tegra_channel_update_format(struct tegra_channel *chan,
		u32 width, u32 height, u32 fourcc,
		const struct tegra_frac *bpp,
		u32 preferred_stride)
{
	u32 denominator = (!bpp->denominator) ? 1 : bpp->denominator;
	u32 numerator = (!bpp->numerator) ? 1 : bpp->numerator;
	u32 bytesperline = (width * numerator / denominator);

	/* Align stride */
	if (chan->vi->fops->vi_stride_align)
		chan->vi->fops->vi_stride_align(&bytesperline);

	chan->format.width = width;
	chan->format.height = height;
	chan->format.pixelformat = fourcc;
	chan->format.bytesperline = preferred_stride ?: bytesperline;
	chan->buffer_offset[0] = 0;
	chan->interlace_bplfactor = 1;

	dev_dbg(&chan->video->dev,
			"%s: Resolution= %dx%d bytesperline=%d\n",
			__func__, width, height, chan->format.bytesperline);

	tegra_channel_fmt_align(chan, chan->fmtinfo,
				&chan->format.width,
				&chan->format.height,
				&chan->format.bytesperline);

	/* Calculate the sizeimage per plane */
	chan->format.sizeimage = get_aligned_buffer_size(chan,
			chan->format.bytesperline, chan->format.height);

	tegra_channel_set_interlace_mode(chan);
	/* Double the size of allocated buffer for interlaced sensor modes */
	if (chan->is_interlaced)
		chan->format.sizeimage *= 2;

	if (fourcc == V4L2_PIX_FMT_NV16)
		chan->format.sizeimage *= 2;
}

static void tegra_channel_fmts_bitmap_init(struct tegra_channel *chan)
{
	int ret, pixel_format_index = 0, init_code = 0;
	struct v4l2_subdev *subdev = chan->subdev_on_csi;
	struct v4l2_subdev_format fmt = {
		.pad = 0,
		.which = V4L2_SUBDEV_FORMAT_ACTIVE,
	};
	struct v4l2_subdev_mbus_code_enum code = {
		.which = V4L2_SUBDEV_FORMAT_ACTIVE,
	};

	struct v4l2_subdev_pad_config pad_cfg;
	struct v4l2_subdev_state cfg = {.pads = &pad_cfg};
	bitmap_zero(chan->fmts_bitmap, MAX_FORMAT_NUM);

	/*
	 * Initialize all the formats available from
	 * the sub-device and extract the corresponding
	 * index from the pre-defined video formats and initialize
	 * the channel default format with the active code
	 * Index zero as the only sub-device is sensor
	 */
	while (1) {
		ret = v4l2_subdev_call(subdev, pad, enum_mbus_code,
				       &cfg, &code);
		if (ret < 0)
			/* no more formats */
			break;

		pixel_format_index =
			tegra_core_get_idx_by_code(chan, code.code, 0);
		while (pixel_format_index >= 0) {
			bitmap_set(chan->fmts_bitmap, pixel_format_index, 1);
			/* Set init_code to the first matched format */
			if (!init_code)
				init_code = code.code;
			/* Look for other formats with the same mbus code */
			pixel_format_index = tegra_core_get_idx_by_code(chan,
				code.code, pixel_format_index + 1);
		}

		code.index++;
	}

	if (!init_code) {
		pixel_format_index =
			tegra_core_get_idx_by_code(chan, TEGRA_VF_DEF, 0);
		if (pixel_format_index >= 0) {
			bitmap_set(chan->fmts_bitmap, pixel_format_index, 1);
			init_code = TEGRA_VF_DEF;
		}
	}
		/* Get the format based on active code of the sub-device */
	ret = v4l2_subdev_call(subdev, pad, get_fmt, &cfg, &fmt);
	if (ret)
		return;

	/* Initiate the channel format to the first matched format */
	chan->fmtinfo =
		tegra_core_get_format_by_code(chan, fmt.format.code, 0);
	if (!chan->fmtinfo)
		return;

	v4l2_fill_pix_format(&chan->format, &fmt.format);
	tegra_channel_update_format(chan, chan->format.width,
				chan->format.height,
				chan->fmtinfo->fourcc,
				&chan->fmtinfo->bpp,
				chan->preferred_stride);

	if (chan->total_ports > 1)
		update_gang_mode(chan);
}

/*
 * -----------------------------------------------------------------------------
 * Tegra channel frame setup and capture operations
 * -----------------------------------------------------------------------------
 */
/*
 * Update the timestamp of the buffer
 */
void set_timestamp(struct tegra_channel_buffer *buf,
			const struct timespec64 *ts)
{
	buf->buf.vb2_buf.timestamp = (u64)timespec64_to_ns(ts);
}
EXPORT_SYMBOL(set_timestamp);

void release_buffer(struct tegra_channel *chan,
			struct tegra_channel_buffer *buf)
{
	struct vb2_v4l2_buffer *vbuf = &buf->buf;
	s64 frame_arrived_ts = 0;

	/* release one frame */
	vbuf->sequence = chan->sequence++;
	vbuf->field = V4L2_FIELD_NONE;
	vb2_set_plane_payload(&vbuf->vb2_buf,
		0, chan->format.sizeimage);

	/*
	 * WAR to force buffer state if capture state is not good
	 * WAR - After sync point timeout or error frame capture
	 * the second buffer is intermittently frame of zeros
	 * with no error status or padding.
	 */
	if (chan->capture_state != CAPTURE_GOOD || vbuf->sequence < 2)
		buf->state = VB2_BUF_STATE_ERROR;

	if (chan->sequence == 1) {
		/*
		 * Evaluate the initial capture latency between videobuf2 queue
		 * and first captured frame release to user-space.
		 */
		frame_arrived_ts = ktime_to_ms(ktime_get());
		dev_dbg(&chan->video->dev,
			"%s: capture init latency is %lld ms\n",
			__func__, (frame_arrived_ts - queue_init_ts));
	}

	dev_dbg(&chan->video->dev,
		"%s: release buf[%p] frame[%d] to user-space\n",
		__func__, buf, chan->sequence);
	vb2_buffer_done(&vbuf->vb2_buf, buf->state);
}
EXPORT_SYMBOL(release_buffer);

/*
 * `buf` has been successfully setup to receive a frame and is
 * "in flight" through the VI hardware. We are currently waiting
 * on it to be filled. Moves the pointer into the `release` list
 * for the release thread to wait on.
 */
void enqueue_inflight(struct tegra_channel *chan,
			struct tegra_channel_buffer *buf)
{
	/* Put buffer into the release queue */
	spin_lock(&chan->release_lock);
	list_add_tail(&buf->queue, &chan->release);
	spin_unlock(&chan->release_lock);

	/* Wake up kthread for release */
	wake_up_interruptible(&chan->release_wait);
}
EXPORT_SYMBOL(enqueue_inflight);

struct tegra_channel_buffer *dequeue_inflight(struct tegra_channel *chan)
{
	struct tegra_channel_buffer *buf = NULL;

	spin_lock(&chan->release_lock);
	if (list_empty(&chan->release)) {
		spin_unlock(&chan->release_lock);
		return NULL;
	}

	buf = list_entry(chan->release.next,
			 struct tegra_channel_buffer, queue);

	if (buf)
		list_del_init(&buf->queue);

	spin_unlock(&chan->release_lock);
	return buf;
}
EXPORT_SYMBOL(dequeue_inflight);

void tegra_channel_init_ring_buffer(struct tegra_channel *chan)
{
	chan->released_bufs = 0;
	chan->num_buffers = 0;
	chan->save_index = 0;
	chan->free_index = 0;
	chan->bfirst_fstart = false;
	chan->capture_descr_index = 0;
	chan->capture_descr_sequence = 0;
	chan->queue_error = false;
}
EXPORT_SYMBOL(tegra_channel_init_ring_buffer);

void free_ring_buffers(struct tegra_channel *chan, int frames)
{
	struct vb2_v4l2_buffer *vbuf;
	s64 frame_arrived_ts = 0;

	spin_lock(&chan->buffer_lock);

	if (frames == 0)
		frames = chan->num_buffers;

	while (frames > 0) {
		vbuf = chan->buffers[chan->free_index];

		/* Skip updating the buffer sequence with channel sequence
		 * for interlaced captures and this instead will be updated
		 * with frame id received from CSI with capture complete
		 */
		if (!chan->is_interlaced)
			vbuf->sequence = chan->sequence++;
		else
			chan->sequence++;
		/* release one frame */
		vbuf->field = V4L2_FIELD_NONE;
		vb2_set_plane_payload(&vbuf->vb2_buf,
			0, chan->format.sizeimage);

		/*
		 * WAR to force buffer state if capture state is not good
		 * WAR - After sync point timeout or error frame capture
		 * the second buffer is intermittently frame of zeros
		 * with no error status or padding.
		 */

		if (chan->sequence == 1) {
			/*
			 * Evaluate the initial capture latency
			 * between videobuf2 queue and first captured
			 * frame release to user-space.
			 */
			frame_arrived_ts = ktime_to_ms(ktime_get());
			dev_dbg(&chan->video->dev,
				"%s: capture init latency is %lld ms\n",
				__func__, (frame_arrived_ts - queue_init_ts));
		}
		vb2_buffer_done(&vbuf->vb2_buf,
			chan->buffer_state[chan->free_index++]);

		if (chan->free_index >= chan->capture_queue_depth)
			chan->free_index = 0;
		chan->num_buffers--;
		chan->released_bufs++;
		frames--;
	}
	spin_unlock(&chan->buffer_lock);
}
EXPORT_SYMBOL(free_ring_buffers);

static void add_buffer_to_ring(struct tegra_channel *chan,
				struct vb2_v4l2_buffer *vb)
{
	/* save the buffer to the ring first */
	/* Mark buffer state as error before start */
	spin_lock(&chan->buffer_lock);
	chan->buffer_state[chan->save_index] = VB2_BUF_STATE_ERROR;
	chan->buffers[chan->save_index++] = vb;
	if (chan->save_index >= chan->capture_queue_depth)
		chan->save_index = 0;
	chan->num_buffers++;
	spin_unlock(&chan->buffer_lock);
}

static void update_state_to_buffer(struct tegra_channel *chan, int state)
{
	int save_index = (chan->save_index - PREVIOUS_BUFFER_DEC_INDEX);

	/* save index decrements by 2 as 3 bufs are added in ring buffer */
	if (save_index < 0)
		save_index += chan->capture_queue_depth;
	/* update state for the previous buffer */
	chan->buffer_state[save_index] = state;

	/* for timeout/error case update the current buffer state as well */
	if (chan->capture_state != CAPTURE_GOOD)
		chan->buffer_state[chan->save_index] = state;
}

void tegra_channel_ring_buffer(struct tegra_channel *chan,
					struct vb2_v4l2_buffer *vb,
					struct timespec64 *ts, int state)
{
	if (!chan->bfirst_fstart)
		chan->bfirst_fstart = true;
	else
		update_state_to_buffer(chan, state);

	/* Capture state is not GOOD, release all buffers and re-init state */
	if (chan->capture_state != CAPTURE_GOOD) {
		free_ring_buffers(chan, chan->num_buffers);
		tegra_channel_init_ring_buffer(chan);
		return;
	} else {
		/* TODO: granular time code information */
		vb->timecode.seconds = ts->tv_sec;
	}

	/* release buffer N at N+2 frame start event */
	if (chan->num_buffers >= (chan->capture_queue_depth - 1))
		free_ring_buffers(chan, 1);
}
EXPORT_SYMBOL(tegra_channel_ring_buffer);

void tegra_channel_ec_close(struct tegra_mc_vi *vi)
{
	struct tegra_channel *chan;

	/* clear all channles sync point fifo context */
	list_for_each_entry(chan, &vi->vi_chans, list) {
		memset(&chan->syncpoint_fifo[0],
			0, sizeof(chan->syncpoint_fifo));
	}
}
EXPORT_SYMBOL(tegra_channel_ec_close);

struct tegra_channel_buffer *dequeue_buffer(struct tegra_channel *chan,
	bool requeue)
{
	struct tegra_channel_buffer *buf = NULL;

	spin_lock(&chan->start_lock);
	if (list_empty(&chan->capture))
		goto done;

	buf = list_entry(chan->capture.next,
			 struct tegra_channel_buffer, queue);
	list_del_init(&buf->queue);

	if (requeue) {
		/* add dequeued buffer to the ring buffer */
		add_buffer_to_ring(chan, &buf->buf);
	}
done:
	spin_unlock(&chan->start_lock);
	return buf;
}
EXPORT_SYMBOL(dequeue_buffer);

struct tegra_channel_buffer *dequeue_dequeue_buffer(struct tegra_channel *chan)
{
	struct tegra_channel_buffer *buf = NULL;

	spin_lock(&chan->dequeue_lock);

	if (list_empty(&chan->dequeue))
		goto done;

	buf = list_entry(chan->dequeue.next, struct tegra_channel_buffer,
		queue);
	list_del_init(&buf->queue);

done:
	spin_unlock(&chan->dequeue_lock);
	return buf;
}
EXPORT_SYMBOL(dequeue_dequeue_buffer);

int tegra_channel_error_recover(struct tegra_channel *chan, bool queue_error)
{
	struct tegra_mc_vi *vi = chan->vi;
	int err = 0;

	if (!(vi->fops && vi->fops->vi_error_recover)) {
		err = -EIO;
		goto done;
	}

	dev_warn(vi->dev, "err_rec: attempting to reset the capture channel\n");

	err = vi->fops->vi_error_recover(chan, queue_error);
	if (!err)
		dev_warn(vi->dev,
			"err_rec: successfully reset the capture channel\n");

done:
	return err;
}
EXPORT_SYMBOL(tegra_channel_error_recover);

static struct device *tegra_channel_get_vi_unit(struct tegra_channel *chan)
{
	struct tegra_mc_vi *vi = chan->vi;
	struct device *vi_unit_dev;

	if (vi->fops->vi_unit_get_device_handle)
		vi->fops->vi_unit_get_device_handle(vi->ndev, chan->port[0],
			&vi_unit_dev);
	else
		vi_unit_dev = vi->dev;

	return vi_unit_dev;
}

/*
 * -----------------------------------------------------------------------------
 * videobuf2 queue operations
 * -----------------------------------------------------------------------------
 */
static int
tegra_channel_queue_setup(struct vb2_queue *vq,
		     unsigned int *nbuffers, unsigned int *nplanes,
		     unsigned int sizes[], struct device *alloc_devs[])
{
	struct tegra_channel *chan = vb2_get_drv_priv(vq);
	struct tegra_mc_vi *vi = chan->vi;
	int ret = 0;


	/* In some cases, if nplanes is valid
	 * and the requested image size is less than the
	 * actual image size, we need to return EINVAL.
	 * Previously, we were just updating sizes[0] irrespective
	 * of the requested image size. Although this did not harm the
	 * flow, according to "v4l2-compliance", we need to check if
	 * the requested size is invalid.
	 */
	if (*nplanes) {
		if (sizes[0] < chan->format.sizeimage) {
			pr_err("%s: sizes[0] = %d chan->format.sizeimage = %d ...\n"
					,__func__,sizes[0],chan->format.sizeimage);
			return -EINVAL;
		}
	} else {
		sizes[0] = chan->format.sizeimage;
	}

	*nplanes = 1;
	alloc_devs[0] = tegra_channel_get_vi_unit(chan);

	if (vi->fops && vi->fops->vi_setup_queue)
		return vi->fops->vi_setup_queue(chan, nbuffers);
	return ret;
}

int tegra_channel_alloc_buffer_queue(struct tegra_channel *chan,
	unsigned int num_buffers)
{
	struct device *vi_unit_dev = tegra_channel_get_vi_unit(chan);

	chan->buffer_state = devm_kzalloc(vi_unit_dev,
		(num_buffers * sizeof(*chan->buffer_state)), GFP_KERNEL);
	if (!chan->buffer_state)
		goto alloc_error;

	chan->buffers = devm_kzalloc(vi_unit_dev,
		(num_buffers * sizeof(*chan->buffers)), GFP_KERNEL);
	if (!chan->buffers)
		goto alloc_error;

	chan->capture_queue_depth = num_buffers;

	return 0;

alloc_error:
	dev_err(chan->vi->dev,
		"error: could not allocate memory for %u size buffer queue\n",
		num_buffers);

	tegra_channel_dealloc_buffer_queue(chan);

	return -ENOMEM;
}
EXPORT_SYMBOL(tegra_channel_alloc_buffer_queue);

void tegra_channel_dealloc_buffer_queue(struct tegra_channel *chan)
{
	struct device *vi_unit_dev = tegra_channel_get_vi_unit(chan);

	if (chan->buffer_state)
		devm_kfree(vi_unit_dev, chan->buffer_state);
	if (chan->buffers)
		devm_kfree(vi_unit_dev, chan->buffers);
}

static int tegra_channel_buffer_prepare(struct vb2_buffer *vb)
{
	struct vb2_v4l2_buffer *vbuf = to_vb2_v4l2_buffer(vb);
	struct tegra_channel *chan = vb2_get_drv_priv(vb->vb2_queue);
	struct tegra_channel_buffer *buf = to_tegra_channel_buffer(vbuf);

	buf->chan = chan;
	vb2_set_plane_payload(&vbuf->vb2_buf, 0, chan->format.sizeimage);
#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
	buf->addr = vb2_dma_contig_plane_dma_addr(vb, 0);
#endif

	return 0;
}

static void tegra_channel_buffer_queue(struct vb2_buffer *vb)
{
	struct vb2_v4l2_buffer *vbuf = to_vb2_v4l2_buffer(vb);
	struct tegra_channel *chan = vb2_get_drv_priv(vb->vb2_queue);
	struct tegra_channel_buffer *buf = to_tegra_channel_buffer(vbuf);

	/* for bypass mode - do nothing */
	if (chan->bypass)
		return;

	if (!queue_init_ts) {
		/*
		 * Record videobuf2 queue initial timestamp.
		 * Note: latency is accurate when streaming is already turned ON
		 */
		queue_init_ts = ktime_to_ms(ktime_get());
	}

	/* Put buffer into the capture queue */
	spin_lock(&chan->start_lock);
	list_add_tail(&buf->queue, &chan->capture);
	spin_unlock(&chan->start_lock);

	/* Wake up kthread for capture */
	wake_up_interruptible(&chan->start_wait);
}


static void tegra_channel_queued_buf_done_single_thread(
		struct tegra_channel *chan,
		enum vb2_buffer_state state)
{
	struct tegra_channel_buffer *buf, *nbuf;

	/* delete capture list */
	spin_lock(&chan->start_lock);
	list_for_each_entry_safe(buf, nbuf, &chan->capture, queue) {
		vb2_buffer_done(&buf->buf.vb2_buf, state);
		list_del(&buf->queue);
	}
	spin_unlock(&chan->start_lock);

	/* delete dequeue list */
	spin_lock(&chan->dequeue_lock);
	list_for_each_entry_safe(buf, nbuf, &chan->dequeue, queue) {
		vb2_buffer_done(&buf->buf.vb2_buf, state);
		list_del(&buf->queue);
	}
	spin_unlock(&chan->dequeue_lock);
}

static void tegra_channel_queued_buf_done_multi_thread(
		struct tegra_channel *chan,
		enum vb2_buffer_state state)
{
	struct tegra_channel_buffer *buf, *nbuf;
	spinlock_t *lock = &chan->start_lock;
	spinlock_t *release_lock = &chan->release_lock;
	struct list_head *q = &chan->capture;
	struct list_head *rel_q = &chan->release;

	spin_lock(lock);
	list_for_each_entry_safe(buf, nbuf, q, queue) {
		vb2_buffer_done(&buf->buf.vb2_buf, state);
		list_del(&buf->queue);
	}
	spin_unlock(lock);

	/* delete release list */
	spin_lock(release_lock);
	list_for_each_entry_safe(buf, nbuf, rel_q, queue) {
		vb2_buffer_done(&buf->buf.vb2_buf, state);
		list_del(&buf->queue);
	}
	spin_unlock(release_lock);
}

/* Return all queued buffers back to videobuf2 */
void tegra_channel_queued_buf_done(struct tegra_channel *chan,
	enum vb2_buffer_state state, bool multi_queue)
{
	if (multi_queue)
		tegra_channel_queued_buf_done_multi_thread(chan, state);
	else
		tegra_channel_queued_buf_done_single_thread(chan, state);
}
EXPORT_SYMBOL(tegra_channel_queued_buf_done);

/*
 * -----------------------------------------------------------------------------
 * subdevice set/unset operations
 * -----------------------------------------------------------------------------
 */
int tegra_channel_write_blobs(struct tegra_channel *chan)
{
	struct v4l2_subdev *sd = NULL;
	struct camera_common_data *s_data = NULL;

	/* for TPG, do nothing */
	if (chan->pg_mode)
		return 0;

	sd = chan->subdev_on_csi;
	if (!sd)
		return -EINVAL;

	s_data = to_camera_common_data(sd->dev);
	if (!s_data)
		return 0;

	if (!is_tvcf_supported(s_data->version))
		return 0;

	return tegracam_write_blobs(s_data->tegracam_ctrl_hdl);
}
EXPORT_SYMBOL(tegra_channel_write_blobs);

int tegra_channel_set_stream(struct tegra_channel *chan, bool on)
{
	int num_sd;
	int ret = 0;
	int err = 0;
	int max_deskew_attempts = 5;
	int deskew_attempts = 0;
	struct v4l2_subdev *sd;

	if (atomic_read(&chan->is_streaming) == on)
		return 0;
	trace_tegra_channel_set_stream("enable", on);

	if (on) {
		tegra_camera_update_clknbw(chan, true);
		/* Enable CSI before sensor. Reason is as follows:
		 * CSI is able to catch the very first clk transition.
		 */
		while (deskew_attempts < max_deskew_attempts) {
			for (num_sd = 0; num_sd < chan->num_subdevs; num_sd++) {
				sd = chan->subdev[num_sd];

				trace_tegra_channel_set_stream(sd->name, on);
				err = v4l2_subdev_call(sd, video, s_stream, on);
				if (!ret && err < 0 && err != -ENOIOCTLCMD)
					ret = err;
			}
			if (!chan->bypass && !chan->pg_mode &&
					chan->deskew_ctx->deskew_lanes) {
				err = nvcsi_deskew_apply_check(
							chan->deskew_ctx);
				++deskew_attempts;
				if (err && deskew_attempts <
							max_deskew_attempts) {
					for (num_sd = 0;
						num_sd < chan->num_subdevs;
								num_sd++) {
						sd = chan->subdev[num_sd];
						trace_tegra_channel_set_stream(
							sd->name, false);
						err = v4l2_subdev_call(sd,
							video,
							s_stream, false);
					}
				} else
					break;
			} else
				break;
		}
	} else {
		for (num_sd = chan->num_subdevs - 1; num_sd >= 0; num_sd--) {
			sd = chan->subdev[num_sd];

			trace_tegra_channel_set_stream(sd->name, on);
			err = v4l2_subdev_call(sd, video, s_stream, on);
			if (!ret && err < 0 && err != -ENOIOCTLCMD)
				ret = err;
		}
		spec_bar();

		tegra_camera_update_clknbw(chan, false);
	}

	if (ret == 0)
		atomic_set(&chan->is_streaming, on);
	return ret;
}
EXPORT_SYMBOL(tegra_channel_set_stream);

int tegra_channel_set_power(struct tegra_channel *chan, bool on)
{
	int num_sd;
	int ret = 0;
	int err = 0;
	struct v4l2_subdev *sd;

	/* First power on and last power off will turn on/off the subdevices */
	if (on) {
		if (atomic_add_return(1, &chan->power_on_refcnt) != 1)
			return 0;
	} else {
		if (!atomic_dec_and_test(&chan->power_on_refcnt))
			return 0;
	}

	/* Power on CSI at the last to complete calibration of mipi lanes */
	for (num_sd = chan->num_subdevs - 1; num_sd >= 0; num_sd--) {
		sd = chan->subdev[num_sd];

		trace_tegra_channel_set_power(sd->name, on);
		err = v4l2_subdev_call(sd, core, s_power, on);
		if (!ret && err < 0 && err != -ENOIOCTLCMD)
			ret = err;
	}

	return ret;
}
EXPORT_SYMBOL(tegra_channel_set_power);

static int tegra_channel_start_streaming(struct vb2_queue *vq, u32 count)
{
	struct tegra_channel *chan = vb2_get_drv_priv(vq);
	struct tegra_mc_vi *vi = chan->vi;

	if (vi->fops) {
		int ret = 0;

		/* power on hw at the start of streaming */
		ret = vi->fops->vi_power_on(chan);
		if (ret < 0)
			return ret;

		return vi->fops->vi_start_streaming(vq, count);
	}
	return 0;
}

static void tegra_channel_stop_streaming(struct vb2_queue *vq)
{
	struct tegra_channel *chan = vb2_get_drv_priv(vq);
	struct tegra_mc_vi *vi = chan->vi;

	if (vi->fops) {
		vi->fops->vi_stop_streaming(vq);
		vi->fops->vi_power_off(chan);
	}

	/* Clean-up recorded videobuf2 queue initial timestamp */
	queue_init_ts = 0;
}

static const struct vb2_ops tegra_channel_queue_qops = {
	.queue_setup = tegra_channel_queue_setup,
	.buf_prepare = tegra_channel_buffer_prepare,
	.buf_queue = tegra_channel_buffer_queue,
	.wait_prepare = vb2_ops_wait_prepare,
	.wait_finish = vb2_ops_wait_finish,
	.start_streaming = tegra_channel_start_streaming,
	.stop_streaming = tegra_channel_stop_streaming,
};

/* -----------------------------------------------------------------------------
 * V4L2 ioctls
 */

static int
tegra_channel_querycap(struct file *file, void *fh, struct v4l2_capability *cap)
{
	struct tegra_channel *chan = video_drvdata(file);
	ssize_t len;
	int ret = 0;

	cap->device_caps = V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING;
	cap->device_caps |= V4L2_CAP_EXT_PIX_FORMAT;
	cap->capabilities = cap->device_caps | V4L2_CAP_DEVICE_CAPS |
			V4L2_CAP_META_CAPTURE;

	len = strscpy(cap->driver, "tegra-video", sizeof(cap->driver));
	if (len < 0)
		return -ENAMETOOLONG;

	len = strscpy(cap->card, chan->video->name, sizeof(cap->card));
	if (len < 0)
		return -ENAMETOOLONG;

	ret = snprintf(cap->bus_info, sizeof(cap->bus_info), "platform:%s:%u",
		 dev_name(chan->vi->dev), chan->port[0]);
	if (ret < 0)
		return -EINVAL;

	return 0;
}

static int
tegra_channel_enum_framesizes(struct file *file, void *fh,
			      struct v4l2_frmsizeenum *sizes)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct v4l2_subdev_frame_size_enum fse;
	struct v4l2_subdev_pad_config pad_cfg;
	struct v4l2_subdev_state cfg = {.pads = &pad_cfg};
	int ret = 0;

	/* Convert v4l2 pixel format (fourcc) into media bus format code */
	fse.code = tegra_core_get_code_by_fourcc(chan, sizes->pixel_format, 0);
	if (fse.code < 0)
		return -EINVAL;
	fse.index = sizes->index;
	fse.which = V4L2_SUBDEV_FORMAT_ACTIVE;
	fse.pad = 0;

	ret = v4l2_subdev_call(sd, pad, enum_frame_size, &cfg, &fse);

	if (!ret) {
		sizes->type = V4L2_FRMSIZE_TYPE_DISCRETE;
		sizes->discrete.width = fse.max_width;
		sizes->discrete.height = fse.max_height;
	}

	return ret;
}

static int
tegra_channel_enum_frameintervals(struct file *file, void *fh,
			      struct v4l2_frmivalenum *intervals)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct v4l2_subdev_frame_interval_enum fie;
	struct v4l2_subdev_pad_config pad_cfg;
	struct v4l2_subdev_state cfg = {.pads = &pad_cfg};
	int ret = 0;

	/* Convert v4l2 pixel format (fourcc) into media bus format code */
	fie.code = tegra_core_get_code_by_fourcc(
		chan, intervals->pixel_format, 0);
	if (fie.code < 0)
		return -EINVAL;
	fie.index = intervals->index;
	fie.width = intervals->width;
	fie.height = intervals->height;
	fie.pad  = 0;
	fie.which = V4L2_SUBDEV_FORMAT_TRY;

	ret = v4l2_subdev_call(sd, pad, enum_frame_interval, &cfg, &fie);

	if (!ret) {
		intervals->type = V4L2_FRMIVAL_TYPE_DISCRETE;
		intervals->discrete.numerator = fie.interval.numerator;
		intervals->discrete.denominator = fie.interval.denominator;
	}

	return ret;
}

static int
tegra_channel_enum_format(struct file *file, void *fh, struct v4l2_fmtdesc *f)
{
	struct tegra_channel *chan = video_drvdata(file);
	unsigned int index = 0, i;
	unsigned long *fmts_bitmap = chan->fmts_bitmap;

	if (f->index >= bitmap_weight(fmts_bitmap, MAX_FORMAT_NUM))
		return -EINVAL;

	for (i = 0; i < f->index + 1; i++, index++)
		index = find_next_bit(fmts_bitmap, MAX_FORMAT_NUM, index);

	index -= 1;
	f->pixelformat = tegra_core_get_fourcc_by_idx(chan, index);

	return 0;
}

static int
tegra_channel_g_edid(struct file *file, void *fh, struct v4l2_edid *edid)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	if (!v4l2_subdev_has_op(sd, pad, get_edid))
		return -ENOTTY;

	return v4l2_subdev_call(sd, pad, get_edid, edid);
}

static int
tegra_channel_s_edid(struct file *file, void *fh, struct v4l2_edid *edid)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	if (!v4l2_subdev_has_op(sd, pad, set_edid))
		return -ENOTTY;

	return v4l2_subdev_call(sd, pad, set_edid, edid);
}

static int
tegra_channel_g_dv_timings(struct file *file, void *fh,
		struct v4l2_dv_timings *timings)
{
	struct tegra_channel *chan = video_drvdata(file);

#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, pad, g_dv_timings))
		return -ENOTTY;

	return v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, pad, g_dv_timings, 0, timings);
#else
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, video, g_dv_timings))
		return -ENOTTY;

	return v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, video, g_dv_timings, timings);
#endif
}

static int
tegra_channel_s_dv_timings(struct file *file, void *fh,
		struct v4l2_dv_timings *timings)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_bt_timings *bt = &timings->bt;
	struct v4l2_dv_timings curr_timings;
	int ret;

#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, pad, s_dv_timings))
#else
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, video, s_dv_timings))
#endif
		return -ENOTTY;

	ret = tegra_channel_g_dv_timings(file, fh, &curr_timings);
	if (ret)
		return ret;

	if (tegra_v4l2_match_dv_timings(timings, &curr_timings, 0, false))
		return 0;

	if (vb2_is_busy(&chan->queue))
		return -EBUSY;

#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
	ret = v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, pad, s_dv_timings, 0, timings);
#else
	ret = v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, video, s_dv_timings, timings);
#endif
	if (!ret)
		tegra_channel_update_format(chan, bt->width, bt->height,
			chan->fmtinfo->fourcc, &chan->fmtinfo->bpp,
			chan->preferred_stride);

	if (chan->total_ports > 1)
		update_gang_mode(chan);

	return ret;
}

static int
tegra_channel_query_dv_timings(struct file *file, void *fh,
		struct v4l2_dv_timings *timings)
{
	struct tegra_channel *chan = video_drvdata(file);

#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, pad, query_dv_timings))
		return -ENOTTY;

	return v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, pad, query_dv_timings, 0, timings);
#else
	if (!v4l2_subdev_has_op(chan->subdev_on_csi, video, query_dv_timings))
		return -ENOTTY;

	return v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, video, query_dv_timings, timings);
#endif
}

static int
tegra_channel_enum_dv_timings(struct file *file, void *fh,
		struct v4l2_enum_dv_timings *timings)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	if (!v4l2_subdev_has_op(sd, pad, enum_dv_timings))
		return -ENOTTY;

	return v4l2_subdev_call(sd, pad, enum_dv_timings, timings);
}

static int
tegra_channel_dv_timings_cap(struct file *file, void *fh,
		struct v4l2_dv_timings_cap *cap)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	if (!v4l2_subdev_has_op(sd, pad, dv_timings_cap))
		return -ENOTTY;

	return v4l2_subdev_call(sd, pad, dv_timings_cap, cap);
}

int tegra_channel_s_ctrl(struct v4l2_ctrl *ctrl)
{
	struct tegra_channel *chan = container_of(ctrl->handler,
				struct tegra_channel, ctrl_handler);
	int err = 0;

	switch (ctrl->id) {
	case TEGRA_CAMERA_CID_GAIN_TPG:
		{
			if (chan->vi->csi != NULL &&
				chan->vi->csi->tpg_gain_ctrl) {
				struct v4l2_subdev *sd = chan->subdev_on_csi;

				err = tegra_csi_tpg_set_gain(sd, &(ctrl->val));
			}
		}
		break;
	case TEGRA_CAMERA_CID_VI_BYPASS_MODE:
		/* Prevent changing the bypass mode while the device is still streaming */
		if (vb2_is_busy(&chan->queue))
			return -EBUSY;

		if (switch_ctrl_qmenu[ctrl->val] == SWITCH_ON)
			chan->bypass = true;
		else if (chan->vi->bypass) {
			dev_dbg(&chan->video->dev,
				"can't disable bypass mode\n");
			dev_dbg(&chan->video->dev,
				"because the VI/CSI is in bypass mode\n");
			chan->bypass = true;
		} else
			chan->bypass = false;
		break;
	case TEGRA_CAMERA_CID_OVERRIDE_ENABLE:
		{
			struct v4l2_subdev *sd = chan->subdev_on_csi;
			struct camera_common_data *s_data =
				to_camera_common_data(sd->dev);

			if (!s_data)
				break;
			if (switch_ctrl_qmenu[ctrl->val] == SWITCH_ON) {
				s_data->override_enable = true;
				dev_dbg(&chan->video->dev,
					"enable override control\n");
			} else {
				s_data->override_enable = false;
				dev_dbg(&chan->video->dev,
					"disable override control\n");
			}
		}
		break;
	case TEGRA_CAMERA_CID_VI_HEIGHT_ALIGN:
		chan->height_align = ctrl->val;
		tegra_channel_update_format(chan, chan->format.width,
				chan->format.height,
				chan->format.pixelformat,
				&chan->fmtinfo->bpp, 0);
		break;
	case TEGRA_CAMERA_CID_VI_SIZE_ALIGN:
		chan->size_align = size_align_ctrl_qmenu[ctrl->val];
		tegra_channel_update_format(chan, chan->format.width,
				chan->format.height,
				chan->format.pixelformat,
				&chan->fmtinfo->bpp, 0);
		break;
	case TEGRA_CAMERA_CID_LOW_LATENCY:
		chan->low_latency = ctrl->val;
		break;
	case TEGRA_CAMERA_CID_VI_PREFERRED_STRIDE:
		chan->preferred_stride = ctrl->val;
		tegra_channel_update_format(chan, chan->format.width,
				chan->format.height,
				chan->format.pixelformat,
				&chan->fmtinfo->bpp,
				chan->preferred_stride);
		break;
	default:
		dev_err(&chan->video->dev, "%s: Invalid ctrl %u\n",
			__func__, ctrl->id);
		err = -EINVAL;
	}

	return err;
}

static const struct v4l2_ctrl_ops channel_ctrl_ops = {
	.s_ctrl	= tegra_channel_s_ctrl,
};

static const struct v4l2_ctrl_config common_custom_ctrls[] = {
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_GAIN_TPG,
		.name = "TPG Gain Ctrl",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.min = 1,
		.max = 64,
		.step = 1,
		.def = 1,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_GAIN_TPG_EMB_DATA_CFG,
		.name = "TPG embedded data config",
		.type = V4L2_CTRL_TYPE_BOOLEAN,
		.flags = V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = 1,
		.step = 1,
		.def = 0,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_VI_BYPASS_MODE,
		.name = "Bypass Mode",
		.type = V4L2_CTRL_TYPE_INTEGER_MENU,
		.def = 0,
		.min = 0,
		.max = ARRAY_SIZE(switch_ctrl_qmenu) - 1,
		.menu_skip_mask = 0,
		.qmenu_int = switch_ctrl_qmenu,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_OVERRIDE_ENABLE,
		.name = "Override Enable",
		.type = V4L2_CTRL_TYPE_INTEGER_MENU,
		.def = 0,
		.min = 0,
		.max = ARRAY_SIZE(switch_ctrl_qmenu) - 1,
		.menu_skip_mask = 0,
		.qmenu_int = switch_ctrl_qmenu,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_VI_HEIGHT_ALIGN,
		.name = "Height Align",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.min = 1,
		.max = 16,
		.step = 1,
		.def = 1,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_VI_SIZE_ALIGN,
		.name = "Size Align",
		.type = V4L2_CTRL_TYPE_INTEGER_MENU,
		.def = TEGRA_SIZE_ALIGNMENT,
		.min = 0,
		.max = ARRAY_SIZE(size_align_ctrl_qmenu) - 1,
		.menu_skip_mask = 0,
		.qmenu_int = size_align_ctrl_qmenu,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_SENSOR_MODES,
		.name = "Sensor Modes",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.flags = V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = MAX_NUM_SENSOR_MODES,
		.def = MAX_NUM_SENSOR_MODES,
		.step = 1,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_SENSOR_SIGNAL_PROPERTIES,
		.name = "Sensor Signal Properties",
		.type = V4L2_CTRL_TYPE_U32,
		.flags = V4L2_CTRL_FLAG_HAS_PAYLOAD |
			 V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = 0xFFFFFFFF,
		.step = 1,
		.def = 0,
		.dims = { MAX_NUM_SENSOR_MODES,
			  SENSOR_SIGNAL_PROPERTIES_CID_SIZE },
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_SENSOR_IMAGE_PROPERTIES,
		.name = "Sensor Image Properties",
		.type = V4L2_CTRL_TYPE_U32,
		.flags = V4L2_CTRL_FLAG_HAS_PAYLOAD |
			 V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = 0xFFFFFFFF,
		.step = 1,
		.def = 0,
		.dims = { MAX_NUM_SENSOR_MODES,
			  SENSOR_IMAGE_PROPERTIES_CID_SIZE },
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_SENSOR_CONTROL_PROPERTIES,
		.name = "Sensor Control Properties",
		.type = V4L2_CTRL_TYPE_U32,
		.flags = V4L2_CTRL_FLAG_HAS_PAYLOAD |
			 V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = 0xFFFFFFFF,
		.step = 1,
		.def = 0,
		.dims = { MAX_NUM_SENSOR_MODES,
			  SENSOR_CONTROL_PROPERTIES_CID_SIZE },
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_SENSOR_DV_TIMINGS,
		.name = "Sensor DV Timings",
		.type = V4L2_CTRL_TYPE_U32,
		.flags = V4L2_CTRL_FLAG_HAS_PAYLOAD |
			 V4L2_CTRL_FLAG_READ_ONLY,
		.min = 0,
		.max = 0xFFFFFFFF,
		.step = 1,
		.def = 0,
		.dims = { MAX_NUM_SENSOR_MODES,
			  SENSOR_DV_TIMINGS_CID_SIZE },
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_LOW_LATENCY,
		.name = "Low Latency Mode",
		.type = V4L2_CTRL_TYPE_BOOLEAN,
		.def = 0,
		.min = 0,
		.max = 1,
		.step = 1,
	},
	{
		.ops = &channel_ctrl_ops,
		.id = TEGRA_CAMERA_CID_VI_PREFERRED_STRIDE,
		.name = "Preferred Stride",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.min = 0,
		.max = 65535,
		.step = 1,
		.def = 0,
	},
};

#define GET_TEGRA_CAMERA_CTRL(id, c)					\
do {									\
	c = v4l2_ctrl_find(&chan->ctrl_handler, TEGRA_CAMERA_CID_##id);	\
	if (!c) {							\
		dev_err(chan->vi->dev, "%s: could not find ctrl %s\n",	\
			__func__, "##id");				\
		return -EINVAL;						\
	}								\
} while (0)

static int tegra_channel_sensorprops_setup(struct tegra_channel *chan)
{
	const struct v4l2_subdev *sd = chan->subdev_on_csi;
	const struct camera_common_data *s_data =
			to_camera_common_data(sd->dev);
	const struct sensor_mode_properties *modes;
	struct v4l2_ctrl *ctrl_modes;
	struct v4l2_ctrl *ctrl_signalprops;
	struct v4l2_ctrl *ctrl_imageprops;
	struct v4l2_ctrl *ctrl_controlprops;
	struct v4l2_ctrl *ctrl_dvtimings;
	u32 i;

	if (!s_data)
		return 0;

	GET_TEGRA_CAMERA_CTRL(SENSOR_MODES, ctrl_modes);
	GET_TEGRA_CAMERA_CTRL(SENSOR_SIGNAL_PROPERTIES, ctrl_signalprops);
	GET_TEGRA_CAMERA_CTRL(SENSOR_IMAGE_PROPERTIES, ctrl_imageprops);
	GET_TEGRA_CAMERA_CTRL(SENSOR_CONTROL_PROPERTIES, ctrl_controlprops);
	GET_TEGRA_CAMERA_CTRL(SENSOR_DV_TIMINGS, ctrl_dvtimings);

	ctrl_modes->val = s_data->sensor_props.num_modes;
	ctrl_modes->cur.val = s_data->sensor_props.num_modes;

	/* Update the control sizes
	 *
	 * Note that the structs have size elems * sizeof(u32)
	 * So to get the number of structs (elems * sizeof(u32)) / num_modes
	 */
	ctrl_signalprops->elems = s_data->sensor_props.num_modes *
					SENSOR_SIGNAL_PROPERTIES_CID_SIZE;

	ctrl_imageprops->elems = s_data->sensor_props.num_modes *
					SENSOR_IMAGE_PROPERTIES_CID_SIZE;

	ctrl_controlprops->elems = s_data->sensor_props.num_modes *
					SENSOR_CONTROL_PROPERTIES_CID_SIZE;

	ctrl_dvtimings->elems = s_data->sensor_props.num_modes *
					SENSOR_DV_TIMINGS_CID_SIZE;

	modes = s_data->sensor_props.sensor_modes;
	for (i = 0; i < s_data->sensor_props.num_modes; i++) {
		void *ptr = NULL;
		u32 size;

		size = sizeof(struct sensor_signal_properties);
		ptr = ctrl_signalprops->p_new.p + (i * size);
		memcpy(ptr, &modes[i].signal_properties, size);

		size = sizeof(struct sensor_image_properties);
		ptr = ctrl_imageprops->p_new.p + (i * size);
		memcpy(ptr, &modes[i].image_properties, size);

		size = sizeof(struct sensor_control_properties);
		ptr = ctrl_controlprops->p_new.p + (i * size);
		memcpy(ptr, &modes[i].control_properties, size);

		size = sizeof(struct sensor_dv_timings);
		ptr = ctrl_dvtimings->p_new.p + (i * size);
		memcpy(ptr, &modes[i].dv_timings, size);
	}
	spec_bar();

	/* Do not copy memory into p_cur block, reuse p_new */
	ctrl_signalprops->p_cur.p = ctrl_signalprops->p_new.p;
	ctrl_imageprops->p_cur.p = ctrl_imageprops->p_new.p;
	ctrl_controlprops->p_cur.p = ctrl_controlprops->p_new.p;
	ctrl_dvtimings->p_cur.p = ctrl_dvtimings->p_new.p;

	return 0;
}

static int tegra_channel_setup_controls(struct tegra_channel *chan)
{
	int num_sd = 0;
	struct v4l2_subdev *sd = NULL;
	struct tegra_mc_vi *vi = chan->vi;
	struct v4l2_ctrl *ctrl;
	int i;
	int ret = 0;

	/* Clear and reinit control handler - Bug 1956853 */
	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	v4l2_ctrl_handler_init(&chan->ctrl_handler, MAX_CID_CONTROLS);

	/* Initialize the subdev and controls here at first open */
	sd = chan->subdev[num_sd];
	while ((sd = chan->subdev[num_sd++]) &&
		(num_sd <= chan->num_subdevs)) {
		/* Add control handler for the subdevice */
		ret = v4l2_ctrl_add_handler(&chan->ctrl_handler,
					sd->ctrl_handler, NULL, false);
		if (ret || chan->ctrl_handler.error)
			dev_err(chan->vi->dev,
				"Failed to add sub-device controls\n");
	}

	/* Add new custom controls */
	for (i = 0; i < ARRAY_SIZE(common_custom_ctrls); i++) {
		switch (common_custom_ctrls[i].id) {
			case TEGRA_CAMERA_CID_OVERRIDE_ENABLE:
				/* don't create override control for pg mode */
				if (chan->pg_mode)
					continue;
				break;
			case TEGRA_CAMERA_CID_GAIN_TPG:
				/* Skip the custom control for sensor and
				 * for TPG which doesn't support gain control
				 */
				if ((vi->csi == NULL) || (chan->pg_mode &&
					 !vi->csi->tpg_gain_ctrl))
					continue;
				break;
			case TEGRA_CAMERA_CID_GAIN_TPG_EMB_DATA_CFG:
				/* Skip the custom control for sensor and
				 * for TPG which doesn't support embedded
				 * data with TPG config data.
				 */
				if ((vi->csi == NULL) || (chan->pg_mode &&
					!vi->csi->tpg_emb_data_config))
					continue;
				break;
			default:
				break;
		}
		ctrl = v4l2_ctrl_new_custom(&chan->ctrl_handler,
			&common_custom_ctrls[i], NULL);
		if (!ctrl) {
			dev_err(chan->vi->dev,
				"Failed to add %s ctrl\n",
				common_custom_ctrls[i].name);
			return chan->ctrl_handler.error;
		}

		/* Initialize the sensor arrays to have zero elements
		 * This should keep accesses to only the modes
		 * later defined in the DT
		 */
		if (ctrl->is_array)
			ctrl->elems = 0;
	}

	vi->fops->vi_add_ctrls(chan);

	if (chan->pg_mode) {
		ret = v4l2_ctrl_add_handler(&chan->ctrl_handler,
					&chan->vi->ctrl_handler, NULL, false);
		if (ret || chan->ctrl_handler.error)
			dev_err(chan->vi->dev,
				"Failed to add VI controls\n");
	}

	/* setup the controls */
	ret = v4l2_ctrl_handler_setup(&chan->ctrl_handler);
	if (ret < 0)
		goto error;

	return 0;

error:
	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	return ret;
}

static void tegra_channel_free_sensor_properties(
		const struct v4l2_subdev *sensor_sd)
{
	struct camera_common_data *s_data;
	struct tegra_csi_device *csi = tegra_get_mc_csi();
	struct tegra_csi_channel *chan;

	if (sensor_sd == NULL)
		return;

	s_data = to_camera_common_data(sensor_sd->dev);
	if (s_data == NULL)
		return;

	if (s_data->sensor_props.sensor_modes)
		devm_kfree(s_data->dev, s_data->sensor_props.sensor_modes);

	s_data->sensor_props.sensor_modes = NULL;

	/* remove reference to s_data */
	list_for_each_entry(chan, &csi->csi_chans, list) {
		if (chan->sensor_sd == sensor_sd)
			chan->s_data = NULL;
	}
}

static int tegra_channel_connect_sensor(
	struct tegra_channel *chan, struct v4l2_subdev *sensor_sd)
{
	struct device *sensor_dev;
	struct device_node *sensor_of_node;
	struct tegra_csi_device *csi_device;
	struct device_node *ep_node;

	if (!chan)
		return -EINVAL;

	if (!sensor_sd)
		return -EINVAL;

	sensor_dev = sensor_sd->dev;
	if (!sensor_dev)
		return -EINVAL;

	sensor_of_node = sensor_dev->of_node;
	if (!sensor_of_node)
		return -EINVAL;

	csi_device = tegra_get_mc_csi();
	WARN_ON(!csi_device);
	if (!csi_device)
		return -ENODEV;

	for_each_endpoint_of_node(sensor_of_node, ep_node) {
		struct device_node *csi_chan_of_node;
		struct tegra_csi_channel *csi_chan;

		csi_chan_of_node =
			of_graph_get_remote_port_parent(ep_node);

		list_for_each_entry(csi_chan, &csi_device->csi_chans, list) {
			if (csi_chan->of_node == csi_chan_of_node) {
				csi_chan->s_data =
					to_camera_common_data(chan->subdev_on_csi->dev);
				csi_chan->sensor_sd = chan->subdev_on_csi;
				break;
			}
		}

		of_node_put(csi_chan_of_node);

	}

	return 0;
}

static int map_to_sensor_type(u32 phy_mode)
{
	switch (phy_mode) {
	case CSI_PHY_MODE_DPHY:
		return SENSORTYPE_DPHY;
	case CSI_PHY_MODE_CPHY:
		return SENSORTYPE_CPHY;
	case SLVS_EC:
		return SENSORTYPE_SLVSEC;
	default:
		return SENSORTYPE_OTHER;
	}
}

static void tegra_channel_get_sensor_peak_vals(struct tegra_channel *chan,
						u64 *pixelclock, u32 *num_lanes)
{
	int i = 0;
	u64 val = 0;

	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct camera_common_data *s_data =
		to_camera_common_data(sd->dev);
	struct sensor_mode_properties *sensor_mode;

	if (!s_data)
		return;

	for (i = 0; i < s_data->sensor_props.num_modes; i++) {
		sensor_mode = &s_data->sensor_props.sensor_modes[i];
		if (sensor_mode->signal_properties.serdes_pixel_clock.val != 0ULL)
			val = sensor_mode->signal_properties.serdes_pixel_clock.val;
		else
			val = sensor_mode->signal_properties.pixel_clock.val;

		/* Select the value from the mode with largest pixel rate and lane numbers */
		if (*pixelclock < val)
			*pixelclock = val;

		if (*num_lanes < sensor_mode->signal_properties.num_lanes)
			*num_lanes = sensor_mode->signal_properties.num_lanes;
	}
	spec_bar();
}


static u32 tegra_channel_get_num_lanes(struct tegra_channel *chan)
{
	u32 num_lanes = 0;
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	struct camera_common_data *s_data =
		to_camera_common_data(sd->dev);
	struct sensor_mode_properties *sensor_mode;

	if (!s_data)
		return 0;

	sensor_mode = &s_data->sensor_props.sensor_modes[0];
	num_lanes = sensor_mode->signal_properties.num_lanes;

	return num_lanes;
}

static u32 tegra_channel_get_sensor_type(struct tegra_channel *chan)
{
	u32 phy_mode = 0, sensor_type = 0;
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct camera_common_data *s_data =
		to_camera_common_data(sd->dev);
	struct sensor_mode_properties *sensor_mode;

	if (!s_data)
		return 0;

	/* Select phy mode based on the first mode */
	sensor_mode = &s_data->sensor_props.sensor_modes[0];
	phy_mode = sensor_mode->signal_properties.phy_mode;
	sensor_type = map_to_sensor_type(phy_mode);

	return sensor_type;
}

static u64 tegra_channel_get_max_source_rate(void)
{
	/* WAR: bug 2095503 */
	/* TODO very large hard-coded rate based on 4k@60 fps */
	/* implement proper functionality here. */
	u64 pixelrate = HDMI_IN_RATE;
	return pixelrate;
}

static void tegra_channel_populate_dev_info(struct tegra_camera_dev_info *cdev,
			struct tegra_channel *chan)
{
	u64 pixelclock = 0;
	u32 max_num_lanes = 0;
	struct camera_common_data *s_data =
			to_camera_common_data(chan->subdev_on_csi->dev);

	if (s_data != NULL) {
		/* camera sensors */
		cdev->sensor_type = tegra_channel_get_sensor_type(chan);
		tegra_channel_get_sensor_peak_vals(chan, &pixelclock, &max_num_lanes);
		/* Multiply by CPHY symbols to pixels factor. */
		if (cdev->sensor_type == SENSORTYPE_CPHY)
			pixelclock *= 16/7;
		cdev->lane_num = tegra_channel_get_num_lanes(chan);
	} else {
		if (chan->pg_mode) {
			/* TPG mode */
			cdev->sensor_type = SENSORTYPE_VIRTUAL;
#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
		} else if (v4l2_subdev_has_op(chan->subdev_on_csi,
						pad, g_dv_timings)) {
#else
		} else if (v4l2_subdev_has_op(chan->subdev_on_csi,
						video, g_dv_timings)) {
#endif
			/* HDMI-IN */
			cdev->sensor_type = SENSORTYPE_OTHER;
			pixelclock = tegra_channel_get_max_source_rate();
		} else {
			/* Focusers, no pixel clk and ISO BW, just bail out */
			return;
		}
	}
	/*
	 * VI clk scaling for gang mode usecase where 2 CSI bricks
	 * stream through a single VI channel.
	 */
	if (max_num_lanes > NUM_LANES_PER_BRICK)
		cdev->pixel_rate = pixelclock * (max_num_lanes / NUM_LANES_PER_BRICK);
	else
		cdev->pixel_rate = pixelclock;
	cdev->pixel_bit_depth = chan->fmtinfo->width;
	cdev->bpp = chan->fmtinfo->bpp.numerator;
	/* BW in kBps */
	cdev->bw = cdev->pixel_rate * cdev->bpp / 1024;
	cdev->bw /= 8;
}

void tegra_channel_remove_subdevices(struct tegra_channel *chan)
{
	tegra_channel_free_sensor_properties(chan->subdev_on_csi);
	video_unregister_device(chan->video);
	chan->video = NULL;
	chan->num_subdevs = 0;
	chan->subdev_on_csi = NULL;
}
EXPORT_SYMBOL(tegra_channel_remove_subdevices);

int tegra_channel_init_subdevices(struct tegra_channel *chan)
{
	int ret = 0;
	struct media_entity *entity;
	struct media_pad *pad;
	struct v4l2_subdev *sd;
	int index = 0;
	u8 num_sd = 0;
	struct tegra_camera_dev_info camdev_info;
	int grp_id = chan->pg_mode ? (TPG_CSI_GROUP_ID + chan->port[0] + 1)
		: chan->port[0] + 1;
	int len = 0;

	/* set_stream of CSI */
#if LINUX_VERSION_CODE < KERNEL_VERSION(6, 0, 0)
	pad = media_entity_remote_pad(&chan->pad);
#else
	pad = media_pad_remote_pad_first(&chan->pad);
#endif
	if (!pad)
		return -ENODEV;

	entity = pad->entity;
	sd = media_entity_to_v4l2_subdev(entity);
	v4l2_set_subdev_hostdata(sd, chan);
	chan->subdev[num_sd++] = sd;

	/* verify if the immediate subdevice is slvsec */
	chan->is_slvsec = (strstr(sd->name, "slvs") != NULL) ? 1 : 0;

	/* Add subdev name to this video dev name with vi-output tag*/
	len = snprintf(chan->video->name, sizeof(chan->video->name), "%s, %s",
		"vi-output", sd->name);
	if (len < 0)
		return -EINVAL;

	sd->grp_id = grp_id;
	chan->grp_id = grp_id;
	index = pad->index - 1;
	while (index >= 0) {
		pad = &entity->pads[index];
		if (!(pad->flags & MEDIA_PAD_FL_SINK))
			break;

#if LINUX_VERSION_CODE < KERNEL_VERSION(6, 0, 0)
		pad = media_entity_remote_pad(pad);
#else
		pad = media_pad_remote_pad_first(pad);
#endif
		if (pad == NULL || !tegra_is_v4l2_subdev(pad->entity))
			break;

		if (num_sd >= MAX_SUBDEVICES)
			break;

		entity = pad->entity;
		sd = media_entity_to_v4l2_subdev(entity);
		v4l2_set_subdev_hostdata(sd, chan);
		sd->grp_id = grp_id;
		chan->subdev[num_sd++] = sd;
		/* Add subdev name to this video dev name with vi-output tag*/
		len = snprintf(chan->video->name, sizeof(chan->video->name), "%s, %s",
			"vi-output", sd->name);
		if (len < 0)
			return -EINVAL;

		index = pad->index - 1;
	}
	spec_bar(); /** for num_sd < MAX_SUBDEVICES */

	chan->num_subdevs = num_sd;
	/*
	 * Each CSI channel has only one final remote source,
	 * Mark that subdev as subdev_on_csi
	 */
	chan->subdev_on_csi = sd;

	/* initialize the available formats */
	if (chan->num_subdevs)
		tegra_channel_fmts_bitmap_init(chan);

	ret = tegra_channel_setup_controls(chan);
	if (ret < 0) {
		dev_err(chan->vi->dev, "%s: failed to setup controls\n",
			__func__);
		goto fail;
	}

	memset(&camdev_info, 0, sizeof(camdev_info));

	/*
	 * If subdev on csi is csi or channel is in pg mode
	 * then don't look for sensor props
	 */
	if (strstr(chan->subdev_on_csi->name, "nvcsi") != NULL ||
			chan->pg_mode) {
		tegra_channel_populate_dev_info(&camdev_info, chan);
		ret = tegra_camera_device_register(&camdev_info, chan);
		return ret;
	}

	ret = tegra_channel_sensorprops_setup(chan);
	if (ret < 0) {
		dev_err(chan->vi->dev, "%s: failed to setup sensor props\n",
			__func__);
		goto fail;
	}

	/* Add a link for the camera_common_data in the tegra_csi_channel. */
	ret = tegra_channel_connect_sensor(chan, chan->subdev_on_csi);
	if (ret < 0) {
		dev_err(chan->vi->dev,
			"%s: failed to connect sensor to channel\n", __func__);
		goto fail;
	}

	tegra_channel_populate_dev_info(&camdev_info, chan);
	ret = tegra_camera_device_register(&camdev_info, chan);

	return ret;
fail:
	tegra_channel_free_sensor_properties(chan->subdev_on_csi);
	return ret;
}
EXPORT_SYMBOL(tegra_channel_init_subdevices);

struct v4l2_subdev *tegra_channel_find_linked_csi_subdev(
	struct tegra_channel *chan)
{
	struct tegra_csi_device *csi = tegra_get_mc_csi();
	struct tegra_csi_channel *csi_it;
	int i = 0;

	list_for_each_entry(csi_it, &csi->csi_chans, list) {
		for (i = 0; i < chan->num_subdevs; i++)
			if (chan->subdev[i] == &csi_it->subdev)
				return chan->subdev[i];
	}

	return NULL;
}
EXPORT_SYMBOL(tegra_channel_find_linked_csi_subdev);

static int
tegra_channel_get_format(struct file *file, void *fh,
			struct v4l2_format *format)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_pix_format *pix = &format->fmt.pix;

	*pix = chan->format;

	return 0;
}

static int
__tegra_channel_try_format(struct tegra_channel *chan,
			struct v4l2_pix_format *pix)
{
	const struct tegra_video_format *vfmt;
	struct v4l2_subdev_format fmt;
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct v4l2_subdev_pad_config pad_cfg;
	struct v4l2_subdev_state cfg = {.pads = &pad_cfg};
	int ret = 0;

	/* Use the channel format if pixformat is not supported */
	vfmt = tegra_core_get_format_by_fourcc(chan, pix->pixelformat);
	if (!vfmt) {
		pix->pixelformat = chan->format.pixelformat;
		vfmt = tegra_core_get_format_by_fourcc(chan, pix->pixelformat);
		if (!vfmt)
			return -EINVAL;
	}

	fmt.which = V4L2_SUBDEV_FORMAT_TRY;
	fmt.pad = 0;
	v4l2_fill_mbus_format(&fmt.format, pix, vfmt->code);

	ret = v4l2_subdev_call(sd, pad, set_fmt, &cfg, &fmt);
	if (ret == -ENOIOCTLCMD)
		return -ENOTTY;

	v4l2_fill_pix_format(pix, &fmt.format);

	tegra_channel_fmt_align(chan, vfmt,
				&pix->width, &pix->height, &pix->bytesperline);
	pix->sizeimage = get_aligned_buffer_size(chan,
			pix->bytesperline, pix->height);
	if (chan->fmtinfo->fourcc == V4L2_PIX_FMT_NV16)
		pix->sizeimage *= 2;

	return ret;
}

static int
tegra_channel_try_format(struct file *file, void *fh,
			struct v4l2_format *format)
{
	struct tegra_channel *chan = video_drvdata(file);

	return  __tegra_channel_try_format(chan, &format->fmt.pix);
}

static int
__tegra_channel_set_format(struct tegra_channel *chan,
			struct v4l2_pix_format *pix)
{
	const struct tegra_video_format *vfmt;
	struct v4l2_subdev_format fmt;
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	struct v4l2_subdev_pad_config pad_cfg;
	struct v4l2_subdev_state cfg = {.pads = &pad_cfg};
	int ret = 0;

	vfmt = tegra_core_get_format_by_fourcc(chan, pix->pixelformat);
	if (!vfmt)
		return -EINVAL;

	fmt.which = V4L2_SUBDEV_FORMAT_ACTIVE;
	fmt.pad = 0;
	v4l2_fill_mbus_format(&fmt.format, pix, vfmt->code);

	ret = v4l2_subdev_call(sd, pad, set_fmt, &cfg, &fmt);
	if (ret == -ENOIOCTLCMD)
		return -ENOTTY;

	v4l2_fill_pix_format(pix, &fmt.format);
	if (!ret) {
		chan->format = *pix;
		chan->fmtinfo = vfmt;

		if (chan->preferred_stride)
			pix->bytesperline = chan->preferred_stride;

		tegra_channel_update_format(chan, pix->width,
			pix->height, vfmt->fourcc, &vfmt->bpp,
			pix->bytesperline);

		*pix = chan->format;

		if (chan->total_ports > 1)
			update_gang_mode(chan);
	}

	return ret;
}

static int
tegra_channel_set_format(struct file *file, void *fh,
			struct v4l2_format *format)
{
	struct tegra_channel *chan = video_drvdata(file);
	int ret = 0;

	/* get the suppod format by try_fmt */
	ret = __tegra_channel_try_format(chan, &format->fmt.pix);
	if (ret)
		return ret;

	if (vb2_is_busy(&chan->queue))
		return -EBUSY;

	return __tegra_channel_set_format(chan, &format->fmt.pix);
}

static int tegra_channel_subscribe_event(struct v4l2_fh *fh,
				  const struct v4l2_event_subscription *sub)
{
	switch (sub->type) {
	case V4L2_EVENT_SOURCE_CHANGE:
		return v4l2_event_subscribe(fh, sub, 4, NULL);
	}
	return v4l2_ctrl_subscribe_event(fh, sub);
}

static int
tegra_channel_enum_input(struct file *file, void *fh, struct v4l2_input *inp)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd_on_csi = chan->subdev_on_csi;
	int ret, len;

	if (inp->index)
		return -EINVAL;

	ret = v4l2_device_call_until_err(chan->video->v4l2_dev,
			chan->grp_id, video, g_input_status, &inp->status);

	if (ret == -ENODEV || sd_on_csi == NULL)
		return -ENODEV;

	inp->type = V4L2_INPUT_TYPE_CAMERA;
#if defined(NV_V4L2_SUBDEV_PAD_OPS_STRUCT_HAS_DV_TIMINGS) /* Linux v6.10 */
	if (v4l2_subdev_has_op(sd_on_csi, pad, s_dv_timings)) {
#else
	if (v4l2_subdev_has_op(sd_on_csi, video, s_dv_timings)) {
#endif
		inp->capabilities = V4L2_IN_CAP_DV_TIMINGS;
		len = snprintf(inp->name,
			sizeof(inp->name), "HDMI %u",
			chan->port[0]);
		if (len < 0)
			return -EINVAL;
	} else {
		len = snprintf(inp->name,
			sizeof(inp->name), "Camera %u",
			chan->port[0]);
		if (len < 0)
			return -EINVAL;
	}

	return ret;
}

static int tegra_channel_g_input(struct file *file, void *priv, unsigned int *i)
{
	*i = 0;
	return 0;
}

static int tegra_channel_s_input(struct file *file, void *priv, unsigned int i)
{
	if (i > 0)
		return -EINVAL;
	return 0;
}

static int tegra_channel_log_status(struct file *file, void *priv)
{
	struct tegra_channel *chan = video_drvdata(file);

	v4l2_device_call_all(chan->video->v4l2_dev,
		chan->grp_id, core, log_status);
	return 0;
}

static long tegra_channel_default_ioctl(struct file *file, void *fh,
			bool use_prio, unsigned int cmd, void *arg)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct tegra_mc_vi *vi = chan->vi;
	long ret = -ENOTTY;

	if (vi->fops && vi->fops->vi_default_ioctl)
		ret = vi->fops->vi_default_ioctl(file, fh, use_prio, cmd, arg);

	return ret;
}

/* Implemented vidioc_s_parm and vidioc_g_parm ioctl to support multiple frame
 * rates */
static int tegra_channel_s_parm(struct file *file, void *fh,
               struct v4l2_streamparm *a)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	return v4l2_s_parm_cap(chan->video, sd, a);
}

static int tegra_channel_g_parm(struct file *file, void *fh,
               struct v4l2_streamparm *a)
{
	struct tegra_channel *chan = video_drvdata(file);
	struct v4l2_subdev *sd = chan->subdev_on_csi;

	return v4l2_g_parm_cap(chan->video, sd, a);
}

static int
__tegra_channel_get_parm(struct tegra_channel *chan,
			  struct v4l2_streamparm *a)
{
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	int ret = 0;
	struct v4l2_subdev_frame_interval interval;

	/* dmipx: fixing G_PARM EINVAL error */
//	ret = v4l2_subdev_call(sd, video, g_frame_interval, &interval);
	ret = sd->ops->video->g_frame_interval(sd, &interval);

	a->parm.capture.timeperframe.numerator = interval.interval.numerator;
	a->parm.capture.timeperframe.denominator = interval.interval.denominator;

	return ret;
}

static int tegra_channel_get_parm(struct file *file, void *fh, struct v4l2_streamparm *a)
{
	struct tegra_channel *chan = video_drvdata(file);

	a->parm.capture.timeperframe.numerator = 1;
	a->parm.capture.timeperframe.denominator = 12;

	return __tegra_channel_get_parm(chan, a);
}

static int
__tegra_channel_set_parm(struct tegra_channel *chan,
			  struct v4l2_streamparm *a)
{
	struct v4l2_subdev *sd = chan->subdev_on_csi;
	int ret = 0;

	struct v4l2_subdev_frame_interval interval;
	interval.pad = 1;
	interval.interval.numerator = a->parm.capture.timeperframe.numerator;
	interval.interval.denominator = a->parm.capture.timeperframe.denominator;

	ret = v4l2_subdev_call(sd, video, s_frame_interval, &interval);
	if (ret == -ENOIOCTLCMD)
			return -ENOTTY;

	return ret;
}
static int tegra_channel_set_parm(struct file *file, void *fh, struct v4l2_streamparm *a)
{
	struct tegra_channel *chan = video_drvdata(file);

	if (vb2_is_busy(&chan->queue))
			return -EBUSY;

	return __tegra_channel_set_parm(chan, a);
}

static const struct v4l2_ioctl_ops tegra_channel_ioctl_ops = {
	.vidioc_querycap		= tegra_channel_querycap,
	.vidioc_enum_framesizes		= tegra_channel_enum_framesizes,
	.vidioc_enum_frameintervals	= tegra_channel_enum_frameintervals,
	.vidioc_s_parm                  = tegra_channel_s_parm,
	.vidioc_g_parm                  = tegra_channel_g_parm,
	.vidioc_enum_fmt_vid_cap	= tegra_channel_enum_format,
	.vidioc_g_fmt_vid_cap		= tegra_channel_get_format,
	.vidioc_s_fmt_vid_cap		= tegra_channel_set_format,
	.vidioc_try_fmt_vid_cap		= tegra_channel_try_format,
	.vidioc_reqbufs			= vb2_ioctl_reqbufs,
	.vidioc_prepare_buf		= vb2_ioctl_prepare_buf,
	.vidioc_querybuf		= vb2_ioctl_querybuf,
	.vidioc_qbuf			= vb2_ioctl_qbuf,
	.vidioc_dqbuf			= vb2_ioctl_dqbuf,
	.vidioc_create_bufs		= vb2_ioctl_create_bufs,
	.vidioc_expbuf			= vb2_ioctl_expbuf,
	.vidioc_streamon		= vb2_ioctl_streamon,
	.vidioc_streamoff		= vb2_ioctl_streamoff,
	.vidioc_g_edid			= tegra_channel_g_edid,
	.vidioc_s_edid			= tegra_channel_s_edid,
	.vidioc_s_dv_timings		= tegra_channel_s_dv_timings,
	.vidioc_g_dv_timings		= tegra_channel_g_dv_timings,
	.vidioc_query_dv_timings	= tegra_channel_query_dv_timings,
	.vidioc_enum_dv_timings		= tegra_channel_enum_dv_timings,
	.vidioc_dv_timings_cap		= tegra_channel_dv_timings_cap,
	.vidioc_subscribe_event		= tegra_channel_subscribe_event,
	.vidioc_unsubscribe_event	= v4l2_event_unsubscribe,
	.vidioc_enum_input		= tegra_channel_enum_input,
	.vidioc_g_input			= tegra_channel_g_input,
	.vidioc_s_input			= tegra_channel_s_input,
	.vidioc_log_status		= tegra_channel_log_status,
	.vidioc_default			= tegra_channel_default_ioctl,
	.vidioc_g_parm			= tegra_channel_get_parm,
	.vidioc_s_parm			= tegra_channel_set_parm,

};

static int tegra_channel_close(struct file *fp);
static int tegra_channel_open(struct file *fp)
{
	int ret;
	struct video_device *vdev = video_devdata(fp);
	struct tegra_channel *chan = video_drvdata(fp);
	struct tegra_mc_vi *vi;
	struct tegra_csi_device *csi;

	trace_tegra_channel_open(vdev->name);
	mutex_lock(&chan->video_lock);
	ret = v4l2_fh_open(fp);
	if (ret || !v4l2_fh_is_singular_file(fp)) {
		mutex_unlock(&chan->video_lock);
		return ret;
	}

	if (chan->subdev[0] == NULL) {
		ret = -ENODEV;
		goto fail;
	}

	vi = chan->vi;
	csi = vi->csi;

	chan->fh = (struct v4l2_fh *)fp->private_data;

	if (tegra_channel_verify_focuser(chan)) {
		ret = tegra_channel_set_power(chan, true);
		if (ret < 0)
			return ret;
	}


	mutex_unlock(&chan->video_lock);
	return 0;

fail:
	_vb2_fop_release(fp, NULL);
	mutex_unlock(&chan->video_lock);
	return ret;
}

static int tegra_channel_close(struct file *fp)
{
	int ret = 0;
	struct video_device *vdev = video_devdata(fp);
	struct tegra_channel *chan = video_drvdata(fp);
	struct tegra_mc_vi *vi = chan->vi;
	bool is_singular;

	trace_tegra_channel_close(vdev->name);
	mutex_lock(&chan->video_lock);
	is_singular = v4l2_fh_is_singular_file(fp);
	ret = _vb2_fop_release(fp, NULL);

	if (!is_singular) {
		mutex_unlock(&chan->video_lock);
		return ret;
	}

	if (tegra_channel_verify_focuser(chan)) {
		ret = tegra_channel_set_power(chan, false);
		if (ret < 0)
			dev_err(vi->dev, "Failed to power off subdevices\n");
	}

	mutex_unlock(&chan->video_lock);
	return ret;
}

/* -----------------------------------------------------------------------------
 * V4L2 file operations
 */
static const struct v4l2_file_operations tegra_channel_fops = {
	.owner		= THIS_MODULE,
	.unlocked_ioctl	= video_ioctl2,
#ifdef CONFIG_COMPAT
	.compat_ioctl32 = video_ioctl2,
#endif
	.open		= tegra_channel_open,
	.release	= tegra_channel_close,
	.read		= vb2_fop_read,
	.poll		= vb2_fop_poll,
	.mmap		= vb2_fop_mmap,
};

int tegra_vi_get_port_info(struct tegra_channel *chan,
			struct device_node *node, unsigned int index)
{
	struct device_node *ep = NULL;
	struct device_node *ports;
	struct device_node *port;
	int value = 0xFFFF;
	int ret = 0;
	u32 i = 0;

	ports = of_get_child_by_name(node, "ports");
	if (ports == NULL)
		ports = node;

	for_each_child_of_node(ports, port) {
		if (!port->name || of_node_cmp(port->name, "port"))
			continue;

		ret = of_property_read_u32(port, "reg", &value);
		if (ret < 0)
			continue;

		if (value != index)
			continue;

		for_each_child_of_node(port, ep) {
			if (!ep->name || of_node_cmp(ep->name, "endpoint"))
				continue;

			/* Get virtual channel id */
			ret = of_property_read_u32(ep, "vc-id", &value);

			/* vc-id is optional, default is 0 */
			chan->virtual_channel = (ret < 0) ? 0 : value;

			/* Consider max simultaneous sensor streams to be 16 */
			if (value > 16) {
				dev_err(chan->vi->dev, "vc id >16!\n");
				return -EINVAL;
			}

			/* Get CSI port */
			ret = of_property_read_u32(ep, "port-index", &value);
			if (ret < 0)
				dev_err(chan->vi->dev, "port index error\n");
			chan->port[0] = value;

			if (value > NVCSI_PORT_H) {
				dev_err(chan->vi->dev, "port index >%d!\n",
					NVCSI_PORT_H);
				return -EINVAL;
			}

			/* Get number of data lanes for the endpoint */
			ret = of_property_read_u32(ep, "bus-width", &value);
			if (ret < 0)
				dev_err(chan->vi->dev, "num lanes error\n");
			chan->numlanes = value;

			if (value > 12) {
				dev_err(chan->vi->dev, "num lanes >12!\n");
				return -EINVAL;
			}
			/*
			 * for numlanes greater than 4 multiple CSI bricks
			 * are needed to capture the image, the logic below
			 * checks for numlanes > 4 and add a new CSI brick
			 * as a valid port. Loops around the three CSI
			 * bricks to add as many ports necessary.
			 */
			value -= 4;
			for (i = 1; value > 0 && i < TEGRA_CSI_BLOCKS; i++, value -= 4) {
				int next_port = chan->port[i-1] + 2;

				next_port = (next_port % (NVCSI_PORT_H + 1));
				chan->port[i] = next_port;
			}
		}
	}

	return ret;
}

static int tegra_channel_csi_init(struct tegra_channel *chan)
{
	int idx = 0;
	struct tegra_mc_vi *vi = chan->vi;
	int ret = 0;

	chan->gang_mode = CAMERA_NO_GANG_MODE;
	chan->total_ports = 0;
	memset(&chan->port[0], INVALID_CSI_PORT, TEGRA_CSI_BLOCKS);
	memset(&chan->syncpoint_fifo[0], 0, sizeof(chan->syncpoint_fifo));
	if (chan->pg_mode) {
		/* If VI has 4 existing channels, chan->id will start
		 * from 4 for the first TPG channel, which uses PORT_A(0).
		 * To get the correct PORT number, subtract existing number of
		 * channels from chan->id.
		 */
		chan->port[0] = (chan->id - vi->num_channels)
				% NUM_TPG_INSTANCE;
		chan->virtual_channel =  (chan->id - vi->num_channels)
				/ NUM_TPG_INSTANCE;

		WARN_ON(chan->port[0] > vi->csi->num_tpg_channels);
		chan->numlanes = 2;
	} else {
		ret = tegra_vi_get_port_info(chan, vi->dev->of_node, chan->id);
		if (ret) {
			dev_err(vi->dev, "%s:Fail to parse port info\n",
					__func__);
			return ret;
		}
	}

	for (idx = 0; idx < TEGRA_CSI_BLOCKS && csi_port_is_valid(chan->port[idx]); idx++) {
		chan->total_ports++;
		/* maximum of 4 lanes are present per CSI block */
		chan->csibase[idx] = vi->iomem +
					TEGRA_VI_CSI_BASE(chan->port[idx]);
	}
	/* based on gang mode valid ports will be updated - set default to 1 */
	chan->valid_ports = chan->total_ports ? 1 : 0;
	return ret;
}

static int tegra_metadata_open(struct file *fp)
{
	struct video_device *vdev = video_devdata(fp);
	struct tegra_channel *chan = video_get_drvdata(vdev);
	int ret;

	mutex_lock(&chan->embedded.lock);
	ret = v4l2_fh_open(fp);
	mutex_unlock(&chan->embedded.lock);

	return ret;
}

static int tegra_metadata_close(struct file *fp)
{
	struct video_device *vdev = video_devdata(fp);
	struct tegra_channel *chan = video_get_drvdata(vdev);
	int ret = _vb2_fop_release(fp, &chan->embedded.lock);

	return ret;
}

static const struct v4l2_file_operations tegra_metadata_fops = {
	.owner          = THIS_MODULE,
	.unlocked_ioctl = video_ioctl2,
	.open           = tegra_metadata_open,
	.release        = tegra_metadata_close,
	.read           = vb2_fop_read,
	.poll           = vb2_fop_poll,
	.mmap           = vb2_fop_mmap,
};

static int tegra_metadata_querycap(struct file *file, void *fh,
                                 struct v4l2_capability *cap)
{
	struct v4l2_fh *vfh = file->private_data;
	struct tegra_channel *chan = video_drvdata(file);

	/* FIXME: why do Device Caps show V4L2_CAP_EXT_PIX_FORMAT? */
	cap->device_caps = V4L2_CAP_META_CAPTURE | V4L2_CAP_STREAMING;
	cap->capabilities = cap->device_caps | V4L2_CAP_DEVICE_CAPS |
			V4L2_CAP_EXT_PIX_FORMAT | V4L2_CAP_VIDEO_CAPTURE;

	strlcpy(cap->driver, "tegra-embedded", sizeof(cap->driver));
	strlcpy(cap->card, vfh->vdev->name, sizeof(cap->card));
	snprintf(cap->bus_info, sizeof(cap->bus_info), "platform:%s:%u",
			dev_name(chan->vi->dev), chan->port[0]);

	return 0;
}

static int tegra_metadata_enum_format(struct file *file, void *fh,
                                     struct v4l2_fmtdesc *f)
{
	if (f->index)
		return -EINVAL;

	f->pixelformat = V4L2_META_FMT_G2XX;
	strlcpy(f->description, "G2XX metadata format", sizeof(f->description));

	return 0;
}

static int tegra_metadata_get_format(struct file *file, void *fh,
                                    struct v4l2_format *format)
{
	struct v4l2_fh *vfh = file->private_data;
	struct v4l2_meta_format *fmt = &format->fmt.meta;

	if (format->type != vfh->vdev->queue->type)
		return -EINVAL;

	memset(fmt, 0, sizeof(*fmt));

	fmt->dataformat = V4L2_META_FMT_G2XX;
	fmt->buffersize = 96; //255, orbbec modify

	return 0;
}
static int tegra_metadata_set_format(struct file *file, void *fh,
                                    struct v4l2_format *format)
{
   return 0;
}

static int tegra_metadata_try_format(struct file *file, void *fh,
                                    struct v4l2_format *format)
{
    return 0;
}
static const struct v4l2_ioctl_ops tegra_metadata_ioctl_ops = {
	.vidioc_querycap                = tegra_metadata_querycap,
	.vidioc_enum_fmt_meta_cap       = tegra_metadata_enum_format,
	.vidioc_g_fmt_meta_cap          = tegra_metadata_get_format,
	.vidioc_s_fmt_meta_cap          = tegra_metadata_set_format,
	.vidioc_try_fmt_meta_cap        = tegra_metadata_try_format,
	.vidioc_reqbufs                 = vb2_ioctl_reqbufs,
	.vidioc_querybuf                = vb2_ioctl_querybuf,
	.vidioc_qbuf                    = vb2_ioctl_qbuf,
	.vidioc_dqbuf                   = vb2_ioctl_dqbuf,
	.vidioc_create_bufs             = vb2_ioctl_create_bufs,
	.vidioc_expbuf                  = vb2_ioctl_expbuf,
	.vidioc_streamon                = vb2_ioctl_streamon,
	.vidioc_streamoff               = vb2_ioctl_streamoff,
};

static int tegra_metadata_queue_setup(struct vb2_queue *vq,
                    unsigned int *nbuffers, unsigned int *nplanes,
                    unsigned int sizes[], struct device *alloc_devs[])
{
	struct tegra_channel *chan = vb2_get_drv_priv(vq);

	if (*nplanes) {
		if (*nplanes != 1)
			return -EINVAL;

		if (sizes[0] < 96) //255, orbbec modify
			return -EINVAL;

		return 0;
	}

	*nplanes = 1;
	sizes[0] = 96; //255, orbbec modify
	alloc_devs[0] = chan->vi->dev;


	return 0;
}

static int tegra_metadata_buffer_prepare(struct vb2_buffer *vb)
{
	if (vb->num_planes != 1)
		return -EINVAL;

	if (vb2_plane_size(vb, 0) < 96) //255, orbbec modify
		return -EINVAL;

	return 0;
}

static void tegra_metadata_buffer_queue(struct vb2_buffer *vb)
{
	struct tegra_channel *chan = vb2_get_drv_priv(vb->vb2_queue);

	spin_lock(&chan->embedded.spin_lock);
	if (chan->embedded.num_buffers < 16) {
		chan->embedded.buffers[chan->embedded.head] = vb;
		chan->embedded.head++;
		if (chan->embedded.head > 15)
			chan->embedded.head = chan->embedded.head - 16;
		chan->embedded.num_buffers++;
	}
	spin_unlock(&chan->embedded.spin_lock);
}

static int tegra_metadata_start_streaming(struct vb2_queue *vq, unsigned int count)
{
	return 0;
}

static void tegra_metadata_stop_streaming(struct vb2_queue *vq)
{
	struct tegra_channel *chan = vb2_get_drv_priv(vq);
	int i = 0;

	spin_lock(&chan->embedded.spin_lock);
	for (i = 0; i < chan->embedded.num_buffers; i++) {
		struct vb2_buffer *evb;
		evb = chan->embedded.buffers[chan->embedded.tail];
		chan->embedded.buffers[chan->embedded.tail] = NULL;
		chan->embedded.tail++;
		if (chan->embedded.tail > 15)
			chan->embedded.tail = chan->embedded.tail - 16;
		vb2_buffer_done(evb, VB2_BUF_STATE_ERROR);
	}
	spin_unlock(&chan->embedded.spin_lock);

	chan->embedded.head = 0;
	chan->embedded.tail = 0;;
	chan->embedded.num_buffers = 0;
}

static const struct vb2_ops tegra_metadata_qops = {
	.queue_setup            = tegra_metadata_queue_setup,
	.buf_prepare            = tegra_metadata_buffer_prepare,
	.buf_queue              = tegra_metadata_buffer_queue,
	.wait_prepare           = vb2_ops_wait_prepare,
	.wait_finish            = vb2_ops_wait_finish,
	.start_streaming        = tegra_metadata_start_streaming,
	.stop_streaming         = tegra_metadata_stop_streaming,
};

int tegra_channel_init_video_embedded(struct tegra_channel *chan)
{
	struct video_device *video;
	struct vb2_queue *queue = &chan->embedded.queue;
	struct tegra_mc_vi *vi = chan->vi;
	int ret;

	mutex_init(&chan->embedded.lock);
	spin_lock_init(&chan->embedded.spin_lock);

	video = chan->embedded.video = video_device_alloc();
	chan->embedded.pad.flags = MEDIA_PAD_FL_SINK;

	ret = tegra_media_entity_init(&video->entity, 1,
									&chan->embedded.pad, false, false);
	if (ret < 0) {
		video_device_release(video);
		dev_err(vi->dev, "%s(): metadata entity init: %d\n",
				__func__, ret);
		return ret;
	}

	ret = v4l2_ctrl_handler_init(&chan->embedded.ctrl_handler,
									MAX_CID_CONTROLS);
	if (chan->embedded.ctrl_handler.error) {
		dev_err(&video->dev, "failed to init control handler\n");
		return ret;
	}

	video->fops = &tegra_metadata_fops;
	video->v4l2_dev = &vi->v4l2_dev;
	video->queue = queue;
	snprintf(video->name, sizeof(video->name), "%s-metadata-%u",
			dev_name(vi->dev), chan->port[0]);
#if LINUX_VERSION_CODE < KERNEL_VERSION(5, 4, 0)
	video->vfl_type = VFL_TYPE_GRABBER;
#else
	video->vfl_type = VFL_TYPE_VIDEO;
	video->device_caps = V4L2_CAP_META_CAPTURE | V4L2_CAP_STREAMING;
#endif
	video->vfl_dir = VFL_DIR_RX;
	video->release = video_device_release_empty;
	video->ioctl_ops = &tegra_metadata_ioctl_ops;
	video->ctrl_handler = &chan->embedded.ctrl_handler;
	video->lock = &chan->embedded.lock;

	video_set_drvdata(video, chan);

#if defined(CONFIG_VIDEOBUF2_DMA_CONTIG)
	/* get the buffers queue... */
	ret = tegra_vb2_dma_init(vi->dev, &chan->embedded.alloc_ctx,
					SZ_64K, &vi->vb2_dma_alloc_refcnt);
	if (ret < 0)
		goto ctx_alloc_error;

#endif
//#if defined(CONFIG_VIDEOBUF2_DMA_CONTIG)
	/* get the buffers queue... */
//     chan->embedded.alloc_ctx = vb2_dma_contig_init_ctx(vi->dev);
//     if (IS_ERR(chan->embedded.alloc_ctx)) {
//             dev_err(vi->dev, "%s(): vb2 buffer init: %ld\n", __func__,
//                     PTR_ERR(chan->embedded.alloc_ctx));
//             goto ctx_alloc_error;
//     }
//#endif

	queue->type = V4L2_BUF_TYPE_META_CAPTURE;
	queue->io_modes = VB2_MMAP | VB2_DMABUF | VB2_READ | VB2_USERPTR;
	queue->lock = &chan->embedded.lock;
	queue->drv_priv = chan;
	queue->buf_struct_size = sizeof(struct tegra_channel_buffer);
	queue->ops = &tegra_metadata_qops;
#if defined(CONFIG_VIDEOBUF2_DMA_CONTIG)
	queue->mem_ops = &vb2_dma_contig_memops;
#endif
	queue->timestamp_flags = V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC |
			V4L2_BUF_FLAG_TSTAMP_SRC_EOF;
	ret = vb2_queue_init(queue);
	if (ret < 0) {
		dev_err(vi->dev, "%s(): metadata queue initialize: %d\n",
				__func__, ret);
		goto vb2_queue_error;
	}

	return 0;

vb2_queue_error:
#if defined(CONFIG_VIDEOBUF2_DMA_CONTIG)
	tegra_vb2_dma_cleanup(vi->dev, chan->embedded.alloc_ctx,
			&vi->vb2_dma_alloc_refcnt);
ctx_alloc_error:
#endif
	media_entity_cleanup(&video->entity);

	return ret;
}

int tegra_channel_cleanup_video_embedded(struct tegra_channel *chan)
{
	struct video_device *video = chan->embedded.video;
	struct vb2_queue *queue = &chan->embedded.queue;
	struct device *vi_unit_dev = tegra_channel_get_vi_unit(chan);

	if (!video)
		return -EINVAL;

	video_unregister_device(video);

	/* release embedded data buffer */
	if (chan->emb_buf_size > 0) {
		dma_free_coherent(vi_unit_dev,
				chan->emb_buf_size,
				chan->emb_buf_addr, chan->emb_buf);
		chan->emb_buf_size = 0;
		vb2_queue_release(queue);
#if defined(CONFIG_VIDEOBUF2_DMA_CONTIG)
		tegra_vb2_dma_cleanup(vi_unit_dev, chan->embedded.alloc_ctx,
						&chan->vi->vb2_dma_alloc_refcnt);
#endif
	}

	v4l2_ctrl_handler_free(&chan->embedded.ctrl_handler);

#if defined(CONFIG_MEDIA_CONTROLLER)
	media_entity_cleanup(&video->entity);
#endif

	video_device_release(video);

	return 0;
}

int tegra_channel_init_video(struct tegra_channel *chan)
{
	struct tegra_mc_vi *vi = chan->vi;
	int ret = 0, len = 0;

	if (chan->video) {
		dev_err(&chan->video->dev, "video device already allocated\n");
		return 0;
	}

	chan->video = video_device_alloc();

	/* Initialize the media entity... */
	chan->pad.flags = MEDIA_PAD_FL_SINK;
	ret = tegra_media_entity_init(&chan->video->entity, 1,
					&chan->pad, false, false);
	if (ret < 0) {
		video_device_release(chan->video);
		dev_err(&chan->video->dev, "failed to init video entity\n");
		return ret;
	}

	/* init control handler */
	ret = v4l2_ctrl_handler_init(&chan->ctrl_handler, MAX_CID_CONTROLS);
	if (chan->ctrl_handler.error) {
		dev_err(&chan->video->dev, "failed to init control handler\n");
		goto ctrl_init_error;
	}

	/* init video node... */
	chan->video->fops = &tegra_channel_fops;
	chan->video->v4l2_dev = &vi->v4l2_dev;
	chan->video->queue = &chan->queue;
	len = snprintf(chan->video->name, sizeof(chan->video->name), "%s-%s-%u",
		dev_name(vi->dev), chan->pg_mode ? "tpg" : "output",
		chan->pg_mode ? (chan->id - vi->num_channels) : chan->port[0]);
	if (len < 0) {
		ret = -EINVAL;
		goto ctrl_init_error;
	}

	chan->video->vfl_type = VFL_TYPE_VIDEO;
	chan->video->device_caps = V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING;
	chan->video->device_caps |= V4L2_CAP_EXT_PIX_FORMAT;
	chan->video->vfl_dir = VFL_DIR_RX;
	chan->video->release = video_device_release_empty;
	chan->video->ioctl_ops = &tegra_channel_ioctl_ops;
	chan->video->ctrl_handler = &chan->ctrl_handler;
	chan->video->lock = &chan->video_lock;

	video_set_drvdata(chan->video, chan);

	return ret;

ctrl_init_error:
	video_device_release(chan->video);
	media_entity_cleanup(&chan->video->entity);
	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	return ret;
}
EXPORT_SYMBOL(tegra_channel_init_video);

int tegra_channel_init(struct tegra_channel *chan)
{
	int ret;
	struct tegra_mc_vi *vi = chan->vi;
	struct device *vi_unit_dev;

	ret = tegra_channel_csi_init(chan);
	if (ret)
		return ret;

	/*
	 * The VI device instance has to be retrieved after CSI channel
	 * has been initialized. This will make sure the TPG ports are
	 * setup correctly
	 */
	vi_unit_dev = tegra_channel_get_vi_unit(chan);
	chan->width_align = TEGRA_WIDTH_ALIGNMENT;
	chan->stride_align = TEGRA_STRIDE_ALIGNMENT;
	chan->height_align = TEGRA_HEIGHT_ALIGNMENT;
	chan->size_align = size_align_ctrl_qmenu[TEGRA_SIZE_ALIGNMENT];
	chan->num_subdevs = 0;
	mutex_init(&chan->video_lock);
	chan->capture_descr_index = 0;
	chan->capture_descr_sequence = 0;
	INIT_LIST_HEAD(&chan->capture);
	INIT_LIST_HEAD(&chan->release);
	INIT_LIST_HEAD(&chan->entities);
	init_waitqueue_head(&chan->start_wait);
	init_waitqueue_head(&chan->release_wait);
	atomic_set(&chan->restart_version, 1);
	chan->capture_version = 0;
	spin_lock_init(&chan->start_lock);
	spin_lock_init(&chan->release_lock);
	INIT_LIST_HEAD(&chan->dequeue);
	init_waitqueue_head(&chan->dequeue_wait);
	spin_lock_init(&chan->dequeue_lock);
	mutex_init(&chan->stop_kthread_lock);
	init_rwsem(&chan->reset_lock);
	atomic_set(&chan->is_streaming, DISABLE);
	spin_lock_init(&chan->capture_state_lock);
	spin_lock_init(&chan->buffer_lock);

	/* Init video format */
	vi->fops->vi_init_video_formats(chan);
	chan->fmtinfo = tegra_core_get_default_format();
	tegra_channel_update_format(chan, TEGRA_DEF_WIDTH,
				TEGRA_DEF_HEIGHT,
				chan->fmtinfo->fourcc,
				&chan->fmtinfo->bpp,
				chan->preferred_stride);

	chan->buffer_offset[0] = 0;
	/* Init bpl factor to 1, will be overidden based on interlace_type */
	chan->interlace_bplfactor = 1;

#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
	/* get the buffers queue... */
	ret = tegra_vb2_dma_init(vi_unit_dev, &chan->alloc_ctx,
			SZ_64K, &vi->vb2_dma_alloc_refcnt);
	if (ret < 0)
		goto vb2_init_error;

#endif

	chan->queue.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	chan->queue.io_modes = VB2_MMAP | VB2_DMABUF | VB2_READ | VB2_USERPTR;
	chan->queue.lock = &chan->video_lock;
	chan->queue.drv_priv = chan;
	chan->queue.buf_struct_size = sizeof(struct tegra_channel_buffer);
	chan->queue.ops = &tegra_channel_queue_qops;
#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
	chan->queue.mem_ops = &vb2_dma_contig_memops;
#endif
	chan->queue.timestamp_flags = V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC
				   | V4L2_BUF_FLAG_TSTAMP_SRC_EOF;
	ret = vb2_queue_init(&chan->queue);
	if (ret < 0) {
		dev_err(chan->vi->dev, "failed to initialize VB2 queue\n");
		goto vb2_queue_error;
	}

	chan->deskew_ctx = devm_kzalloc(vi->dev,
			sizeof(struct nvcsi_deskew_context), GFP_KERNEL);
	if (!chan->deskew_ctx) {
		ret = -ENOMEM;
		goto deskew_ctx_err;
	}

	chan->init_done = true;

	return 0;

deskew_ctx_err:
	devm_kfree(vi->dev, chan->deskew_ctx);
vb2_queue_error:
#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
	tegra_vb2_dma_cleanup(vi_unit_dev, chan->alloc_ctx,
		&vi->vb2_dma_alloc_refcnt);
vb2_init_error:
#endif
	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	return ret;
}
EXPORT_SYMBOL(tegra_channel_init);

int tegra_channel_cleanup_video(struct tegra_channel *chan)
{
	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	media_entity_cleanup(&chan->video->entity);
	video_device_release(chan->video);
	return 0;
}
EXPORT_SYMBOL(tegra_channel_cleanup_video);

int tegra_channel_cleanup(struct tegra_channel *chan)
{
	struct device *vi_unit_dev = tegra_channel_get_vi_unit(chan);

	/* release embedded data buffer */
	if (chan->emb_buf_size > 0) {
		dma_free_coherent(vi_unit_dev,
			chan->emb_buf_size,
			chan->emb_buf_addr, chan->emb_buf);
		chan->emb_buf_size = 0;
		vb2_queue_release(&chan->embedded.queue);
#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
		tegra_vb2_dma_cleanup(vi_unit_dev, chan->embedded.alloc_ctx,
			&chan->vi->vb2_dma_alloc_refcnt);
		//vb2_dma_contig_cleanup_ctx(chan->embedded.alloc_ctx);
#endif
		media_entity_cleanup(&chan->embedded.video->entity);
	}

	tegra_channel_dealloc_buffer_queue(chan);

	v4l2_ctrl_handler_free(&chan->ctrl_handler);
	mutex_lock(&chan->video_lock);
	vb2_queue_release(&chan->queue);
#if IS_ENABLED(CONFIG_VIDEOBUF2_DMA_CONTIG)
	tegra_vb2_dma_cleanup(vi_unit_dev, chan->alloc_ctx,
		&chan->vi->vb2_dma_alloc_refcnt);
#endif
	mutex_unlock(&chan->video_lock);

	tegra_camera_device_unregister(chan);

	return 0;
}
EXPORT_SYMBOL(tegra_channel_cleanup);

void tegra_vi_channels_unregister(struct tegra_mc_vi *vi)
{
	struct tegra_channel *it;

	list_for_each_entry(it, &vi->vi_chans, list) {
		if (it->video->cdev != NULL)
			video_unregister_device(it->video);
	}
}
EXPORT_SYMBOL(tegra_vi_channels_unregister);

int tegra_vi_mfi_work(struct tegra_mc_vi *vi, int channel)
{
	if (vi->fops)
		return vi->fops->vi_mfi_work(vi, channel);

	return 0;
}
EXPORT_SYMBOL(tegra_vi_mfi_work);

int tegra_vi_channels_init(struct tegra_mc_vi *vi)
{
	int ret = 0;
	struct tegra_channel *it;
	int count = 0;

	list_for_each_entry(it, &vi->vi_chans, list) {
		it->vi = vi;
		ret = tegra_channel_init(it);
		if (ret < 0) {
			dev_err(vi->dev, "channel init failed\n");
			continue;
		}
		count++;
	}

	if (count == 0) {
		dev_err(vi->dev, "all channel init failed\n");
		return ret;
	}

	return 0;
}
EXPORT_SYMBOL(tegra_vi_channels_init);
int tegra_vi_channels_cleanup(struct tegra_mc_vi *vi)
{
	int ret = 0, err = 0;
	struct tegra_channel *it;

	list_for_each_entry(it, &vi->vi_chans, list) {
		if (!it->init_done)
			continue;
		err = tegra_channel_cleanup(it);
		if (err < 0) {
			ret = err;
			dev_err(vi->dev, "channel cleanup failed, err %d\n",
					err);
		}
	}
	return ret;
}
EXPORT_SYMBOL(tegra_vi_channels_cleanup);
