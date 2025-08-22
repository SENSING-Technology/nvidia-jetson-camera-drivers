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

# Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils busybox
fi


red_print "This package is use for Sensing SG10A-AGON-G2M-A1-AGX-ORIN_SHW3H&SHF3L_JP6.2_L4TR36.4.3"
camera_array=([1]=shf3l
              [2]=shw3h)

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}

if [ "`sudo lsmod | grep shw3h_shf3l`" == "" ];then
	sudo busybox devmem 0x02448020 w 0x1008  #PAC.04 ouptput mode for poc_ctrl
	sudo busybox devmem 0x0c302028 w 0x0009  #PCC.02 ouptput mode for trigger
	sudo insmod ./ko/pwm-gpio.ko
	sudo insmod ./ko/shw3h-shf3l.ko
fi	

green_print "Press select your YUV camera:"
read key

green_print "Please select your camera resolution:"
sensor_mode=([1]=1280x1280
             [2]=1920x1536)

echo 1:${sensor_mode[1]}
echo 2:${sensor_mode[2]}

read sensormode

green_print "Press select your camera port [0-9]:" 
read port


green_print "Select your trigger mode [0:Internal trigger, 1:External trigger]:" 
read trig_mode

green_print "Start bring up camera!" 

string=(`echo ${sensor_mode[sensormode]} | tr 'x' ' '`)

if [ $trig_mode == 1 ];then

	if [ $sensormode == 1 ];then
		if [ $key == 1 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=0,trig_mode=2 -d /dev/video${port}
		elif [ $key == 2 ];then
    	    v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=1,trig_mode=2 -d /dev/video${port}
		fi
	elif [ $sensormode == 2 ];then
		if [ $key == 1 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=2,trig_mode=2 -d /dev/video${port}
		elif [ $key == 2 ];then
    	    v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=3,trig_mode=2 -d /dev/video${port}
		fi
	fi
else
	if [ $sensormode == 1 ];then
		if [ $key == 1 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=0,trig_mode=0 -d /dev/video${port}
		elif [ $key == 2 ];then
    	    v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=1,trig_mode=0 -d /dev/video${port}
		fi
	elif [ $sensormode == 2 ];then
		if [ $key == 1 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=2,trig_mode=0 -d /dev/video${port}
		elif [ $key == 2 ];then
    	    v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=3,trig_mode=0 -d /dev/video${port}
		fi
	fi
fi	

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
