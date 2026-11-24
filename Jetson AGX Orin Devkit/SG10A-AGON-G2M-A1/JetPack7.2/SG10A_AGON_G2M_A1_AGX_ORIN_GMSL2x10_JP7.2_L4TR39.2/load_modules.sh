#!/bin/bash

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

if ! command -v busybox >/dev/null 2>&1; then
        red_print "busybox not found, installing busybox..."
        sudo apt update
        sudo apt install -y busybox
fi
sudo rmmod sgx_gmsl2_cam >/dev/null 2>&1


sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

sudo busybox devmem 0x02448020 w 0x1008 # A1 PAC.4 PoC output
sudo busybox devmem 0x0c302028 w 0x0009 # A1 PCC.2 FSYNC output
 
sudo insmod ko/sgx_gmsl2_cam.ko
sudo insmod ko/pwm-gpios.ko >/dev/null 2>&1
 
#For YUV Camera: 1920*1080：sensor_mode=1,1920*1536：sensor_mode=2,3840*2160：sensor_mode=4;For RAW  Camera：sensor_mode=0

#For 6G GMSL2 Mode, set gmsl_mode=0;For 3G GMSL2 Mode(only SG3S11AFSK), set gmsl_mode=1

# Trigger defaults: CAM0..3 MFP7 (0x00070007); CAM4..9 MFP6 (0x00060007).

#trig_mode:MASTER_RISE_EDGE:trig_mode=0,SLAVER:trig_mode=2
v4l2-ctl -d /dev/video0 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
v4l2-ctl -d /dev/video1 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
v4l2-ctl -d /dev/video2 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
v4l2-ctl -d /dev/video3 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
v4l2-ctl -d /dev/video4 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
v4l2-ctl -d /dev/video5 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=2
v4l2-ctl -d /dev/video7 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
v4l2-ctl -d /dev/video8 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
v4l2-ctl -d /dev/video9 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
