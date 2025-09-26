#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/types.h>
#include <linux/slab.h>
#include <linux/fs.h>
#include <linux/interrupt.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/gpio.h>
#include <asm/ioctl.h>
#include <linux/of_gpio.h>
#include <linux/of.h>
#include <linux/pwm.h>
#include <linux/platform_device.h>
#include <linux/regulator/consumer.h>

//--------------------------------------------------------------------------
#define DELAY_TIME	   	1 //20ms

#define FPS_SCALE       100

#define SYNC_HWTIMER_OFFSET_TIME   20   //20us

//--------------------------------------------------------------------------
#define CAM_SYNC_START      _IOW('c', 1, int)
#define CAM_SYNC_STOP       _IOW('c', 2, int)

//--------------------------------------------------------------------------
typedef enum {
    MODE_SYNC_IN,
    MODE_SYNC_OUT
} cs_mode_e;

typedef enum {
    NO_TRIGGER,
    GPIO_TRIGGER,
    PWM_TRIGGER
} trigger_type_t;

typedef struct {
    uint8_t mode;
    uint16_t fps; //30.04fps
} cs_param_t;

typedef struct {
    struct mutex lock;
    struct device *dev;
    struct regulator *reg;
    struct pwm_device *pwm;
	struct pwm_state pwm_state;
    struct hrtimer trigger_timer;
    struct timer_list delay_timer;
    cs_param_t param;
    unsigned long pwm_period;
    unsigned long pwm_value;
    uint32_t trigger_type;
    uint32_t irq; /* IRQ number */
    unsigned long hdelay;
    unsigned long ldelay;
    int sync_in_gpios;
    int sync_out_gpios;
    bool irq_enabled;
    uint8_t is_high;
    // ktime_t kt;
} cam_sync_t;

cam_sync_t *cam_sync = NULL;
int m_lock = 0;

//--------------------------------------------------------------------------
static int debug_en = 0;
module_param(debug_en, int, 0644);

//--------------------------------------------------------------------------
static void sync_enable_irq(void)
{
    if(cam_sync->irq_enabled == false)
    {
        enable_irq(cam_sync->irq);
        cam_sync->irq_enabled = true;
    }
}

static void sync_disable_irq(void)
{
    if(cam_sync->irq_enabled == true)
    {
        disable_irq(cam_sync->irq);
        cam_sync->irq_enabled = false;
    }
}

static int set_pwm_period(cam_sync_t *cam_sync, unsigned long period)
{
	int ret = 0;
	struct pwm_state *state = &cam_sync->pwm_state;

	mutex_lock(&cam_sync->lock);

    if(period > cam_sync->pwm_state.duty_cycle){
        state->enabled = true;
    }
    else{
        dev_err(cam_sync->dev, "pwm_period is too short\n");
        goto exit_set_pwm_err;
    }
	state->period = period;
	ret = pwm_apply_state(cam_sync->pwm, state);
	if (ret)
        dev_err(cam_sync->dev, "set pwm_period err \n");
    else 
		cam_sync->pwm_period = period;
    dev_info(cam_sync->dev, "set pwm_period to %lldns\n", state->period);
exit_set_pwm_err:
	mutex_unlock(&cam_sync->lock);
	return ret;
}

static void cam_sync_stop(void)
{
    sync_disable_irq();

    if(cam_sync->trigger_type == GPIO_TRIGGER)
        hrtimer_cancel(&cam_sync->trigger_timer);
    else if(cam_sync->trigger_type == PWM_TRIGGER)
        pwm_disable(cam_sync->pwm);
    if (cam_sync->sync_in_gpios >0 && cam_sync->sync_out_gpios >0)
        del_timer(&cam_sync->delay_timer);
    if(cam_sync->sync_out_gpios > 0) 
        gpio_set_value(cam_sync->sync_out_gpios, 0);

    dev_info(cam_sync->dev, "cam sync close\n");
}

static void cam_sync_set_mode(cs_param_t *param)
{
    unsigned long period;
    if(cam_sync->sync_out_gpios > 0) gpio_set_value(cam_sync->sync_out_gpios, 0);
    if(m_lock == 1)
    {
        m_lock = 0;
        del_timer(&cam_sync->delay_timer);
    }
    if(param->mode == MODE_SYNC_IN)
    {
        if(cam_sync->trigger_type == GPIO_TRIGGER) 
            hrtimer_cancel(&cam_sync->trigger_timer);
        else if(cam_sync->trigger_type == PWM_TRIGGER)
            pwm_disable(cam_sync->pwm);
        sync_enable_irq();
        dev_info(cam_sync->dev, "sync in trigger mode\n");
    }
    else
    {
        int offset = SYNC_HWTIMER_OFFSET_TIME;
        ktime_t kt;
        switch (param->fps)
        {
        case 6000:
            offset = 30;
            break;

        case 3000:
            offset = 100;
            break;

        case 1500:
            offset = 100;
            break;

        case 1000:
            offset = 100;
            break;

        case 600:
            offset = 100;
            break;

        case 500:
            offset = 100;
            break;

        default:
            offset = SYNC_HWTIMER_OFFSET_TIME;
            break;
        }
        sync_disable_irq();
        cam_sync->ldelay = 1000000*FPS_SCALE/param->fps - cam_sync->hdelay + offset; //us
        kt = ktime_set(0, cam_sync->ldelay * 1000);//ns
        period = (cam_sync->ldelay + cam_sync->hdelay)*1000;

        dev_info(cam_sync->dev, "sync out mode pwm_period :%ldns\n", period);

        if(cam_sync->trigger_type == GPIO_TRIGGER){
            cam_sync->is_high = 0;
            hrtimer_start(&cam_sync->trigger_timer, kt, HRTIMER_MODE_REL_PINNED_HARD);
        }
        else if(cam_sync->trigger_type == PWM_TRIGGER){
            set_pwm_period(cam_sync, period);
        }
    }
}

static ssize_t cam_sync_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
{
    int ret;
    //cam_sync_t *cam_sync = container_of(file->private_data, cam_sync_t, misc_dev);
    dev_info(cam_sync->dev, "cam-sync read:%d, %d\n", cam_sync->param.mode, cam_sync->param.fps);

    ret = copy_to_user(buf, &cam_sync->param, sizeof(cam_sync->param));
    if(ret)
    {
        dev_info(cam_sync->dev, "copy_to_user err:%d\n", ret);
        return ret;
    }
    return 0;
}

static ssize_t cam_sync_write(struct file *file, const char __user *buf, size_t count, loff_t *pos)
{
    //cam_sync_t *cam_sync = container_of(file->private_data, cam_sync_t, misc_dev);
    cs_param_t param;
    int ret = copy_from_user(&param, buf, sizeof(param));
    if(ret)
    {
        dev_info(cam_sync->dev, "copy_from_user err:%d\n", ret);
        return ret;
    }
    dev_info(cam_sync->dev, "cam-sync write:%d, %d\n", param.mode, param.fps);

    if(param.mode > 2 || param.fps < 4*FPS_SCALE || param.fps > 120*FPS_SCALE) //4~120fps
        return -1;

    cam_sync_set_mode(&param);
    cam_sync->param = param;

    return 0;
}

static long cam_sync_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    if(cmd == CAM_SYNC_START)
    {
        cs_param_t param;
        int ret = copy_from_user(&param, (void*)arg, sizeof(param));
        if(ret)
        {
            dev_info(cam_sync->dev, "copy_from_user err:%d\n", ret);
            return ret;
        }
        cam_sync_set_mode(&param);
        dev_info(cam_sync->dev, "cam sync start\n");
    }
    else if(cmd == CAM_SYNC_STOP)
    {
        cam_sync_stop();
        dev_info(cam_sync->dev, "cam sync stop\n");
    }
    else
    {
        return -1;
    }

    return 0;
}

static int cam_sync_open(struct inode *inode, struct file *file)
{
    dev_info(cam_sync->dev, "cam sync open\n");
    return 0;
}

static int cam_sync_release(struct inode *inode, struct file *file)
{
    //cam_sync_t *cam_sync = container_of(file->private_data, cam_sync_t, misc_dev);
    cam_sync_stop();
    return 0;
}

static const struct file_operations cam_sync_fops = {
    .owner   = THIS_MODULE,
    .llseek  = no_llseek,
    .write   = cam_sync_write,
    .read    = cam_sync_read,
    .unlocked_ioctl = cam_sync_ioctl,
    .open    = cam_sync_open,
    .release = cam_sync_release,
};

static enum hrtimer_restart cam_sync_hrtimer_irq(struct hrtimer *timer)
{
    ktime_t kt;

    gpio_set_value(cam_sync->sync_out_gpios, cam_sync->is_high ? 1 : 0);

    kt = ktime_set(0, (cam_sync->is_high ? cam_sync->hdelay : cam_sync->ldelay) * 1000); //ns
    hrtimer_forward(timer, timer->base->get_time(), kt);//hrtimer_forward(trigger_timer, now, tick_period);
    cam_sync->is_high ^= 1;
    dev_dbg(cam_sync->dev, "htim\n");
	return HRTIMER_RESTART; //HRTIMER_NORESTART
}

static void cam_sync_in_timer_irq(struct timer_list *timer)
{
    gpio_set_value(cam_sync->sync_out_gpios, 0);
    del_timer(timer);
    m_lock = 0;
    dev_dbg(cam_sync->dev, "tim\n");
}

static irqreturn_t cam_sync_in_trigger_irq(int irq, void *data)
{
    if(m_lock)
        return IRQ_HANDLED;
    m_lock = 1;

    gpio_set_value(cam_sync->sync_out_gpios, 1);

    dev_dbg(cam_sync->dev, "tri\n");

    /* start trigger_timer */
    cam_sync->delay_timer.expires = jiffies + DELAY_TIME;
    add_timer(&cam_sync->delay_timer);

    return IRQ_HANDLED;
}

static struct miscdevice csync_misc_device = {
    .minor = MISC_DYNAMIC_MINOR,
    .name = "camsync",
    .fops = &cam_sync_fops,
};

static int obc_cam_sync_probe(struct platform_device *pdev)
{
    struct device *dev = &pdev->dev;
    int err = 0;
    struct device_node *node = dev->of_node;
    cam_sync = devm_kzalloc(dev, sizeof(cam_sync_t), GFP_KERNEL);
    if(!cam_sync) {
        dev_err(dev, "failed to malloc cam_sync_t\n");
        return -ENOMEM;
    }
    mutex_init(&cam_sync->lock);
    cam_sync->dev = dev;

    cam_sync->sync_in_gpios = of_get_named_gpio(node, "sync-in-gpios", 0);
	if (cam_sync->sync_in_gpios < 0) {
		dev_info(dev, "sync-in-gpios not found\n");
	}
    
    cam_sync->sync_out_gpios = of_get_named_gpio(node, "sync-out-gpios", 0);
	if (cam_sync->sync_out_gpios < 0) {
		dev_info(dev, "sync-out-gpios not found\n");
	}
    else{
        gpio_request(cam_sync->sync_out_gpios, "sync-out");
        gpio_direction_output(cam_sync->sync_out_gpios, 0);
        cam_sync->hdelay = 1000; //1ms
        cam_sync->ldelay = 32333; //32.333ms
        cam_sync->trigger_type = GPIO_TRIGGER;

        hrtimer_init(&cam_sync->trigger_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL_PINNED_HARD);
        cam_sync->trigger_timer.function = cam_sync_hrtimer_irq;
        hrtimer_cancel(&cam_sync->trigger_timer);
    }

    if (cam_sync->sync_in_gpios >0 && cam_sync->sync_out_gpios >0){
        gpio_request(cam_sync->sync_in_gpios, "sync-in");
        gpio_direction_input(cam_sync->sync_in_gpios);
        cam_sync->irq = gpio_to_irq(cam_sync->sync_in_gpios);
        dev_info(cam_sync->dev, "gpio to irq: %d -> %d\n", cam_sync->sync_in_gpios, cam_sync->irq);

        // disable_irq(cam_sync->irq);
        cam_sync->irq_enabled = false;
        timer_setup(&cam_sync->delay_timer, cam_sync_in_timer_irq, 0);
        err = request_irq(cam_sync->irq, cam_sync_in_trigger_irq, IRQF_TRIGGER_RISING, "cam_sync_in_trigger_irq", NULL);
        if (err) {
            dev_info(cam_sync->dev, "failed to request cam_sync_in_trigger_irq\n");
            return err;
        }
    }
    
    cam_sync->pwm = devm_of_pwm_get(dev, dev->of_node, NULL);
	if (IS_ERR(cam_sync->pwm))
        dev_info(dev, "Could not get PWM\n");
    else {
        cam_sync->trigger_type = PWM_TRIGGER;
        pwm_init_state(cam_sync->pwm, &cam_sync->pwm_state);
        cam_sync->pwm_state.duty_cycle = 1000000; //1ms
        pwm_apply_state(cam_sync->pwm, &cam_sync->pwm_state);

    }
    if (cam_sync->sync_out_gpios < 0 && IS_ERR(cam_sync->pwm)) 
        return -EINVAL;

    platform_set_drvdata(pdev, cam_sync);

    err = misc_register(&csync_misc_device);
    if (err) {
        dev_info(cam_sync->dev, "misc_register failed\n");
        return err;
    }

    dev_info(cam_sync->dev, "camsync misc register success!\n");

    return 0;
}

static int obc_cam_sync_remove(struct platform_device *pdev)
{
    //misc_deregister(&cam_sync->misc_dev);
    misc_deregister(&csync_misc_device);
    free_irq(cam_sync->irq, NULL);
    if(cam_sync->sync_in_gpios > 0) gpio_free(cam_sync->sync_in_gpios);
    if(cam_sync->sync_out_gpios > 0) gpio_free(cam_sync->sync_out_gpios);
    if(cam_sync->pwm != NULL) pwm_free(cam_sync->pwm);
    kfree(cam_sync);
    return 0;
}

static const struct of_device_id of_obc_cam_sync_match[] = {
	{ .compatible = "orbbec,obc_cam_sync", },
	{},
};
MODULE_DEVICE_TABLE(of, of_obc_cam_sync_match);

static struct platform_driver obc_cam_sync_driver = {
	.probe		= obc_cam_sync_probe,
    .remove = obc_cam_sync_remove,
	.driver	= {
		.name		= "obc_cam_sync",
		.of_match_table	= of_obc_cam_sync_match,
	},
};

module_platform_driver(obc_cam_sync_driver);

MODULE_AUTHOR("xuanyuan@orbbec.com");
MODULE_AUTHOR("yanxiao@orbbec.com");
MODULE_DESCRIPTION(" orbbec mult-device-sync trigger");
MODULE_LICENSE("GPL");