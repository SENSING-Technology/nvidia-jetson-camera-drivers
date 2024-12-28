#!/bin/bash

dtb_name=$(grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | awk -F "_" '/FDT/{print $2}')

grep -q "Image.sensing_bk" /boot/extlinux/extlinux.conf
if [ $? -ne 0 ]; then
	sudo cp /boot/Image /boot/Image.sensing_bk
	sudo echo "" >> /boot/extlinux/extlinux.conf
	grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | sed 's/primary/sensing_bk/g' | sed 's/Image/Image.sensing_bk/g' >> /boot/extlinux/extlinux.conf

	sudo cp dtb/sg1_tc358748_gmsl2/${dtb_name} /boot/dtb/kernel_${dtb_name}
	sudo cp boot/Image /boot/
fi