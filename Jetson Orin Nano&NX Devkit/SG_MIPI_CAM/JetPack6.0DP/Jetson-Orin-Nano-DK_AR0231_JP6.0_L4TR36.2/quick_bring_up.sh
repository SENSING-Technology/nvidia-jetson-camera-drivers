#!/bin/bash
<<COMMENT
#
# 2023-08-21 Jetson Orin nano V1.0
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

red_print "This package is use for Jetson_Linux_R36.2.0"

command_array=([1]=argus_camera
		[2]=nvgstcapture-1.0
		)

camera_array=([1]=sg2-mipi-ar0231
               )

echo 1:${camera_array[1]}

green_print "Press select your camera type:" 
read key

if [ -f $PWD/camera_type ]; then
	green_print "Press select your camera port [0-1]:" 
	read port
	
	green_print "ready bring up camera" 
	var=$(cat camera_type | grep '')
	if [ ${camera_array[key]} = $var ];then
		cd $PWD/ko
		sudo insmod ${camera_array[key]}.ko
		#export DISPLAY=:0
		green_print "Use the following command to light the camera!"
		echo 1:${command_array[1]} -d ${port}
		#echo 2:${command_array[2]} --sensor-id=${port} --sensor-mode=0

	else
		sudo cp $PWD/dtb/${camera_array[key]}/${dtb_name} /boot/dtb/kernel_${dtb_name}
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
