#!/bin/bash

sudo cp boot/Image /boot/Image

sudo cp dtb/SGX_G2XX_ISX031/tegra234-p3737-0000+p3701-0000-nv.dtb /boot/dtb/kernel_tegra234-p3737-0000+p3701-0000-nv.dtb
sudo cp dtb/SGX_G2XX_ISX031/tegra234-p3737-0000+p3701-0005-nv.dtb /boot/dtb/kernel_tegra234-p3737-0000+p3701-0005-nv.dtb
sudo cp dtb/SGX_G2XX_ISX031/tegra234-camera-g2xx-isx031-overlay.dtbo /boot/tegra234-camera-g2xx-isx031-overlay.dtbo

sudo cp ./ko/tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ./ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/

sudo cp ./ko/capture-ivc.ko /lib/modules/5.15.136-tegra/updates/drivers/platform/tegra/rtcpu/

sudo cp ./ko/videodev.ko /lib/modules/5.15.136-tegra/kernel/drivers/media/v4l2-core/
sudo cp ./ko/uvcvideo.ko /lib/modules/5.15.136-tegra/kernel/drivers/media/usb/uvc/

sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max96712.ko

sync


