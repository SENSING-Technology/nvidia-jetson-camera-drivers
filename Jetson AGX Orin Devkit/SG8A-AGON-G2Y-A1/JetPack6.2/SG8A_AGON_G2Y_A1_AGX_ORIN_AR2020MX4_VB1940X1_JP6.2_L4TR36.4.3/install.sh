#!/bin/bash

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/capture-ivc.ko /lib/modules/5.15.148-tegra/updates/drivers/platform/tegra/rtcpu/
sudo cp ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/5.15.148-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dtb/AR2020M_SHW5G/tegra234-camera*.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

# backup camera_overrides.isp if exists

if [ -f /var/nvidia/nvcam/settings/camera_overrides.isp ]; then    
    sudo mv /var/nvidia/nvcam/settings/camera_overrides.isp /var/nvidia/nvcam/settings/camera_overrides.isp.bak   
    echo "Backup camera_overrides.isp to camera_overrides.isp.bak"
fi
# upgrade isp
sudo cp ISP_File/ar2020m.isp /var/nvidia/nvcam/settings/cam0_bottomleft.isp
sudo cp ISP_File/ar2020m.isp /var/nvidia/nvcam/settings/cam1_bottomright.isp
sudo cp ISP_File/ar2020m.isp /var/nvidia/nvcam/settings/cam2_centerleft.isp
sudo cp ISP_File/ar2020m.isp /var/nvidia/nvcam/settings/cam3_centerright.isp
sudo cp ISP_File/vb1940.isp /var/nvidia/nvcam/settings/cam6_front.isp

sync
