#!/bin/bash

# Install Device Tree Overlay
cd dts
cpp -I . -nostdinc -undef -x assembler-with-cpp tegra234-camera-sipl-camera-overlay.dts | \
  dtc -@ -I dts -O dtb -o tegra234-camera-sipl-camera-overlay.dtbo -
sudo cp tegra234-camera-sipl-camera-overlay.dtbo /boot/
cd ..

# Install SIPL driver
sudo rm -rf /usr/lib/nvsipl_drv/*
sudo cp -arf driver/libnvuddf* /usr/lib/nvsipl_drv/
sudo cp -arf driver/libnvsipl* /usr/lib/nvsipl_drv/
sudo cp -arf driver/libnvcamerahal.so /usr/lib/aarch64-linux-gnu/nvidia/libnvcamerahal.so

sudo cp nvsipl_camera /usr/sbin/
sudo cp nvsipl_query /usr/sbin/
sudo chmod +x /usr/sbin/nvsipl_camera
sudo chmod +x /usr/sbin/nvsipl_query

# Install SIPL ISP files
sudo cp nito/* /var/nvidia/nvcam/settings/sipl/