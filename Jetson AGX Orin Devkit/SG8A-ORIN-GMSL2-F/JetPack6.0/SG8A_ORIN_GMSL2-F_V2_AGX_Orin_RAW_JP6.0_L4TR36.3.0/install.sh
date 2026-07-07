#!/bin/bash


sudo cp boot/Image /boot/Image

sudo cp dtb/SG2_AR0233C_GMSL2/tegra234-camera-ar0233-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ar0233-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_AR0820C_GMSL2/tegra234-camera-ar0820-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ar0820-gmsl2x8-overlay.dtbo
sudo cp dtb/SG2_IMX390C_GMSL2/tegra234-camera-imx390-gmsl2x8-overlay.dtbo /boot/tegra234-camera-imx390-gmsl2x8-overlay.dtbo
sudo cp dtb/SG2_OX03CC_GMSL2/tegra234-camera-ox03c-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ox03c-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_AR0823C_GMSL2/tegra234-camera-ar0823-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ar0823-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_S5K1H1SB_GMSL2/tegra234-camera-s5k1h1sb-gmsl2x8-overlay.dtbo /boot/tegra234-camera-s5k1h1sb-gmsl2x8-overlay.dtbo
sudo cp dtb/SG2_IMX662C_GMSL2/tegra234-camera-imx662-gmsl2x8-overlay.dtbo /boot/tegra234-camera-imx662-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_IMX728C_GMSL2/tegra234-camera-imx728-gmsl2x8-overlay.dtbo /boot/tegra234-camera-imx728-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_OX08DC_GMSL2/tegra234-camera-ox08d-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ox08d-gmsl2x8-overlay.dtbo
sudo cp dtb/SG8_OX08BC_GMSL2/tegra234-camera-ox08b-gmsl2x8-overlay.dtbo /boot/tegra234-camera-ox08b-gmsl2x8-overlay.dtbo

sudo cp ./ko/tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ./ko/nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/

sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9296.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max9295.ko
sudo rm -rf /lib/modules/5.15.136-tegra/updates/drivers/media/i2c/max96712.ko
