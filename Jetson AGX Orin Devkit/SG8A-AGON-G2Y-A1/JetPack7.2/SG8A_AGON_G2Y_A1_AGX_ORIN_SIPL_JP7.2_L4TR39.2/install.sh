#!/bin/bash
#Install dtb
sudo cp dts/tegra234-camera-sipl-camera-overlay.dtbo /boot/

# Install SIPL driver
sudo rm -rf /usr/lib/nvsipl_drv/*
sudo cp -arf driver/libnvuddf* /usr/lib/nvsipl_drv/
sudo cp -arf driver/libnvsipl* /usr/lib/nvsipl_drv/
sudo cp -arf driver/libnvcamerahal.so /usr/lib/aarch64-linux-gnu/nvidia/libnvcamerahal.so

sudo cp nvsipl_camera /usr/sbin/
sudo cp nvsipl_query /usr/sbin/
sudo chmod +x /usr/sbin/nvsipl_camera
sudo chmod +x /usr/sbin/nvsipl_query

# # Install SIPL ISP files
sudo cp nito/* /var/nvidia/nvcam/settings/sipl/