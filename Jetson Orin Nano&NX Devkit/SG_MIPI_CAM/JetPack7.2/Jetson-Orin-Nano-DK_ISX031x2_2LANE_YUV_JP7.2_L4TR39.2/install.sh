#!/bin/bash

#sudo cp boot/Image /boot/Image
sudo cp dtb/SG3_MIPI_ISX031/tegra234-camera-isx031-mipi-2lane-overlay.dtbo /boot/tegra234-camera-isx031-mipi-2lane-overlay.dtbo
sudo cp ./ko/tegra-camera.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ./ko/nvhost-nvcsi.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/video/tegra/host/nvcsi/
