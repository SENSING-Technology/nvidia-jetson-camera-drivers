#!/bin/bash
<<COMMENT
#
# 2024-09-09 Jetson Orin Nx/Nano SG2A-G2-M4L-F
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

red_print "This package is use for SG2A-G2-M4L-F Jetson_Linux_R35.4.1"

camera_array=([1]=sgx-yuv-gmsl2)
key=1

if [ -f $PWD/camera_type ]; then
	var=$(cat camera_type | grep '')
	if [ ${camera_array[key]} == $var ];then
		#for yuv gw5200&5300 camera
		if [ ${camera_array[key]} == sgx-yuv-gmsl2 ];then
			green_print "Press select your yuv camera type:" 
			echo 0:SG2-IMX390C-5200-GMSL2
			echo 1:SG2-AR0233C-5200-GMSL2
			echo 2:SG3-ISX031C-GMSL2
			echo 3:SG3S-ISX031C-GMSL2F
			echo 4:SG3S-OX03JC-GMSL2F
			echo 5:SG5-IMX490C-5300-GMSL2
			echo 6:SG8S-AR0820C-5300-GMSL2
			read yuv_cam_type
		fi

		green_print "Press select your camera port [2-3]:" 
		read port
	
		green_print "ready bring up camera" 
		cd $PWD/ko
		if [ "`sudo lsmod | grep max9295`" == "" ];then
			sudo insmod max9295.ko
		fi
		
		if [ "`sudo lsmod | grep max9296`" == "" ];then
			sudo insmod max9296.ko
		fi

		if [ ${yuv_cam_type} -eq 3 -o ${yuv_cam_type} -eq 4 ];then
			sudo insmod ${camera_array[key]}.ko enable_3G=1,1,1,1
		else
			sudo insmod ${camera_array[key]}.ko
		fi

		#if you run this script on remote teminal,pls enable this commond
		#export DISPLAY=:0

		if [ ${yuv_cam_type} == 0 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
		elif [ ${yuv_cam_type} == 1 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
		elif [ ${yuv_cam_type} == 2 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
		elif [ ${yuv_cam_type} == 3 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
		elif [ ${yuv_cam_type} == 4 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
		elif [ ${yuv_cam_type} == 5 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=1,trig_pin=0xffff0008
		elif [ ${yuv_cam_type} == 6 ];then
			v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_pin=0xffff0007
		fi

		gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
	else
		sudo cp $PWD/dtb/${camera_array[key]}/${platform}.dtb /boot/dtb/kernel_${platform}.dtb
		sudo echo ${camera_array[key]} > $PWD/camera_type
		red_print "camera type change to ${camera_array[key]}, pls reboot system!"
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
				grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | sed 's/primary/backup/g' | sed 's/\.dtb/.dtb.backup/g' | sed 's/Image/Image.backup/g' >> /boot/extlinux/extlinux.conf
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
