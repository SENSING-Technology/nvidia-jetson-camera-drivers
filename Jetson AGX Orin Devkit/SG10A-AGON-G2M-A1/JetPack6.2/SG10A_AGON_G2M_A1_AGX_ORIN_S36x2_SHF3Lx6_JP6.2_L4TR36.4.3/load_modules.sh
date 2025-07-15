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

sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

sudo busybox devmem 0x02448020 w 0x1008

sudo insmod ko/sgx_yuv_cam.ko

## Manual Triger
# for SHF3L Module(6G GMSL Mode), set gmsl_mode=0 
# for SG3S-ISX031C-GMSL2F Module(3G GMSL Mode), set gmsl_mode=1
v4l2-ctl -d /dev/video0 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video1 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video2 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video3 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video4 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video5 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video7 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video8 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
v4l2-ctl -d /dev/video9 -c sensor_mode=2,gmsl_mode=0,trig_mode=0

## EXT Trigger
#v4l2-ctl -d /dev/video0 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00070007,trig_mode=3
#v4l2-ctl -d /dev/video1 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00070007,trig_mode=3
#v4l2-ctl -d /dev/video2 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00070007,trig_mode=3
#v4l2-ctl -d /dev/video3 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00070007,trig_mode=3
#v4l2-ctl -d /dev/video4 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=3
#v4l2-ctl -d /dev/video5 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=3
#v4l2-ctl -d /dev/video6 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=3
#v4l2-ctl -d /dev/video7 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=3
#v4l2-ctl -d /dev/video8 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=3
#v4l2-ctl -d /dev/video9 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=3
