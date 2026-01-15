#!/bin/bash

red_print(){
        echo -e "\e[1;31m$1\e[0m"
}
green_print(){
        echo -e "\e[1;32m$1\e[0m"
}

sudo rmmod s56_shw5gc >/dev/null 2>&1

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

#chmod a+x boost_clock.sh
sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

sudo busybox devmem 0x02448020 w 0x1008  #PAC.04 ouptput mode for poc_ctrl
sudo busybox devmem 0x0c302028 w 0x0009  #PCC.02 ouptput mode for trigger
sudo insmod ./ko/pwm-gpio.ko >/dev/null 2>&1

sudo insmod ko/s56-shw5gc.ko >/dev/null 2>&1

