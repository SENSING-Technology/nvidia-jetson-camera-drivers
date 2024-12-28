#!/bin/bash
<<COMMENT
#
# 2024-10-09 Jetson Orin Nx/Nano SG2A-G2-M4L-F
#
COMMENT

clear
echo "This package is use for tc358748 640*512@50fps on SG2A-G2-M4L-F && Jetson_Linux_R35.4.1"

cd $PWD/ko
sudo insmod max9295.ko >/dev/null 2>&1
sudo insmod max9296.ko >/dev/null 2>&1
sudo insmod nv_tc358748.ko >/dev/null 2>&1

v4l2-ctl --set-ctrl bypass_mode=0,sensor_mode=3 -d /dev/video0
gst-launch-1.0 v4l2src device=/dev/video0 ! video/x-raw,format=UYVY,width=640,height=512,framerate=50/1 ! xvimagesink -ev