#!/bin/bash


sudo cp boot/Image /boot/Image
sudo cp dtb/sgx-yuv-gmsl/tegra234-camera-yuv-gmslx2-overlay.dtbo /boot/tegra234-camera-yuv-gmslx2-overlay.dtbo

sudo cp ./ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ./ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/

sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko
