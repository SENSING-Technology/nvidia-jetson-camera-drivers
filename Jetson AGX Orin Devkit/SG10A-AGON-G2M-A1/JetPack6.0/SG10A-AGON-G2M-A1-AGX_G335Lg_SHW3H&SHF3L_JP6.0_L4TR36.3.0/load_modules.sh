#!/bin/bash

sudo busybox devmem 0x02448020 w 0x1008

sudo insmod ./ko/serdes.ko
sudo insmod ./ko/fzcam.ko

sudo insmod ./ko/serdesa.ko
sudo insmod ./ko/fzcama.ko

sudo insmod ./ko/max9295.ko
sudo insmod ./ko/max9296.ko
sudo insmod ./ko/g2xx.ko


#change to max clk
sudo chmod a+x ./clock_config.sh
sudo ./clock_config.sh

   ## CAM2
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev &

   ## CAM3
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev &

   ## CAM4
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev &

   ## CAM5
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev &

   ## CAM6
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev &

   ## CAM7
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev &
