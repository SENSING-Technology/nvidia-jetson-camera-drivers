// SPDX-License-Identifier: GPL-2.0
// Copyright (c) 2022-2024, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

#include <nvidia/conftest.h>

#include <linux/tegra-capture-ivc.h>

#include <linux/completion.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/pm_runtime.h>
#include <soc/tegra/ivc_ext.h>
#include <linux/tegra-ivc-bus.h>
#include <linux/nospec.h>
#include <linux/kthread.h>
#include <linux/sched.h>
#include <linux/version.h>
#include <asm/barrier.h>

#include <trace/events/tegra_capture.h>

#include "capture-ivc-priv.h"
#include <linux/semaphore.h>

/* Timeout for acquiring channel-id */
#define TIMEOUT_ACQUIRE_CHANNEL_ID 120

static int tegra_capture_ivc_tx_(struct tegra_capture_ivc *civc,
				const void *req, size_t len)
{
	struct tegra_ivc_channel *chan;
	int ret;

	chan = civc->chan;
	if (chan == NULL || WARN_ON(!chan->is_ready))
		return -EIO;

	ret = mutex_lock_interruptible(&civc->ivc_wr_lock);
	if (unlikely(ret == -EINTR))
		return -ERESTARTSYS;
	if (unlikely(ret))
		return ret;

	ret = wait_event_interruptible(civc->write_q,
				tegra_ivc_can_write(&chan->ivc));
	if (likely(ret == 0))
		ret = tegra_ivc_write(&chan->ivc, NULL, req, len);

	mutex_unlock(&civc->ivc_wr_lock);

	if (unlikely(ret < 0))
		dev_err(&chan->dev, "tegra_ivc_write: error %d\n", ret);

	return ret;
}

static int tegra_capture_ivc_tx(struct tegra_capture_ivc *civc,
				const void *req, size_t len)
{
	int ret;
	struct tegra_capture_ivc_msg_header hdr;
	size_t hdrlen = sizeof(hdr);
	char const *ch_name = "NULL";

	if (civc->chan)
		ch_name = dev_name(&civc->chan->dev);

	if (len < hdrlen) {
		memset(&hdr, 0, hdrlen);
		memcpy(&hdr, req, len);
	} else {
		memcpy(&hdr, req, hdrlen);
	}

	ret = tegra_capture_ivc_tx_(civc, req, len);

	if (ret < 0)
		trace_capture_ivc_send_error(ch_name, hdr.msg_id, hdr.channel_id, ret);
	else
		trace_capture_ivc_send(ch_name, hdr.msg_id, hdr.channel_id);

	return ret;
}

int tegra_capture_ivc_control_submit(const void *control_desc, size_t len)
{
	if (WARN_ON(__scivc_control == NULL))
		return -ENODEV;

	return tegra_capture_ivc_tx(__scivc_control, control_desc, len);
}
EXPORT_SYMBOL(tegra_capture_ivc_control_submit);

int tegra_capture_ivc_capture_submit(const void *capture_desc, size_t len)
{
	if (WARN_ON(__scivc_capture == NULL))
		return -ENODEV;

	return tegra_capture_ivc_tx(__scivc_capture, capture_desc, len);
}
EXPORT_SYMBOL(tegra_capture_ivc_capture_submit);

int tegra_capture_ivc_register_control_cb(
		tegra_capture_ivc_cb_func control_resp_cb,
		uint32_t *trans_id, const void *priv_context)
{
	struct tegra_capture_ivc *civc;
	struct tegra_capture_ivc_cb_ctx *cb_ctx;
	size_t ctx_id;
	int ret;

	/* Check if inputs are valid */
	if (WARN(control_resp_cb == NULL, "callback function is NULL"))
		return -EINVAL;
	if (WARN(trans_id == NULL, "return value trans_id is NULL"))
		return -EINVAL;
	if (WARN_ON(!__scivc_control))
		return -ENODEV;

	civc = __scivc_control;

	ret = tegra_ivc_channel_runtime_get(civc->chan);
	if (unlikely(ret < 0))
		return ret;

	spin_lock(&civc->avl_ctx_list_lock);
	if (unlikely(list_empty(&civc->avl_ctx_list))) {
		spin_unlock(&civc->avl_ctx_list_lock);
		ret = -EAGAIN;
		goto fail;
	}


	cb_ctx = list_first_entry(&civc->avl_ctx_list,
			struct tegra_capture_ivc_cb_ctx, node);

	list_del(&cb_ctx->node);
	spin_unlock(&civc->avl_ctx_list_lock);

	ctx_id = cb_ctx - &civc->cb_ctx[0];

	if (WARN(ctx_id < TRANS_ID_START_IDX ||
			ctx_id >= ARRAY_SIZE(civc->cb_ctx),
			"invalid cb_ctx %zu", ctx_id)) {
		ret = -EIO;
		goto fail;
	}

	mutex_lock(&civc->cb_ctx_lock);

	if (WARN(cb_ctx->cb_func != NULL, "cb_ctx is busy")) {
		ret = -EIO;
		goto locked_fail;
	}

	*trans_id = (uint32_t)ctx_id;
	cb_ctx->cb_func = control_resp_cb;
	cb_ctx->priv_context = priv_context;

	mutex_unlock(&civc->cb_ctx_lock);

	return 0;

locked_fail:
	mutex_unlock(&civc->cb_ctx_lock);
fail:
	tegra_ivc_channel_runtime_put(civc->chan);
	return ret;
}
EXPORT_SYMBOL(tegra_capture_ivc_register_control_cb);

int tegra_capture_ivc_notify_chan_id(uint32_t chan_id, uint32_t trans_id)
{
	struct tegra_capture_ivc *civc;

	if (WARN(chan_id >= NUM_CAPTURE_CHANNELS, "invalid chan_id"))
		return -EINVAL;
	if (WARN(trans_id < TRANS_ID_START_IDX ||
			trans_id >= TOTAL_CHANNELS, "invalid trans_id"))
		return -EINVAL;
	if (WARN_ON(!__scivc_control))
		return -ENODEV;

	chan_id  = array_index_nospec(chan_id,  NUM_CAPTURE_CHANNELS);
	trans_id = array_index_nospec(trans_id, TOTAL_CHANNELS);

	civc = __scivc_control;

    if (down_timeout(&civc->cb_ctx[chan_id].sem_ch, TIMEOUT_ACQUIRE_CHANNEL_ID)) {
        return -EBUSY;
    }

	mutex_lock(&civc->cb_ctx_lock);

	if (WARN(civc->cb_ctx[trans_id].cb_func == NULL,
			"transaction context at %u is idle", trans_id)) {
		mutex_unlock(&civc->cb_ctx_lock);
		return -EBADF;
	}

	if (WARN(civc->cb_ctx[chan_id].cb_func != NULL,
			"channel context at %u is busy", chan_id)) {
		mutex_unlock(&civc->cb_ctx_lock);
		return -EBUSY;
	}

	/* Update cb_ctx index */
	civc->cb_ctx[chan_id].cb_func = civc->cb_ctx[trans_id].cb_func;
	civc->cb_ctx[chan_id].priv_context =
			civc->cb_ctx[trans_id].priv_context;

	/* Reset trans_id cb_ctx fields */
	civc->cb_ctx[trans_id].cb_func = NULL;
	civc->cb_ctx[trans_id].priv_context = NULL;

	mutex_unlock(&civc->cb_ctx_lock);

	spin_lock(&civc->avl_ctx_list_lock);
	list_add_tail(&civc->cb_ctx[trans_id].node, &civc->avl_ctx_list);
	spin_unlock(&civc->avl_ctx_list_lock);

	return 0;
}
EXPORT_SYMBOL(tegra_capture_ivc_notify_chan_id);

int tegra_capture_ivc_register_capture_cb(
		tegra_capture_ivc_cb_func capture_status_ind_cb,
		uint32_t chan_id, const void *priv_context)
{
	struct tegra_capture_ivc *civc;
	int ret;

	if (WARN(capture_status_ind_cb == NULL, "callback function is NULL"))
		return -EINVAL;

	if (WARN(chan_id >= NUM_CAPTURE_CHANNELS,
			"invalid channel id %u", chan_id))
		return -EINVAL;
	chan_id = array_index_nospec(chan_id, NUM_CAPTURE_CHANNELS);

	if (!__scivc_capture)
		return -ENODEV;

	civc = __scivc_capture;

	ret = tegra_ivc_channel_runtime_get(civc->chan);
	if (ret < 0)
		return ret;

	mutex_lock(&civc->cb_ctx_lock);

	if (WARN(civc->cb_ctx[chan_id].cb_func != NULL,
			"capture channel %u is busy", chan_id)) {
		ret = -EBUSY;
		goto fail;
	}

	civc->cb_ctx[chan_id].cb_func = capture_status_ind_cb;
	civc->cb_ctx[chan_id].priv_context = priv_context;
	mutex_unlock(&civc->cb_ctx_lock);

	return 0;
fail:
	mutex_unlock(&civc->cb_ctx_lock);
	tegra_ivc_channel_runtime_put(civc->chan);

	return ret;
}
EXPORT_SYMBOL(tegra_capture_ivc_register_capture_cb);

int tegra_capture_ivc_unregister_control_cb(uint32_t id)
{
	struct tegra_capture_ivc *civc;

	/* id could be temporary trans_id or rtcpu-allocated chan_id */
	if (WARN(id >= TOTAL_CHANNELS, "invalid id %u", id))
		return -EINVAL;
	if (WARN_ON(!__scivc_control))
		return -ENODEV;

	id = array_index_nospec(id, TOTAL_CHANNELS);

	civc = __scivc_control;

	mutex_lock(&civc->cb_ctx_lock);

	up(&civc->cb_ctx[id].sem_ch);

	if (WARN(civc->cb_ctx[id].cb_func == NULL,
			"control channel %u is idle", id)) {
		mutex_unlock(&civc->cb_ctx_lock);
		return -EBADF;
	}

	civc->cb_ctx[id].cb_func = NULL;
	civc->cb_ctx[id].priv_context = NULL;

	mutex_unlock(&civc->cb_ctx_lock);

	/*
	 * If it's trans_id, client encountered an error before or during
	 * chan_id update, in that case the corresponding cb_ctx
	 * needs to be added back in the avilable cb_ctx list.
	 */
	if (id >= TRANS_ID_START_IDX) {
		spin_lock(&civc->avl_ctx_list_lock);
		list_add_tail(&civc->cb_ctx[id].node, &civc->avl_ctx_list);
		spin_unlock(&civc->avl_ctx_list_lock);
	}

	tegra_ivc_channel_runtime_put(civc->chan);

	return 0;
}
EXPORT_SYMBOL(tegra_capture_ivc_unregister_control_cb);

int tegra_capture_ivc_unregister_capture_cb(uint32_t chan_id)
{
	struct tegra_capture_ivc *civc;

	if (chan_id >= NUM_CAPTURE_CHANNELS)
		return -EINVAL;

	if (!__scivc_capture)
		return -ENODEV;

	chan_id = array_index_nospec(chan_id, NUM_CAPTURE_CHANNELS);

	civc = __scivc_capture;

	mutex_lock(&civc->cb_ctx_lock);

	if (WARN(civc->cb_ctx[chan_id].cb_func == NULL,
			"capture channel %u is idle", chan_id)) {
		mutex_unlock(&civc->cb_ctx_lock);
		return -EBADF;
	}

	civc->cb_ctx[chan_id].cb_func = NULL;
	civc->cb_ctx[chan_id].priv_context = NULL;

	mutex_unlock(&civc->cb_ctx_lock);

	tegra_ivc_channel_runtime_put(civc->chan);

	return 0;
}
EXPORT_SYMBOL(tegra_capture_ivc_unregister_capture_cb);

static inline void tegra_capture_ivc_recv_msg(
	struct tegra_capture_ivc *civc,
	uint32_t id,
	const void *msg)
{
	struct device *dev = &civc->chan->dev;

	/* Check if callback function available */
	if (unlikely(!civc->cb_ctx[id].cb_func)) {
		dev_dbg(dev, "No callback for id %u\n", id);
	} else {
		/* Invoke client callback. */
		civc->cb_ctx[id].cb_func(msg, civc->cb_ctx[id].priv_context);
	}
}

static inline void tegra_capture_ivc_recv(struct tegra_capture_ivc *civc)
{
	struct tegra_ivc *ivc = &civc->chan->ivc;
	struct device *dev = &civc->chan->dev;
	const void *msg;
	const struct tegra_capture_ivc_msg_header *hdr;
	uint32_t id;

	while (tegra_ivc_can_read(ivc)) {
#if defined(NV_TEGRA_IVC_STRUCT_HAS_IOSYS_MAP) /* Linux 6.2 */
		struct iosys_map map;
		int err;
		err = tegra_ivc_read_get_next_frame(ivc, &map);
		if (err) {
			dev_err(dev, "Failed to get next frame for read\n");
			return;
		}
		msg = map.vaddr;
#else
		msg = tegra_ivc_read_get_next_frame(ivc);
#endif
		hdr = msg;
		id = hdr->channel_id;

		trace_capture_ivc_recv(dev_name(dev), hdr->msg_id, id);

		/* Check if message is valid */
		if (id < TOTAL_CHANNELS) {
			id = array_index_nospec(id, TOTAL_CHANNELS);
			tegra_capture_ivc_recv_msg(civc, id, msg);
		} else {
			dev_WARN(dev, "Invalid rtcpu channel id %u", id);
		}

		tegra_ivc_read_advance(ivc);
	}
}

static void tegra_capture_ivc_worker(struct kthread_work *work)
{
	struct tegra_capture_ivc *civc;
	struct tegra_ivc_channel *chan;

	civc = container_of(work, struct tegra_capture_ivc, work);
	chan = civc->chan;

	/*
	 * Do not process IVC events if worker gets woken up while
	 * this channel is suspended.  There is a Christmas tree
	 * notify when RCE resumes and IVC bus gets set up.
	 */
	if (pm_runtime_get_if_in_use(&chan->dev) > 0) {
		WARN_ON(!chan->is_ready);

		tegra_capture_ivc_recv(civc);

		pm_runtime_put(&chan->dev);
	} else {
		dev_dbg(&chan->dev, "extra wakeup");
	}
}

static void tegra_capture_ivc_notify(struct tegra_ivc_channel *chan)
{
	struct tegra_capture_ivc *civc = tegra_ivc_channel_get_drvdata(chan);

	trace_capture_ivc_notify(dev_name(&chan->dev));

	/* Only 1 thread can wait on write_q, rest wait for write_lock */
	wake_up(&civc->write_q);
	kthread_queue_work(&civc->ivc_worker, &civc->work);
}

#define NV(x) "nvidia," #x

static int tegra_capture_ivc_probe(struct tegra_ivc_channel *chan)
{
	struct device *dev = &chan->dev;
	struct tegra_capture_ivc *civc;
	const char *service;
	int ret;
	uint32_t i;

	civc = devm_kzalloc(dev, (sizeof(*civc)), GFP_KERNEL);
	if (unlikely(civc == NULL))
		return -ENOMEM;

	ret = of_property_read_string(dev->of_node, NV(service),
			&service);
	if (unlikely(ret)) {
		dev_err(dev, "missing <%s> property\n", NV(service));
		return ret;
	}

	civc->chan = chan;

	mutex_init(&civc->cb_ctx_lock);
	mutex_init(&civc->ivc_wr_lock);

	for (i = 0; i < TOTAL_CHANNELS; i++) sema_init(&civc->cb_ctx[i].sem_ch, 1);

	/* Initialize kworker */
	kthread_init_work(&civc->work, tegra_capture_ivc_worker);

	kthread_init_worker(&civc->ivc_worker);

	civc->ivc_kthread = kthread_create(&kthread_worker_fn,
			&civc->ivc_worker, service);
	if (IS_ERR(civc->ivc_kthread)) {
		dev_err(dev, "Cannot allocate ivc worker thread\n");
		ret = PTR_ERR(civc->ivc_kthread);
		goto err;
	}
	sched_set_fifo_low(civc->ivc_kthread);
	wake_up_process(civc->ivc_kthread);

	/* Initialize wait queue */
	init_waitqueue_head(&civc->write_q);

	/* transaction-id list of available callback contexts */
	spin_lock_init(&civc->avl_ctx_list_lock);
	INIT_LIST_HEAD(&civc->avl_ctx_list);

	/* Add the transaction cb-contexts to the available list */
	for (i = TRANS_ID_START_IDX; i < ARRAY_SIZE(civc->cb_ctx); i++)
		list_add_tail(&civc->cb_ctx[i].node, &civc->avl_ctx_list);

	tegra_ivc_channel_set_drvdata(chan, civc);

	if (!strcmp("capture-control", service)) {
		if (WARN_ON(__scivc_control != NULL)) {
			ret = -EEXIST;
			goto err_service;
		}
		__scivc_control = civc;
	} else if (!strcmp("capture", service)) {
		if (WARN_ON(__scivc_capture != NULL)) {
			ret = -EEXIST;
			goto err_service;
		}
		__scivc_capture = civc;
	} else {
		dev_err(dev, "Unknown ivc channel %s\n", service);
		ret = -EINVAL;
		goto err_service;
	}

	return 0;

err_service:
	kthread_stop(civc->ivc_kthread);
err:
	return ret;
}

static void tegra_capture_ivc_remove(struct tegra_ivc_channel *chan)
{
	struct tegra_capture_ivc *civc = tegra_ivc_channel_get_drvdata(chan);

	kthread_flush_worker(&civc->ivc_worker);
	kthread_stop(civc->ivc_kthread);

	if (__scivc_control == civc)
		__scivc_control = NULL;
	else if (__scivc_capture == civc)
		__scivc_capture = NULL;
	else
		dev_warn(&chan->dev, "Unknown ivc channel\n");
}

static struct of_device_id tegra_capture_ivc_channel_of_match[] = {
	{ .compatible = "nvidia,tegra186-camera-ivc-protocol-capture-control" },
	{ .compatible = "nvidia,tegra186-camera-ivc-protocol-capture" },
	{ },
};
MODULE_DEVICE_TABLE(of, tegra_capture_ivc_channel_of_match);

static const struct tegra_ivc_channel_ops tegra_capture_ivc_ops = {
	.probe	= tegra_capture_ivc_probe,
	.remove	= tegra_capture_ivc_remove,
	.notify	= tegra_capture_ivc_notify,
};

static struct tegra_ivc_driver tegra_capture_ivc_driver = {
	.driver = {
		.name	= "tegra-capture-ivc",
		.bus	= &tegra_ivc_bus_type,
		.owner	= THIS_MODULE,
		.of_match_table = tegra_capture_ivc_channel_of_match,
	},
	.dev_type	= &tegra_ivc_channel_type,
	.ops.channel	= &tegra_capture_ivc_ops,
};

tegra_ivc_subsys_driver_default(tegra_capture_ivc_driver);
MODULE_AUTHOR("Sudhir Vyas <svyas@nvidia.com>");
MODULE_DESCRIPTION("NVIDIA Tegra Capture IVC driver");
MODULE_LICENSE("GPL v2");
