#!/bin/bash
<<COMMENT
#
# 2024-05-22 AGX Thor
#
COMMENT

clear

red_print(){
        echo -e "\e[1;31m$1\e[0m"
}
green_print(){
        echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for AGX Thor & Jetson_Linux_R38.2.0"

# Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

chmod 777 *
sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

#POWER
sudo i2ctransfer -y -f 9 w2@0x29 0x01 0x1f
sudo i2ctransfer -y -f 12 w2@0x28 0x01 0x1f

#GPIO PK.05
sudo busybox devmem 0x810c2810a0 w 0x203000 

green_print "Select the camera type:"
echo 0:SDV11NM1

read target_cam

green_print "Select the camera port to light up[0-7]:"
read port

green_print "ready bring up camera"

sudo insmod ./ko/max96712.ko >/dev/null 2>&1

if [[ ${target_cam} -eq 3 ]]; then
        sudo insmod ./ko/sdv11nm1.ko enable_3G_0=1,1,1,1 enable_3G_1=1,1,1,1 >/dev/null 2>&1
else
        sudo insmod ./ko/sdv11nm1.ko >/dev/null 2>&1
fi

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:1

if [[ ${target_cam} == 0 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_pin=0xffff0007
fi

#gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev
