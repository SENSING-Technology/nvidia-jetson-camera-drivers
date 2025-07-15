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

sudo insmod ko/serdes.ko
sudo insmod ko/fzcam.ko
sudo insmod ko/serdesa.ko
sudo insmod ko/fzcama.ko
sudo insmod ko/max9296.ko
sudo insmod ko/max9295.ko
sudo insmod ko/d4xx.ko

