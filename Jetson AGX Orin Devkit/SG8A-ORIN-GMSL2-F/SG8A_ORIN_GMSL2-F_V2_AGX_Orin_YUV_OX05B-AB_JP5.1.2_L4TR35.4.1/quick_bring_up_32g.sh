#!/bin/bash
<<COMMENT
#
# 2024-03-07 Jetson AGX Orin V1.0
#
COMMENT

clear
Upgrade_flag=0
backup_flag=0
platform=tegra234-p3701-0000-p3737-0000

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG8A-ORING-GMSL on JetPack-5.1.2-L4T-35.4.1"

camera_array=([1]=sgx-yuv-gmsl2
               )

echo 1:${camera_array[1]}

green_print "Press select your camera type:" 
read key

if [ -f $PWD/camera_type ]; then
	green_print "Press select your camera port [0 2 4 6]:" 
	read port
	declare -i port1=${port}+1

	green_print "ready bring up camera" 
	var=$(cat camera_type | grep '')
	if [ ${camera_array[key]} = $var ];then
		cd $PWD/ko
        sudo insmod max9295.ko
        sudo insmod max9296.ko
		sudo insmod ${camera_array[key]}.ko
		#export DISPLAY=:0
		green_print "light the camera!"
		v4l2-ctl -d /dev/video${port} -c sensor_mode=4
        v4l2-ctl -d /dev/video${port1} -c sensor_mode=4

        gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev &
        sleep 1
		gst-launch-1.0 v4l2src device=/dev/video${port1} ! xvimagesink -ev &


	else
		sudo cp $PWD/dtb/${camera_array[key]}/${platform} /boot/dtb/kernel_${platform}
		sudo echo ${camera_array[key]} > $PWD/camera_type
		red_print "camera type change to ${camera_array[key]}, pls reboot system!"
	fi
else
	#backup Image$dtb
	if [ -f /boot/Image ]; then
		sudo cp /boot/Image /boot/Image.backup
		sudo cp /boot/extlinux/extlinux.conf  /boot/extlinux/extlinux.conf_bak
		if [ -f /boot/dtb/kernel_${platform}.dtb ]; then
			sudo cp /boot/dtb/kernel_${platform}.dtb /boot/dtb/kernel_${platform}.dtb.backup
			green_print "Backup Jetson Orin Image and DTB success!"
			backup_flag=1
		fi
	fi

	#upgrade Image&dtb
	if [ ${backup_flag} -eq 1 ];then
		#upgrade dtb
		if [ ${key} -gt 0 ]; then
			if [ -f $PWD/dtb/${camera_array[key]}/${platform}.dtb ]; then
				sudo cp $PWD/dtb/${camera_array[key]}/${platform}.dtb /boot/dtb/kernel_${platform}.dtb
				green_print "Upgrade ${camera_array[key]} dtb success!"
				Upgrade_flag=1
			else
				red_print "Upgrade failure, cant find ${camera_array[key]} dtb file in package !"
				Upgrade_flag=-1
			fi
		fi
		
		#upgrade Image
		if [ ${Upgrade_flag} -eq 1 ];then
			if [ -f $PWD/boot/Image ];then
				sudo cp $PWD/boot/Image /boot/Image
				sudo cp $PWD/boot/extlinux/extlinux_32g.conf  /boot/extlinux/extlinux.conf
				green_print "Upgrade Image file success, pls reboot system!"
			else
				red_print "Upgrade failure, cant find Image file in package !"
				Upgrade_flag=-1
			fi
		fi
		
		#recovery
		if [ ${Upgrade_flag} -eq -1 ];then
			sudo cp /boot/Image.backup /boot/Image
			sudo cp /boot/dtb/kernel_${platform}.dtb.backup /boot/dtb/kernel_${platform}.dtb
			sudo cp /boot/extlinux/extlinux.conf_bak /boot/extlinux/extlinux.conf  
			red_print "Upgrade failure, recovery system!"
		else
			sudo echo ${camera_array[key]} > $PWD/camera_type
		fi
	else
		red_print "Backup error, Upgrade package failure!"
	fi
fi
