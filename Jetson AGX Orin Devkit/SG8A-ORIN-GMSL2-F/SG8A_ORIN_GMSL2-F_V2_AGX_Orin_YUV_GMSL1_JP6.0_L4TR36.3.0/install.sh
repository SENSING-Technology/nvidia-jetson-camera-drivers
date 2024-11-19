#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9296.ko

# add dtbo
sudo cp dtb/SGX_YUV_GMSL1/tegra234-camera-yuv-gmsl1x8-overlay.dtbo /boot/

# upgrade Image
# sudo cp boot/Image /boot/Image

sudo depmod
sync

echo "Install done"