#!/bin/bash
<<COMMENT
#
# 2022-10-07 AGX Orin V1.0
#
COMMENT

clear
Upgrade_flag=0
backup_flag=0
cam_mode=0  #0: Raw camera, 1:yuv GMSL1 camera, 2:yuv GMSL2 camera
platform=tegra234-p3701-0000-p3737-0000
arr_0=0
arr_1=0
arr_2=0
arr_3=0
red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG8A-ORING-GMSL on JetPack-5.1.2-L4T-35.4.1"



if [ -f $PWD/camera_type ]; then
	cd $PWD/ko
	if [ "`sudo lsmod | grep max9295`" == "" ];then
		sudo insmod max9295.ko
	fi	
	
	if [ "`sudo lsmod | grep max9296`" == "" ];then
		sudo insmod max9296.ko
	fi

	if [ "`sudo lsmod | grep sgx_yuv_gmsl2`" == "" ];then
		green_print "Press select your first group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)"
		read key1

		green_print "Press select your second group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)"
		read key2

		green_print "Press select your third group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)"
		read key3

		green_print "Press select your fourth group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)"
		read key4
		sudo insmod sgx-yuv-gmsl2.ko gmsl_mode=$key1,$key2,$key3,$key4
	fi
	
	green_print "Press select your yuv camera type:" 
	echo 0:SG2-IMX390C-5200-GMSL2
	echo 1:SG2-AR0233C-5200-G2A
	echo 2:SG2-OX03CC-5200-GMSL2
	echo 3:SG3-ISX031C-GMSL2
	echo 4:SG2-OX03CC-5200-G2F
	echo 5:SG3S-ISX031C-GMSL2F
	echo 6:SG3S-OX03JC-G2F
	echo 7:SG5-IMX490C-5300-GMSL2
	echo 8:SG8S-AR0820C-5300-G2A
	echo 9:SG8-AR0820C-5300-G2A
	echo 10:SG8-OX08BC-5300-G2A
	echo 11:SG8-OX08BC-5300-GMSL2
	echo 12:OMSBDAAN-AA
	echo 13:OMSBDAAN-AB
	echo 14:DMSBBFAN
	echo 15:SG1-OX01F10C-GMSL
	echo 16:SG1S-OX01F10C-G1G-Hxxx
	echo 17:SG2-AR0231C-0202-GMSL-1080P	
	read yuv_cam_type
			
	green_print "Press select your camera port [0-7]:" 
	read port

	if [ ${yuv_cam_type} == 0 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 1 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 2 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007	
	elif [ ${yuv_cam_type} == 3 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 4 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 5 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 6 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 7 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_pin=0xffff0008,trig_mode=1
	elif [ ${yuv_cam_type} == 8 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 9 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_pin=0xffff0008
	elif [ ${yuv_cam_type} == 10 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 11 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_pin=0xffff0008			
	elif [ ${yuv_cam_type} == 12 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=5,trig_pin=0xffff0007,trig_mode=3
	elif [ ${yuv_cam_type} == 13 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_pin=0xffff0007,trig_mode=3
	elif [ ${yuv_cam_type} == 14 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=6,trig_pin=0xffff0007
	elif [ ${yuv_cam_type} == 15 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=8	
	elif [ ${yuv_cam_type} == 16 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=9		
	elif [ ${yuv_cam_type} == 17 ];then
		v4l2-ctl -d /dev/video${port} -c sensor_mode=0	
	fi
	
	if [ ${yuv_cam_type} == 15 ];then
		gst-launch-1.0 v4l2src device=/dev/video${port} ! video/x-raw,format=UYVY,width=1280,height=720,framerate=30/1 ! xvimagesink -ev	
	elif [ ${yuv_cam_type} == 16 ];then
		gst-launch-1.0 v4l2src device=/dev/video${port} ! video/x-raw,format=UYVY,width=1280,height=960,framerate=30/1 ! xvimagesink -ev
	else
		gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev
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
		if [ -f $PWD/dtb/sgx-yuv-gmsl2/${platform}.dtb ]; then
			sudo cp $PWD/dtb/sgx-yuv-gmsl2/${platform}.dtb /boot/dtb/kernel_${platform}.dtb
			green_print "Upgrade sgx-yuv-gmsl2 dtb success!"
			Upgrade_flag=1
		else
			red_print "Upgrade failure, cant find sgx-yuv-gmsl2 dtb file in package !"
			Upgrade_flag=-1
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
			sudo echo sgx-yuv-gmsl2 > $PWD/camera_type
		fi
	else
		red_print "Backup error, Upgrade package failure!"
	fi
fi
