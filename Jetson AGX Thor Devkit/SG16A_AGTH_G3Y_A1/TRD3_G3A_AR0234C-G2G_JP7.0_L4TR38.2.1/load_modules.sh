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

sudo rmmod sg2-ar0234c-g2g >/dev/null 2>&1
sudo rmmod max96726 >/dev/null 2>&1

sleep 2
sudo insmod ko/max96726.ko debug_on=1
sudo insmod ko/sg2-ar0234c-g2g.ko 
sudo insmod ko/pwm-gpio.ko >/dev/null 2>&1

sudo ./boost_clock.sh
# export DISPLAY=:0
# 60fps:sensor_mode=0; 120fps:sensor_mode=1
# master: trig_mode=0, slave: trig_mode=1
v4l2-ctl -d /dev/video0 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video8 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video9 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video10 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video11 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video12 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video13 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video14 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video15 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0

green_print "Load modules done."




