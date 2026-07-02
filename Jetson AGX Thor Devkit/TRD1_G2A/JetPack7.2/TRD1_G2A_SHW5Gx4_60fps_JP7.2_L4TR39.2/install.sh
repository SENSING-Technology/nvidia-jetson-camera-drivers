#!/bin/bash


# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-1021-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-1021-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dtb/SHW5G/tegra264-camera-shw5gx4-overlay.dtbo /boot/

#add nito
sudo cp isp/shw5g.nito /var/nvidia/nvcam/settings/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
