#!/bin/bash

sudo cp boot/Image /boot/Image
sudo cp dtb/sgx-yuv-gmsl2/tegra234-p3701-0000-p3737-0000.dtb /boot/dtb/kernel_tegra234-p3701-0000-p3737-0000.dtb
sudo cp dtb/sgx-yuv-gmsl2/tegra234-p3701-0005-p3737-0000.dtb /boot/dtb/kernel_tegra234-p3701-0005-p3737-0000.dtb

sync
reboot