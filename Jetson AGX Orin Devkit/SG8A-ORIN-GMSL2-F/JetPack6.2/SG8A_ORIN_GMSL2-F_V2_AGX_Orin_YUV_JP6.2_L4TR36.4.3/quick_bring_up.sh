#!/bin/bash
<<COMMENT
#
# 2024-10-11 AGX Orin
#
COMMENT

clear

red_print(){
        echo -e "\e[1;31m$1\e[0m"
}
green_print(){
        echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for AGX Orin & Jetson_Linux_R36.4.3"

if [ "`sudo lsmod | grep sgx_yuv_gmsl2`" == "" ];then
        green_print "Press select your cam0 cam1 type: (GMSL2/6G=0, GMSL2/3G=1)"
        read key1

        green_print "Press select your cam2 cam3 type: (GMSL2/6G=0, GMSL2/3G=1)"
        read key2

        green_print "Press select your cam4 cam5 type: (GMSL2/6G=0, GMSL2/3G=1)"
        read key3

        green_print "Press select your cam6 cam7 type: (GMSL2/6G=0, GMSL2/3G=1)"
        read key4
fi

cd $PWD/ko
if [ "`sudo lsmod | grep max9295`" == "" ];then
	sudo insmod max9295.ko
fi	

if [ "`sudo lsmod | grep max9296`" == "" ];then
	sudo insmod max9296.ko
fi

if [ "`sudo lsmod | grep sgx-yuv-gmsl2`" == "" ];then
	sudo insmod sgx-yuv-gmsl2.ko enable_3G=${key1},${key2},${key3},${key4}
else
	sudo insmod sgx-yuv-gmsl2.ko
fi

green_print "Select the camera type:"
echo 0:SG2-IMX390C-5200-GMSL2
echo 1:SG2-AR0233-5300-GMSL2
echo 2:SG2-OX03CC-5200-GMSL2
echo 3:SG3S-ISX031C-GMSL2
echo 4:SG2-OX03CC-5200-G2F
echo 5:SG3S-ISX031C-GMSL2F
echo 6:SG3S-OX03JC-G2F
echo 7:SG5-IMX490C-5300-GMSL2
echo 8:SG8S-AR0820C-5300-G2A
echo 9:SG8-AR0820C-5300-GMSL2
echo 10:SG8-OX08BC-5300-G2A
echo 11:SG8-OX08BC-5300-GMSL2
echo 12:OMSBDAAN-AA
echo 13:OMSBDAAN-AB
echo 14:DMSBBFAN
read yuv_cam_type
cam_mode=2

green_print "Select the camera port to light up[0-7]:"
read port

green_print "Start bring up camera!" 

#if you run this script on remote teminal,pls enable this commond
export DISPLAY=:0

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
fi

gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev
