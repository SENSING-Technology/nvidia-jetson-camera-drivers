// SPDX-License-Identifier: GPL-2.0-only
/*
 * Generic software PWM for modulating multiple GPIOs simultaneously
 * Modified to support GPIO array for synchronized camera sync signals
 */

#include <linux/device.h>
#include <linux/err.h>
#include <linux/gpio/consumer.h>
#include <linux/hrtimer.h>
#include <linux/kernel.h>
#include <linux/math64.h>
#include <linux/module.h>
#include <linux/mod_devicetable.h>
#include <linux/platform_device.h>
#include <linux/property.h>
#include <linux/pwm.h>
#include <linux/spinlock.h>
#include <linux/time.h>
#include <linux/types.h>

struct pwm_gpio {
	struct hrtimer gpio_timer;
	
	/* Support multiple GPIOs */
	struct gpio_desc **gpios;
	unsigned int num_gpios;
	
	struct pwm_state state;
	struct pwm_state next_state;

	/* Protect internal state between pwm_ops and hrtimer */
	spinlock_t lock;

	bool changing;
	bool running;
	bool level;
    struct pwm_chip		chip;
};

static struct pwm_gpio *to_pwm_gpio_chip(struct pwm_chip *chip)
{
	return container_of(chip, struct pwm_gpio, chip);
}

static void pwm_gpio_round(struct pwm_state *dest, const struct pwm_state *src)
{
	u64 dividend;
	u32 remainder;

	*dest = *src;

	/* Round down to hrtimer resolution */
	dividend = dest->period;
	remainder = do_div(dividend, hrtimer_resolution);
	dest->period -= remainder;

	dividend = dest->duty_cycle;
	remainder = do_div(dividend, hrtimer_resolution);
	dest->duty_cycle -= remainder;
}

static u64 pwm_gpio_toggle(struct pwm_gpio *gpwm, bool level)
{
	const struct pwm_state *state = &gpwm->state;
	bool invert = state->polarity == PWM_POLARITY_INVERSED;
	unsigned int i;

	gpwm->level = level;
	
	/* Toggle all GPIOs simultaneously */
	for (i = 0; i < gpwm->num_gpios; i++) {
		gpiod_set_value(gpwm->gpios[i], gpwm->level ^ invert);
	}

	if (!state->duty_cycle || state->duty_cycle == state->period) {
		gpwm->running = false;
		return 0;
	}

	gpwm->running = true;
	return level ? state->duty_cycle : state->period - state->duty_cycle;
}

static enum hrtimer_restart pwm_gpio_timer(struct hrtimer *gpio_timer)
{
	struct pwm_gpio *gpwm = container_of(gpio_timer, struct pwm_gpio,
					     gpio_timer);
	u64 next_toggle;
	bool new_level;
    unsigned long flags;

    spin_lock_irqsave(&gpwm->lock, flags);

	/* Apply new state at end of current period */
	if (!gpwm->level && gpwm->changing) {
		gpwm->changing = false;
		gpwm->state = gpwm->next_state;
		new_level = !!gpwm->state.duty_cycle;
	} else {
		new_level = !gpwm->level;
	}

	next_toggle = pwm_gpio_toggle(gpwm, new_level);
	if (next_toggle)
		hrtimer_forward(gpio_timer, hrtimer_get_expires(gpio_timer),
				ns_to_ktime(next_toggle));

    spin_unlock_irqrestore(&gpwm->lock, flags);
	return next_toggle ? HRTIMER_RESTART : HRTIMER_NORESTART;
}

static int pwm_gpio_apply(struct pwm_chip *chip, struct pwm_device *pwm,
			  const struct pwm_state *state)
{
    struct pwm_gpio *gpwm = to_pwm_gpio_chip(chip);
	bool invert = state->polarity == PWM_POLARITY_INVERSED;
    unsigned long flags;
    unsigned int i;
    int ret;

	if (state->duty_cycle && state->duty_cycle < hrtimer_resolution)
		return -EINVAL;

	if (state->duty_cycle != state->period &&
	    (state->period - state->duty_cycle < hrtimer_resolution))
		return -EINVAL;

	if (!state->enabled) {
		hrtimer_cancel(&gpwm->gpio_timer);
	} else if (!gpwm->running) {
		/* Set all GPIOs to output mode */
		for (i = 0; i < gpwm->num_gpios; i++) {
			ret = gpiod_direction_output(gpwm->gpios[i], invert);
			if (ret)
				return ret;
		}
	}

    spin_lock_irqsave(&gpwm->lock, flags);

	if (!state->enabled) {
		pwm_gpio_round(&gpwm->state, state);
		gpwm->running = false;
		gpwm->changing = false;

		for (i = 0; i < gpwm->num_gpios; i++) {
			gpiod_set_value(gpwm->gpios[i], invert);
		}
	} else if (gpwm->running) {
		pwm_gpio_round(&gpwm->next_state, state);
		gpwm->changing = true;
	} else {
		unsigned long next_toggle;

		pwm_gpio_round(&gpwm->state, state);
		gpwm->changing = false;

		next_toggle = pwm_gpio_toggle(gpwm, !!state->duty_cycle);
		if (next_toggle)
			hrtimer_start(&gpwm->gpio_timer, next_toggle,
				      HRTIMER_MODE_REL);
	}

    spin_unlock_irqrestore(&gpwm->lock, flags);
	return 0;
}

static int pwm_gpio_get_state(struct pwm_chip *chip, struct pwm_device *pwm,
			       struct pwm_state *state)
{
     struct pwm_gpio *gpwm = to_pwm_gpio_chip(chip);
    unsigned long flags;

    spin_lock_irqsave(&gpwm->lock, flags);

	if (gpwm->changing)
		*state = gpwm->next_state;
	else
		*state = gpwm->state;

    spin_unlock_irqrestore(&gpwm->lock, flags);

	return 0;
}

static const struct pwm_ops pwm_gpio_ops = {
	.apply = pwm_gpio_apply,
	.get_state = pwm_gpio_get_state,
};

static void pwm_gpio_disable_hrtimer(void *data)
{
	struct pwm_gpio *gpwm = data;
	hrtimer_cancel(&gpwm->gpio_timer);
}

static int pwm_gpio_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct pwm_chip *chip;
	struct pwm_gpio *gpwm;
	int ret;
    unsigned int i;
    struct gpio_desc *desc;

    gpwm = devm_kzalloc(&pdev->dev, sizeof(*gpwm), GFP_KERNEL);
	if (!gpwm)
		return -ENOMEM;

    chip = &gpwm->chip;
	chip->dev = &pdev->dev;
	chip->npwm = 1; 

	spin_lock_init(&gpwm->lock);

    /* Step 1: Count how many GPIOs are defined in Device Tree */
    gpwm->num_gpios = 0;
    while (true) {
        desc = gpiod_get_index(dev, NULL, gpwm->num_gpios, GPIOD_ASIS);
        if (IS_ERR(desc)) {
            if (PTR_ERR(desc) == -ENOENT) {
                break; 
            }
            return dev_err_probe(dev, PTR_ERR(desc),
                     "%pfw: could not get gpio index %d\n",
                     dev_fwnode(dev), gpwm->num_gpios);
        }
        gpiod_put(desc);
        gpwm->num_gpios++;
    }

    if (gpwm->num_gpios == 0) {
        dev_err(dev, "No GPIOs found in device tree\n");
        return -EINVAL;
    }

    dev_info(dev, "Found %d GPIOs, allocating array...\n", gpwm->num_gpios);

    /* Step 2: Allocate array for GPIO descriptors */
    gpwm->gpios = devm_kmalloc_array(&pdev->dev, gpwm->num_gpios, sizeof(struct gpio_desc *), GFP_KERNEL);
    if (!gpwm->gpios) {
        return -ENOMEM;
    }

    /* Step 3: Get all GPIOs and store in array */
    for (i = 0; i < gpwm->num_gpios; i++) {
        gpwm->gpios[i] = devm_gpiod_get_index(dev, NULL, i, GPIOD_ASIS);
        if (IS_ERR(gpwm->gpios[i])) {
            return dev_err_probe(dev, PTR_ERR(gpwm->gpios[i]),
                     "%pfw: failed to get gpio index %d\n",
                     dev_fwnode(dev), i);
        }

        if (gpiod_cansleep(gpwm->gpios[i])) {
            dev_err(dev, "Sleeping GPIO %d not supported\n", i);
            return -EINVAL;
        }
    }

	chip->ops = &pwm_gpio_ops;

	hrtimer_init(&gpwm->gpio_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
	ret = devm_add_action_or_reset(dev, pwm_gpio_disable_hrtimer, gpwm);
	if (ret)
		return ret;

	gpwm->gpio_timer.function = pwm_gpio_timer;

	ret = pwmchip_add(chip);
	if (ret < 0){
		return dev_err_probe(dev, ret, "could not add pwmchip\n");
    }

    dev_info(&pdev->dev,"Init gpio-to-pwm success with %d GPIOs\n", gpwm->num_gpios);
	return 0;
}

static const struct of_device_id pwm_gpio_dt_ids[] = {
	{ .compatible = "pwm-gpio" },
	{ /* sentinel */ }
};
MODULE_DEVICE_TABLE(of, pwm_gpio_dt_ids);

static struct platform_driver pwm_gpio_driver = {
	.driver = {
		.name = "pwm-gpio",
		.of_match_table = pwm_gpio_dt_ids,
	},
	.probe = pwm_gpio_probe,
};
module_platform_driver(pwm_gpio_driver);

MODULE_DESCRIPTION("PWM GPIO driver with multi-GPIO support");
MODULE_AUTHOR("Modified for Jetson Thor/RK3588 Sync");
MODULE_LICENSE("GPL");