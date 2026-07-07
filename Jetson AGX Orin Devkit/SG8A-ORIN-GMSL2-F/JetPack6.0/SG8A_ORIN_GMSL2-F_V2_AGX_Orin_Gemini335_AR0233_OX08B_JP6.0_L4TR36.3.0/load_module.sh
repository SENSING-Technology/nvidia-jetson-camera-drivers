#!/bin/bash

sudo insmod ./ko/serdes.ko
sudo insmod ./ko/fzcam.ko

sudo insmod ./ko/max9295.ko
sudo insmod ./ko/max9296.ko
sudo insmod ./ko/g2xx.ko

sleep 2

#change to max clk
sudo chmod a+x ./clock_config.sh
sudo ./clock_config.sh

sudo i2ctransfer -y -f 10 w3@0x48 0x03 0x20 0x34
sudo i2ctransfer -y -f 11 w3@0x48 0x03 0x20 0x37
sudo i2ctransfer -y -f 12 w3@0x48 0x03 0x20 0x34

# sensor_mode, used for resolution settings (0: 1920×1080, 1: 3840×2160)
v4l2-ctl -d /dev/video0 -c sensor_mode=1
v4l2-ctl -d /dev/video1 -c sensor_mode=1
v4l2-ctl -d /dev/video2 -c sensor_mode=1
v4l2-ctl -d /dev/video3 -c sensor_mode=1
v4l2-ctl -d /dev/video4 -c sensor_mode=1
v4l2-ctl -d /dev/video5 -c sensor_mode=1
