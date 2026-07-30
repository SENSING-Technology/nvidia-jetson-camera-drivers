#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-1021-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
# sudo cp dtb/SGCAM_GMSL2/tegra264-camera-sgcam-*-overlay.dtbo /boot/
sudo cp dts/tegra264-camera-sgcamx8-overlay.dtbo /boot/
# sudo cp dtb/S56/tegra264-camera-s56*-overlay.dtbo /boot/
# upgrade Image
sudo cp boot/Image /boot/Image
sudo cp isp/*.nito /var/nvidia/nvcam/settings/
sync
