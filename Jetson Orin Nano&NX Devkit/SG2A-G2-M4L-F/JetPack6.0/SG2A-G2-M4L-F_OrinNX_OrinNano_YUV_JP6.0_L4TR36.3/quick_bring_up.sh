#!/bin/bash
<<COMMENT
#
# 2024-09-11 Jetson Orin Nx/Nano SG2A-G2-M4L-F
#
COMMENT

clear

red_print(){
	echo -e "\e[1;31m$1\e[0m"
}
green_print(){
	echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for SG2A-G2-M4L-F Jetson_Linux_R36.3"

green_print "Press select your yuv camera type:" 
echo 0:SG2-IMX390C-5200-GMSL2
echo 1:SG2-AR0233C-5200-GMSL2
echo 2:SG3-ISX031C-GMSL2
echo 3:SG3S-ISX031C-GMSL2F
echo 4:SG3S-OX03JC-GMSL2F
echo 5:SG5-IMX490C-5300-GMSL2
echo 6:SG8S-AR0820C-5300-GMSL2
read yuv_cam_type

green_print "Press select your camera port [0-1]:" 
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
	sudo insmod sgx-yuv-gmsl2.ko enable_3G=1,1,1,1
else
	sudo insmod sgx-yuv-gmsl2.ko
fi

#if you run this script on remote teminal,pls enable this commond
export DISPLAY=:0

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

gst-launch-1.0 v4l2src device=/dev/video${port} ! videoconvert ! ximagesink