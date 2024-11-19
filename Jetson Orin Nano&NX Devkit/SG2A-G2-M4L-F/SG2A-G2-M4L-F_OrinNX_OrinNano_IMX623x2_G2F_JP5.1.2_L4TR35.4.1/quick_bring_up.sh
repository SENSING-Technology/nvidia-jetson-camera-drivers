#!/bin/bash
<<COMMENT
#
# 2024-04-28 Jetson Orin nano SG2A-G2-M4L-F V1.0
#
COMMENT

clear
Upgrade_flag=0
backup_flag=0
cam_mode=0  #0: Raw camera, 1:yuv GMSL1 camera, 2:yuv GMSL2 camera
dtb_name=$(grep -A 5 "LABEL primary" /boot/extlinux/extlinux.conf | awk -F "_" '/FDT/{print $2}')

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for SG2A-G2-M4L-F Jetson_Linux_R35.4.1"

camera_array=([1]=sgx-yuv-gmsl1
			  [2]=sgx-yuv-gmsl2
			  [3]=sg3s-imx623c-gmsl2f
			  [4]=sg8-imx728c-g2g
               )

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}

green_print "Press select your camera type:" 
read key

if [ -f $PWD/camera_type ]; then
	var=$(cat camera_type | grep '')
	if [ ${camera_array[key]} == $var ];then
		#for yuv gw5200&5300 camera
		if [ ${camera_array[key]} == sgx-yuv-gmsl2  ];then
			green_print "Press select your yuv camera type:" 
			echo 0:SG2-IMX390C-5200-GMSL2
			echo 1:SG2-AR0233-5300-GMSL2
			echo 2:SG3-ISX031C-GMSL2
			read yuv_cam_type
			cam_mode=2
		elif [ ${camera_array[key]} == sgx-yuv-gmsl1  ];then
			echo 0:SG1-OX01F10C-GMSL
			echo 1:SG2-AR0231C-0202-GMSL
			read yuv_cam_type
			cam_mode=1
		fi

		green_print "Press select your camera port [0-1]:" 
		read port
	
		green_print "ready bring up camera" 
		cd $PWD/ko
		if [ "`sudo lsmod | grep max9295`" == "" ];then
			if [ ${cam_mode} -eq 1 ];then
				sudo insmod max9295.ko i2c_reg8=1
			else
				sudo insmod max9295.ko
			fi
		fi	
		
		if [ "`sudo lsmod | grep max9296`" == "" ];then
			sudo insmod max9296.ko
		fi

		if [ ${cam_mode} -eq 2 ];then
			if [ ${yuv_cam_type} -eq 3 -o ${yuv_cam_type} -eq 4 ];then
				sudo insmod ${camera_array[key]}.ko enable_3G=1,1,1,1
			else
				sudo insmod ${camera_array[key]}.ko
			fi
		else
			sudo insmod ${camera_array[key]}.ko
		fi
		
		#if you run this script on remote teminal,pls enable this commond
		#export DISPLAY=:0  
		
		if [ ${cam_mode} -eq 1 ];then #For yuv_gmsl1 mode
			if [ ${yuv_cam_type} == 0 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 1 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=1
			fi
			
			gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
		elif [ ${cam_mode} -eq 2 ];then  #For yuv_gmsl2 mode
			if [ ${yuv_cam_type} == 0 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 1 ];then
				v4l2-ctl -d /dev/video${port} -c sensor_mode=0
			elif [ ${yuv_cam_type} == 2 ];then
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
	#backup Image$dtb$libnvscf
	if [ -f /boot/Image ]; then
		sudo cp /boot/Image /boot/Image.backup
		if [ -f /boot/dtb/kernel_${dtb_name} ]; then
			if [ -f /boot/dtb/kernel_${dtb_name}.backup ]; then
				echo "dtb file have backup !!"
			else
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
