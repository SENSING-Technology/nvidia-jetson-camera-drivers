#!/bin/bash

sudo cp boot/Image /boot/Image
sudo cp boot/dtb/tegra234-camera-imx728-gmsl3x8-overlay.dtbo /boot/tegra234-camera-imx728-gmsl3x8-overlay.dtbo
sudo cp drivers/media/platform/tegra/camera/tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp drivers/video/tegra/host/nvcsi/nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max96712.ko
sudo sync
sudo depmod
sudo reboot