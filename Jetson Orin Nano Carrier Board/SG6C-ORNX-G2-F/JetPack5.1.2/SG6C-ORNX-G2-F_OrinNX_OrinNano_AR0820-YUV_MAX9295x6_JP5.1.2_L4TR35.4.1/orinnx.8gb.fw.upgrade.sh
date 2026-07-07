#!/bin/bash

clear

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print 'This package is JetPack5.1.2-R35.4.1, check it before running this shell'
cat /etc/nv_tegra_release

green_print 'Press Enter to continue'
read key

sudo -S su << EOF
nvidia
EOF

echo ''
green_print 'Upgrade ETH/SPI/WIFI modules'
sudo cp $PWD/ko/mcp251xfd.ko /lib/modules/$(uname -r)/kernel/drivers/net/can/spi/
sudo cp $PWD/ko/rtl8822cu.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtlwifi/
echo "rtl8822cu" | sudo tee /etc/modules-load.d/rtl8822cu.conf
sudo modprobe cfg80211
sudo insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8822cu.ko
sudo depmod -a
sudo modprobe rtl8822cu

sudo cp $PWD/ko/usb_wwan.ko /lib/modules/$(uname -r)/kernel/drivers/usb/serial/
sudo cp $PWD/ko/option.ko /lib/modules/$(uname -r)/kernel/drivers/usb/serial/
sudo cp $PWD/ko/qmi_wwan_q.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/
sudo modprobe cdc-wdm
sudo insmod /lib/modules/$(uname -r)/kernel/drivers/net/usb/qmi_wwan_q.ko
sudo depmod -a
sudo modprobe qmi_wwan_q

green_print 'Upgrade Camera modules'
sudo cp $PWD/ko/fzcam.ko /lib/modules/$(uname -r)/kernel/drivers/media/i2c/
sudo insmod /lib/modules/$(uname -r)/kernel/drivers/media/i2c/fzcam.ko
sudo depmod -a
sudo modprobe fzcam

green_print 'Backup and upgrade Image and DTB'
echo '' 
sudo cp /boot/Image /boot/Image.backup
sudo cp /boot/dtb/kernel_tegra234-p3767-0001-p3768-0000-a0.dtb /boot/dtb/kernel_tegra234-p3767-0001-p3768-0000-a0.dtb.backup
sudo cp $PWD/kernel/Image /boot/Image
sudo cp $PWD/kernel/dtb/tegra234-p3767-0001-p3768-0000-a0.dtb /boot/dtb/kernel_tegra234-p3767-0001-p3768-0000-a0.dtb
sudo cp $PWD/extlinux.orinnx.8gb.conf $PWD/extlinux.conf.backup
newvalue=`cat /boot/extlinux/extlinux.conf | grep -m1 root=PARTUUID=`
sed -i "s|      APPEND|$newvalue|g" $PWD/extlinux.conf.backup
sync
sudo cp $PWD/extlinux.conf.backup /boot/extlinux/extlinux.conf
sync

green_print 'Upgrade success, please press Enter to reboot'
read key

sudo reboot


