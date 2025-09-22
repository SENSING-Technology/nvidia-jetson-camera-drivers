#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp  dtb/ASTRA_S56/tegra264-camera-s56x4-overlay.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
