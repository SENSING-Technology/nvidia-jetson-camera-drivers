#!/bin/bash
<<COMMENT
#
# 2024-12-25
#
COMMENT

clear
red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG6C_ORIN_GMSL2 on JetPack-5.1.2-L4T-35.4.1"
camera_array=([1]=1920x1080
              [2]=2880x1860
			  [3]=3840x2160)


echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}

green_print "Press select your YUV camera resolution:"
read key

green_print "Press select your camera port [0-5]:" 
read port

green_print "Select your trigger mode [0:Internal trigger, 1:External trigger]:" 
read trig_mode

green_print "Start bring up camera!" 

cd $PWD/ko
if [ "`sudo lsmod | grep fzcam`" == "" ];then
	sudo insmod fzcam.ko
	sudo insmod r8152.ko
fi	

string=(`echo ${camera_array[key]} | tr 'x' ' '`)

if [ $trig_mode == 0 ];then
	if [ $key == 1 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=3,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 2 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=3,trig_pin=0x68 -d /dev/video${port}
	elif [ $key == 3 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=3,trig_pin=0x68 -d /dev/video${port}
	fi
else
	if [ $key == 1 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 2 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=1,trig_pin=0x68 -d /dev/video${port}
	elif [ $key == 3 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=0,trig_pin=0x68 -d /dev/video${port}
	fi
fi	

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
