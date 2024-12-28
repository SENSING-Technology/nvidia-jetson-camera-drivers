#!/bin/bash
<<COMMENT
#
# 2024-09-12 Jetson AGX Orin SG8A_ORIN_GMSLX8_V2
#
COMMENT

clear

red_print(){
	echo -e "\e[1;31m$1\e[0m"
}
green_print(){
	echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for AR0144 on SG8A_ORIN_GMSLX8_V2 && Jetson_Linux_R36.3"

green_print "ready bring up camera" 

sudo insmod ko/serializer.ko >/dev/null 2>&1
sudo insmod ko/max9296.ko >/dev/null 2>&1
sudo insmod ko/sgx-yuv-gmsl.ko >/dev/null 2>&1

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0

gst-launch-1.0 v4l2src device=/dev/video$1  ! xvimagesink -ev