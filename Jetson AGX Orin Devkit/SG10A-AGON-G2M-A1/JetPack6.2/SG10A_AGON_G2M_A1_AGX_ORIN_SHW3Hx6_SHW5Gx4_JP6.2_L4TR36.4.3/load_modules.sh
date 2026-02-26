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

red_print "This package is use for Sensing SG10A_AGON_G2M_A1_AGX_ORIN_SHE3Hx6_SHW5Gx4_JP6.2_L4TR36.4.3"

# Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils busybox
fi


if [ "`sudo lsmod | grep shw3h_shw5g`" == "" ];then
	sudo busybox devmem 0x02448020 w 0x1008  #PAC.04 ouptput mode for poc_ctrl
	sudo busybox devmem 0x0c302028 w 0x0009  #PCC.02 ouptput mode for trigger
	sudo insmod ./ko/pwm-gpio.ko
	sudo insmod ./ko/shw3h_shw5g.ko
    sudo chmod 777 ./gpio-pwm.sh
    sudo ./gpio-pwm.sh
fi	

camera_array=([1]=shw3h
              [2]=shw5g)
echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
green_print "Press select your camera:"

read camId

if [[ "$camId" != "1" && "$camId" != "2" ]]; then
    echo "Invalid camera id"
    exit 1
fi

green_print "Please select your camera resolution:"

if [ "$camId" == "1" ]; then
    sensor_mode[1]="1920x1536"
elif [ "$camId" == "2" ]; then
    sensor_mode[1]="2560x1984"
else
    echo "Invalid camera id"
    exit 1
fi

echo "1:${sensor_mode[1]}"

read sensormode


if [[ "$sensormode" != "1" ]]; then
    echo "Invalid camera resolution"
    exit 1
fi


if [ "$camId" == "1" ]; then
    green_print "Press select your camera port [0-5]:" 
    read port
    if (( port < 0 || port > 5 )); then
        echo "Invalid camera port: $port (expect 0-5)"
        exit 1
    fi

elif [ "$camId" == "2" ]; then
    green_print "Press select your camera port [6-9]:"
    read port
    if (( port < 6 || port > 9 )); then
        echo "Invalid camera port: $port (expect 6-9)"
        exit 1
    fi
fi


green_print "Select your trigger mode [0:Internal trigger, 1:External trigger]:" 
read trig_mode

green_print "Start bring up camera!" 

string=(`echo ${sensor_mode[sensormode]} | tr 'x' ' '`)

echo "${string[0]},height=${string[1]} "

if [ $trig_mode == 1 ];then
    if [ $camId == 1 ];then
        v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=3,trig_mode=1 -d /dev/video${port}
    elif [ $camId == 2 ];then
        v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=0,trig_mode=1 -d /dev/video${port}
    fi
else
    if [ $camId == 1 ];then
        v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=3,trig_mode=2 -d /dev/video${port}
    elif [ $camId == 2 ];then
        v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl sensor_mode=0,trig_mode=0 -d /dev/video${port}
    fi
fi	

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
if [ $camId == 1 ];then
    gst-launch-1.0 v4l2src device=/dev/video${port} ! video/x-raw,width=${string[0]},height=${string[1]},format=UYVY   ! xvimagesink -ev
elif [ $camId == 2 ];then
    argus_camera -d ${port}
fi
