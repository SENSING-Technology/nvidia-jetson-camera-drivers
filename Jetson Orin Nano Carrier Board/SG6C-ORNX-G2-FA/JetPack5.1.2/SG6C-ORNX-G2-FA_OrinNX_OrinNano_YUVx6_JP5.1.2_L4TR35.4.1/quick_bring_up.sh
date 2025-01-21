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

red_print "This package is use for Sensing SG6C-ORNX-G2-FA on JetPack-5.1.2-L4T-35.4.1"
camera_array=([1]=1920x1080
              [2]=1920x1536
			  [3]=2880x1860
      	      [4]=3840x2160)

cd $PWD/ko
if [ "`sudo lsmod | grep fzcam`" == "" ];then
	green_print "Please select your camera serializer type [0: GMSL2_6G, 1: GMSL2_3G, 2: GMSL1]:"
	read gmslmode
	if [ $gmslmode == 0 ];then
		sudo insmod fzcam.ko mode=0xf300ff7f
	elif [ $gmslmode == 1 ];then
		sudo insmod fzcam.ko mode=0xf310ff7f
	elif [ $gmslmode == 2 ];then 
                sudo insmod fzcam.ko mode=0xf320ff7f
	fi
	sudo insmod r8152.ko
fi	

green_print "Press select your camera port [0-5]:" 
read port

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}

green_print "Press select your YUV camera resolution:"
read key

green_print "Select your trigger mode [0:Internal trigger, 1:External trigger]:" 
read trig_mode

green_print "Start bring up camera!" 

string=(`echo ${camera_array[key]} | tr 'x' ' '`)

if [ $trig_mode == 1 ];then
	if [ $key == 1 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=3,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 2 ];then
                v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,trig_mode=3,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 3 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=3,trig_pin=0x68 -d /dev/video${port}
	elif [ $key == 4 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=3,trig_pin=0x68 -d /dev/video${port}
	fi
else
	if [ $key == 1 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 2 ];then
                v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
	elif [ $key == 3 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=1,trig_pin=0x68 -d /dev/video${port}
	elif [ $key == 4 ];then
		v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=0,trig_pin=0x68 -d /dev/video${port}
	fi
fi	

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
