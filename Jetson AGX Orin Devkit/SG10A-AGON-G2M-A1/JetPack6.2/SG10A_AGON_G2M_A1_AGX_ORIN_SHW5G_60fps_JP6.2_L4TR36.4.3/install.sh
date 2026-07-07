#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/capture-ivc.ko /lib/modules/5.15.148-tegra/updates/drivers/platform/tegra/rtcpu/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dtb/SHW5G/tegra234-camera*.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image


sync
