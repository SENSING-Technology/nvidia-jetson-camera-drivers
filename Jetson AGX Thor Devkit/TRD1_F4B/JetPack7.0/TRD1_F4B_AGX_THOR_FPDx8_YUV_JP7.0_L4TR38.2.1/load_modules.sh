#!/bin/bash

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

## Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

# ## Set MIPI_MCLK1 and MIPI_MCLK0 as GPIO mode
# sudo busybox devmem 0x810c2810a8 w 0x203000
# sudo busybox devmem 0x810c2810a0 w 0x203000
#GPIO PK.05
sudo busybox devmem 0x810c2810a0 w 0x203000 
#GPIO PK.04
sudo busybox devmem 0x810c2810a8 w 0x203000 
sudo rmmod sgx_yuv_fpd4 >/dev/null 2>&1
sudo rmmod ti9724 >/dev/null 2>&1
sleep 2
sudo insmod ko/ti9724.ko debug_on=1
sudo insmod ko/sgx-yuv-fpd4.ko enable_fpd4_0=0,0,0,1 enable_fpd4_1=1,1,1,1 
sudo insmod ko/pwm-gpios.ko >/dev/null 2>&1

sudo ./boost_clock.sh

#sudo ./pwm.sh
# camera master: trig_mode=0,slave:trig_mode=1, Orin trigger pin: 0x00000000, Ext trigger pin: 0x00020000
v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video2 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video3 -c sensor_mode=3,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video4 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video5 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
v4l2-ctl -d /dev/video7 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0

green_print "Load modules done."

