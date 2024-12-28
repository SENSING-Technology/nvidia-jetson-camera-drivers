#!/bin/bash

sudo cp boot/Image /boot/Image

sudo cp dtb/SGX_YUV_GMSL2/tegra234-p3767-0003-p3768-0000-a0.dtb /boot/dtb/kernel_tegra234-p3767-0003-p3768-0000-a0.dtb

sleep 1s

sudo reboot
