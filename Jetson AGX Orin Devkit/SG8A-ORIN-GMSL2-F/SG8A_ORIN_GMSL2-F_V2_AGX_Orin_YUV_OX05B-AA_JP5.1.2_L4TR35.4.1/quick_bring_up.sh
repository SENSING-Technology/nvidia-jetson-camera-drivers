#!/bin/bash
<<COMMENT
#
# 2024-9-10 AGX Orin
#
COMMENT

clear
Upgrade_flag=0
backup_flag=0
dtb_name=$(grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | awk -F "_" '/FDT/{print $2}')

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG8A-ORIN-GMSL2 on JetPack-5.1.2-L4T-35.4.1"

camera_array=([1]=sgx-yuv-gmsl2)
key=1

if [ -f $PWD/camera_type ]; then
	var=$(cat camera_type | grep '')
	if [ ${camera_array[key]} == $var ];then
		green_print "Press select your camera port [0-7]:" 
		read port

		green_print "Start bring up camera!"

		cd $PWD/ko

		sudo insmod max9295.ko >/dev/null 2>&1
		sudo insmod max9296.ko >/dev/null 2>&1
		sudo insmod ${camera_array[key]}.ko >/dev/null 2>&1

		v4l2-ctl -d /dev/video${port} -c sensor_mode=5
		gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
	else
		red_print "Error, unknow camera type!!!"
	fi
else
	#backup Image$dtb$libnvscf
	if [ -f /boot/Image ]; then
		sudo cp /boot/Image /boot/Image.backup
		if [ -f /boot/dtb/kernel_${dtb_name} ]; then
			if [ -f /boot/dtb/kernel_${dtb_name}.backup ]; then
				echo "dtb file have backup !!"
			else
				sudo echo "" >> /boot/extlinux/extlinux.conf
				sudo grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | sed 's/primary/backup/g' | sed 's/\.dtb/.dtb.backup/g' | sed 's/Image/Image.backup/g' >> /boot/extlinux/extlinux.conf
			fi
			sudo cp /boot/dtb/kernel_${dtb_name} /boot/dtb/kernel_${dtb_name}.backup
			sync
			green_print "Backup Jetson Orin Image and DTB success!"
			backup_flag=1
		fi
	fi

	#upgrade Image&dtb&libnvscf
	if [ ${backup_flag} -eq 1 ];then
		#upgrade dtb
		if [ ${key} -gt 0 ]; then
			if [ -f $PWD/dtb/${camera_array[key]}/${dtb_name} ]; then
				sudo cp $PWD/dtb/${camera_array[key]}/${dtb_name} /boot/dtb/kernel_${dtb_name}
				green_print "Upgrade ${camera_array[key]} dtb success!"
				Upgrade_flag=1
			else
				red_print "Upgrade failure, cant find ${dtb_name} dtb file in path $PWD/dtb/${camera_array[key]}!"
				Upgrade_flag=-1
			fi
		fi

		#upgrade Image
		if [ ${Upgrade_flag} -eq 1 ];then
			if [ -f $PWD/boot/Image ];then
				sudo cp $PWD/boot/Image /boot/Image
				green_print "Upgrade Image file success, pls reboot system!"
			else
				red_print "Upgrade failure, cant find Image file in package !"
				Upgrade_flag=-1
			fi
		fi

		#recovery
		if [ ${Upgrade_flag} -eq -1 ];then
			sudo cp /boot/Image.backup /boot/Image
			sudo cp /boot/dtb/kernel_${dtb_name}.backup /boot/dtb/kernel_${dtb_name}
			red_print "Upgrade failure, recovery system!"
		else
			sudo echo ${camera_array[key]} > $PWD/camera_type
		fi
	else
		red_print "Backup error, Upgrade package failure!"
	fi
fi
