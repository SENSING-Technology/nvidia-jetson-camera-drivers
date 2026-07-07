#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dtb/SGX_SDV11NM1_SHW3G/tegra234-camera-sdv11nm1x1-shw3gx4-gmsl2x8-overlay.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
