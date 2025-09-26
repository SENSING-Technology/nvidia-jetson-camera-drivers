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

# Set MIPI_MCLK0 and MIPI_MCLK1 as GPIO mode
sudo busybox devmem 0x810c2810a8 w 0x203000
sudo busybox devmem 0x810c2810a0 w 0x203000

sudo rmmod sg8_ox08dc_g2g >/dev/null 2>&1
sudo rmmod max96712 >/dev/null 2>&1
sleep 1
sudo insmod ko/max96712.ko debug_on=1
#sudo insmod ko/max96712.ko
sudo insmod ko/sg8-ox08dc-g2g.ko
sudo insmod ko/pwm-gpio.ko >/dev/null 2>&1

sudo ./boost_clock.sh

# master: trig_mode=0, slave: trig_mode=1
v4l2-ctl -d /dev/video0 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video1 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video2 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video3 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video4 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video5 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video6 -c trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video7 -c trig_pin=0x00020007,trig_mode=0

green_print "Load modules done."
