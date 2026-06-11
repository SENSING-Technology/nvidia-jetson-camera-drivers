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
sudo rmmod shw5g >/dev/null 2>&1
sleep 0.2
sudo busybox devmem 0x02448020 w 0x1008

# sudo insmod ko/s56-shw5gc.ko
sudo insmod ko/shw5g.ko
## Manual Triger
# trig_mode: 0:master 1:slave
v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video8 -c sensor_mode=0,trig_mode=1
v4l2-ctl -d /dev/video9 -c sensor_mode=0,trig_mode=1

