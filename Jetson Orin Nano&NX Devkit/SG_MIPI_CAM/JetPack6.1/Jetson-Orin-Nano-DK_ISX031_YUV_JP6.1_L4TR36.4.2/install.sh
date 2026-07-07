#!/bin/bash

sudo cp boot/Image /boot/Image
sudo cp dtb/SG3_MIPI_ISX031/tegra234-camera-isx031-mipi-overlay.dtbo /boot/tegra234-camera-isx031-mipi-overlay.dtbo

sudo cp ./ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ./ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/

sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko
