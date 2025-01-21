#!/bin/bash
<<COMMENT
#
# 2024-11-07 Orin NANO V1.0
#
COMMENT

clear
red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG4A-NONX-G2Y-A1 on JetPack-6.1-L4T-36.4"
camera_array=([0]=1920x1080
		[1]=1920x1536
	        [2]=2880x1860
		[3]=3840x2160
		[4]=1280x720)
		

cd $PWD/ko
if [ "`sudo lsmod | grep max96712`" == "" ];then
	sudo insmod max96712.ko
fi

if [ "`sudo lsmod | grep gmsl2`" == "" ];then
	green_print "Press select your frist camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)"
	read key1

	green_print "Press select your second camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)"
	read key2

	green_print "Press select your third camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)"
	read key3

	green_print "Press select your fourth camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)"
	read key4
	
	sudo insmod sgx-yuv-gmsl2.ko GMSLMODE_1=${key1},${key2},${key3},${key4}
fi

green_print "Press select your camera port [0-3]:" 
read port

green_print "Press select your camera resolution:" 
echo 0:${camera_array[0]}
echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}
read index

string=(`echo ${camera_array[index]} | tr 'x' ' '`)
v4l2-ctl --set-ctrl bypass_mode=0,sensor_mode=${index} -d /dev/video${port}

#change to max clk
sudo chmod a+x ../clock_config.sh
sudo ../clock_config.sh

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0

gst-launch-1.0 v4l2src device=/dev/video$port ! "video/x-raw, format=UYVY, width=${string[0]}, height=${string[1]}, framerate=30/1" ! xvimagesink 
