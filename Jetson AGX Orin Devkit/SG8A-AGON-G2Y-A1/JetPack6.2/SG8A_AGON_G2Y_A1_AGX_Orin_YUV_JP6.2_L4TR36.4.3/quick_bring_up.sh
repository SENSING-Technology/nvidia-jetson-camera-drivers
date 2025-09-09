#!/bin/bash
<<COMMENT
#
# 2024-05-22 AGX Orin
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

# Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

green_print "Select the camera type:"
echo 0:SG2-IMX390C-5200-G2A-Hxxx
echo 1:SG2-AR0233C-5200-G2A-Hxxx
echo 2:SG2-OX03CC-5200-GMSL2F-Hxxx
echo 3:SG3S-ISX031C-GMSL2-Hxxx
echo 4:SG3S-ISX031C-GMSL2F-Hxxx
echo 5:SG5-IMX490C-5300-GMSL2-Hxxx
echo 6:SG8S-AR0820C-5300-G2A-Hxxx
echo 7:SG8-OX08BC-5300-GMSL2-Hxxx
echo 8:SG8-ISX028C-G2G-Hxxx
echo 9:DMSBBFAN
echo 10:OMSBDAAN-AA

read target_cam

green_print "Select the camera port to light up[0-7]:"
read port

green_print "ready bring up camera"

sudo insmod ko/max96712.ko >/dev/null 2>&1

if [[ ${target_cam} -eq 2 ]] || [[ ${target_cam} -eq 4 ]] || [[ ${target_cam} -eq 9 ]]; then
        sudo insmod ko/sgx-yuv-gmsl2.ko enable_3G_0=1,1,1,1 enable_3G_1=1,1,1,1 >/dev/null 2>&1
else
        sudo insmod ko/sgx-yuv-gmsl2.ko >/dev/null 2>&1
fi

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0

if [[ ${target_cam} == 0 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
elif [[ ${target_cam} == 1 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
elif [[ ${target_cam} == 2 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_pin=0xffff0007
elif [[ ${target_cam} == 3 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_pin=0xffff0007
elif [[ ${target_cam} == 4 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_pin=0xffff0007
elif [[ ${target_cam} == 5 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_mode=1,trig_pin=0xffff0008
elif [[ ${target_cam} == 6 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_pin=0xffff0007
elif [[ ${target_cam} == 7 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_pin=0xffff0008
elif [[ ${target_cam} == 8 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=5,trig_pin=0xffff0007
elif [[ ${target_cam} == 9 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=6,trig_pin=0xffff0007
elif [[ ${target_cam} == 10 ]];then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=7,trig_mode=3,trig_pin=0xffff0007
fi

gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev