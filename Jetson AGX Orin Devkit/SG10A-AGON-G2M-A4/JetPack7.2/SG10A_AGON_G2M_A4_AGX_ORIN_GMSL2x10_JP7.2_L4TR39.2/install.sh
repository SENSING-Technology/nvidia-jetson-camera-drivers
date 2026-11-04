#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-1021-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/6.8.12-1021-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/6.8.12-1021-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dts/tegra234-camera-sgcamx10-overlay.dtbo /boot/
# sudo cp dtb/S56C_SHW5G/tegra234-camera-s56-gmsl2x5-overlay.dtbo /boot/
# sudo cp dtb/S56C_SHW5G/tegra234-camera-shw5g-gmsl2x10-overlay.dtbo /boot/
# sudo cp dtb/SHW3G/tegra234-camera-shw3g-gmsl2x10-overlay.dtbo /boot/
# upgrade Image
sudo cp boot/Image /boot/Image
# add nito
sudo cp ISP/*.nito /var/nvidia/nvcam/settings/

sync
