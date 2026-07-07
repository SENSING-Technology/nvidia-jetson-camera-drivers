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

# green_print "Select the camera port to light up[0-7]:"
# read port

green_print "ready bring up camera"

sudo insmod ko/max96712.ko >/dev/null 2>&1

sudo insmod ko/sdv11nm1.ko 
sudo insmod ko/shw3g.ko
