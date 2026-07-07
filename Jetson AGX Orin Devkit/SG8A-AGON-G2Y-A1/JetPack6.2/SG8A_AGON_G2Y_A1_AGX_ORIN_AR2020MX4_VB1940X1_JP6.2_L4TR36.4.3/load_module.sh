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

sudo rmmod ar2020m >/dev/null 2>&1
sudo rmmod shw5g >/dev/null 2>&1 
sudo rmmod max96712 >/dev/null 2>&1 
sleep 2
#sudo insmod ko/max96712.ko
sudo insmod ko/max96712.ko debug_on=1
sudo insmod ko/ar2020m.ko
sudo insmod ko/shw5g.ko debug_on=1
sudo insmod ko/pwm-gpio.ko >/dev/null 2>&1

sudo ./boost_clock.sh
#sudo ./pwm.sh


## Auto trigger: trig_mode=0; Orin trigger/ Ext Trigger: trig_mode=1

v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_mode=0
