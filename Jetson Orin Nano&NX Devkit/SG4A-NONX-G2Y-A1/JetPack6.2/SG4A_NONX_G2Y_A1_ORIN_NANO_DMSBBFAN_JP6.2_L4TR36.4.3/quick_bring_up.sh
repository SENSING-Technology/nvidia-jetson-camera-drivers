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

# Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

red_print "This package is use for Sensing SG4A-NONX-G2Y-A1 on JetPack-6.2-L4T-36.4.3"

		
cd $PWD/ko
if [ "`sudo lsmod | grep max96712`" == "" ];then
	sudo insmod max96712.ko debug_on=1
fi

if [ "`sudo lsmod | grep gmsl2`" == "" ];then
	
	sudo insmod sgx-yuv-gmsl2.ko GMSLMODE_1=2,2,2,2 
fi

green_print "Press select your camera port [0-3]:" 
read port



string=(`echo ${camera_array[index]} | tr 'x' ' '`)
v4l2-ctl --set-ctrl bypass_mode=0,sensor_mode=6 -d /dev/video${port}

#change to max clk
sudo chmod a+x ../clock_config.sh
sudo ../clock_config.sh

#if you run this script on remote teminal,pls enable this commond
export DISPLAY=:0

gst-launch-1.0 v4l2src device=/dev/video$port ! "video/x-raw, format=UYVY, width=1600, height=1300, framerate=30/1" ! xvimagesink 
