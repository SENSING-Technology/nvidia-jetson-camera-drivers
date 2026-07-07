#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9296.ko

# add dtbo
sudo cp dtb/S56_SHF3L/tegra234-camera-s56x1-shf3lx6-overlay.dtbo /boot

# upgrade Image
sudo cp boot/Image /boot/Image

## Install ISP file
sudo rm -rf /var/nvidia/nvcam/settings/*
sudo cp ./isp/*isp /var/nvidia/nvcam/settings/
sudo chmod 644 /var/nvidia/nvcam/settings/*.isp

sync
