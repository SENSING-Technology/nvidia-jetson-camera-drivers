# SPDX-License-Identifier: GPL-2.0
# Copyright (c) 2022, NVIDIA CORPORATION.  All rights reserved.

obj-m += pwm-tegra-tachometer.o
ifdef SG8_AGX_F4_A1
	obj-m += pwm-gpios.o
else
	obj-m += pwm-gpio.o
endif