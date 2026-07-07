#!/bin/bash

sudo insmod sgx-yuv-gmsl2.ko mode=0xf300f777

v4l2-ctl -c sensor_mode=1 -d /dev/video0
v4l2-ctl -c sensor_mode=1 -d /dev/video1
v4l2-ctl -c sensor_mode=1 -d /dev/video2
v4l2-ctl -c sensor_mode=1 -d /dev/video3
v4l2-ctl -c sensor_mode=1 -d /dev/video4
v4l2-ctl -c sensor_mode=1 -d /dev/video5

#gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev &
#gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev &
#gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev &
#gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev &
#gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev &
#gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev &

