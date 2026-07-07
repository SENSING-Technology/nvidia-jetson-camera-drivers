#!/bin/bash

sudo cp boot/Image /boot/Image
sudo cp dtb/SG17_IMX735C_GMSL3/tegra234-camera-imx735-gmsl3x8-overlay.dtbo /boot/tegra234-camera-imx735-gmsl3x8-overlay.dtbo
sudo cp ko/tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max96712.ko
sudo sync
sudo depmod