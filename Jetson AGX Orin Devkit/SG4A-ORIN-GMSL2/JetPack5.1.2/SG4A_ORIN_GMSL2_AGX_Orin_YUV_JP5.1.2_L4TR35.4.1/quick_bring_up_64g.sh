#!/bin/bash
<<COMMENT
#
# 2022-10-07 AGX Orin V1.0
#
COMMENT


# 初始化变量
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BOOT_DIR="/boot"
DTB_DIR="${BOOT_DIR}/dtb"

clear
Upgrade_flag=0
backup_flag=0
cam_mode=0  #0: Raw camera, 1:yuv GMSL1 camera, 2:yuv GMSL2 camera
platform=tegra234-p3701-0005-p3737-0000
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

red_print "This package is use for Sensing SG4A-ORING-GMSL on JetPack-5.1.2-L4T-35.4.1"
camera_array=(
	      [1]=sgx-yuv-gmsl2
              [2]=sg2-ox03c-gmsl2
	      [3]=sg2-imx390c-gmsl2
	      [4]=sg8-ar0820c-gmsl2)

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}

green_print "Press select your camera type:"
read key

if [ -f "${SCRIPT_DIR}/camera_type" ]; then
    var=$(cat "${SCRIPT_DIR}/camera_type")
    if [ "${camera_array[key]}" == "$var" ]; then
		#for yuv gw5200&5300 camera
		if [ ${camera_array[key]} == sgx-yuv-gmsl2  ];then
			green_print "Press select your yuv camera type:" 
			echo 0:SG2-IMX390C-5200-GMSL2
			echo 1:SG2-AR0233-5300-GMSL2
			echo 2:SG3-ISX031C-GMSL2
			echo 3:SG4-IMX490C-5300-GMSL2
			echo 4:SG8-AR0820C-5300-GMSL2
			echo 5:SG8-OX08BC-5300-GMSL2	
			echo 6:SG2-OX03CC-5200-GMSL2F
			echo 7:SG3-ISX031C-GMSL2F
			read yuv_cam_type
			cam_mode=1
		fi
	
		green_print "Press select your camera port [0-15]:" 
		read port
		
		green_print "Start bring up camera!" 
		
		cd $PWD/ko
		if [ "`sudo lsmod | grep max96712`" == "" ];then
			sudo insmod max96712.ko
		fi

		if [ "${cam_mode}" -eq 1 ] && { [ "${yuv_cam_type}" = 6 ] || [ "${yuv_cam_type}" = 7 ]; }; then
		    sudo insmod "${camera_array[key]}.ko" enable_3G_0=1,1,1,1 enable_3G_1=1,1,1,1 enable_3G_2=1,1,1,1 enable_3G_3=1,1,1,1
		else
		    sudo insmod "${camera_array[key]}.ko"
		fi
	
		#if you run this script on remote teminal,pls enable this commond
		# export DISPLAY=:0  
		
		if [ ${cam_mode} -eq 1 ];then  #For yuv_gmsl2 mode
			if [ ${yuv_cam_type} == 0 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 1 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 2 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=1
			elif [ ${yuv_cam_type} == 3 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=2
			elif [ ${yuv_cam_type} == 4 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=3
			elif [ ${yuv_cam_type} == 5 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=3
			elif [ ${yuv_cam_type} == 6 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 7 ];then
                                v4l2-ctl -d /dev/video${port} -c sensor_mode=1
			fi
			
			gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
		else #for raw camera
			nvgstcapture-1.0 --sensor-id=${port}
		fi
	else
		sudo cp $PWD/dtb/${camera_array[key]}/${platform}.dtb /boot/dtb/kernel_${platform}.dtb
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

	if [ -f /lib/modules/5.10.120-tegra/kernel/drivers/media/i2c/max96712.ko ]; then
		sudo rm -rf /lib/modules/5.10.120-tegra/kernel/drivers/media/i2c/max96712.ko
		sudo depmod
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
				sudo cp $PWD/boot/extlinux/extlinux_64g.conf /boot/extlinux/extlinux.conf
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

