#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
#sudo cp dtb/SGCAM_GMSL2/tegra264-camera-sgcam-*-overlay.dtbo /boot/
sudo cp dtb/SG8_IMX715C_G3A/tegra264-camera-imx715x16-overlay.dtbo /boot/
sudo cp dtb/SG12_IMX577C_G3A/tegra264-camera-imx577x16-overlay.dtbo /boot/
sudo cp dtb/SG17_IMX735C_G3A/tegra264-camera-imx735x16-overlay.dtbo /boot/
sudo cp dtb/SGCAM_GMSL2/tegra264-camera-yuv-gmsl2x16-overlay.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
