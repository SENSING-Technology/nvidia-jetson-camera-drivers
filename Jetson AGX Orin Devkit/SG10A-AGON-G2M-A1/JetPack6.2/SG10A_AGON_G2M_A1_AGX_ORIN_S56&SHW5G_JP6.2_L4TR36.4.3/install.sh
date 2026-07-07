#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9296.ko

# add dtbo
sudo cp dtb/S56_SHW5G/tegra234-camera-s56x2-shw5gx6-overlay.dtbo /boot/
sudo cp dtb/S56_SHW5G/tegra234-camera-shw5g-gmsl2x10-overlay.dtbo /boot/
sudo cp dtb/S56_SHW5G/tegra234-camera-s56-gmsl2x4-overlay.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
