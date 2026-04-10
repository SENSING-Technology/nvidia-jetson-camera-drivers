#!/bin/bash

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for AGX Orin & Jetson_Linux_R36.4.4 & Jetpack_6.2.1"

if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

CAMERA_CONFIG_FILE="$(pwd)/camera_config.sh"
if [ -f "$CAMERA_CONFIG_FILE" ]; then
    green_print "Loading camera configuration from $CAMERA_CONFIG_FILE"
    source "$CAMERA_CONFIG_FILE"
    green_print "Using configuration:"
    green_print "  ENABLE_3G_0=$ENABLE_3G_0"
    green_print "  ENABLE_3G_1=$ENABLE_3G_1"
    green_print "  SENSOR_MODE_0=$SENSOR_MODE_0"
    green_print "  SENSOR_MODE_1=$SENSOR_MODE_1"
    green_print "  SENSOR_MODE_2=$SENSOR_MODE_2"
    green_print "  SENSOR_MODE_3=$SENSOR_MODE_3"
    green_print "  SENSOR_MODE_4=$SENSOR_MODE_4"
    green_print "  SENSOR_MODE_5=$SENSOR_MODE_5"
    green_print "  SENSOR_MODE_6=$SENSOR_MODE_6"
    green_print "  SENSOR_MODE_7=$SENSOR_MODE_7"
    green_print ""
else
    # Default parameters if config file not found
    green_print "Warning: Camera configuration file not found. Using default parameters."
    green_print ""
    ENABLE_3G_0="0,0,0,0"
    ENABLE_3G_1="0,0,0,0"
    SENSOR_MODE_0="0"   
    SENSOR_MODE_1="0"   
    SENSOR_MODE_2="0"   
    SENSOR_MODE_3="0"   
    SENSOR_MODE_4="0"   
    SENSOR_MODE_5="0"   
    SENSOR_MODE_6="0"   
    SENSOR_MODE_7="0"   
fi

sudo rmmod sgcam-gmsl2 >/dev/null 2>&1
sudo rmmod max96712 >/dev/null 2>&1
sudo rmmod pwm-gpio >/dev/null 2>&1

## Set MIPI_MCLK0 and MIPI_MCLK1 as GPIO mode
sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

sudo insmod ko/pwm-gpio.ko
sudo insmod ko/max96712.ko debug_on=1
#sudo insmod ko/max96712.ko
# sudo insmod ko/sgcam-gmsl2.ko enable_3G_0=1,1,1,1 enable_3G_1=0,0,1,1
sudo insmod ko/sgcam-gmsl2.ko enable_3G_0=$ENABLE_3G_0 enable_3G_1=$ENABLE_3G_1

## master: trig_mode=0, slave: trig_mode=1
v4l2-ctl -d /dev/video0 -c sensor_mode=$SENSOR_MODE_0,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video1 -c sensor_mode=$SENSOR_MODE_1,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video2 -c sensor_mode=$SENSOR_MODE_2,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video3 -c sensor_mode=$SENSOR_MODE_3,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video4 -c sensor_mode=$SENSOR_MODE_4,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video5 -c sensor_mode=$SENSOR_MODE_5,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video6 -c sensor_mode=$SENSOR_MODE_6,trig_pin=0x00020007,trig_mode=0
v4l2-ctl -d /dev/video7 -c sensor_mode=$SENSOR_MODE_7,trig_pin=0x00020007,trig_mode=0

# v4l2-ctl -d /dev/video0 -c sensor_mode=$SENSOR_MODE_0,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video1 -c sensor_mode=$SENSOR_MODE_1,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video2 -c sensor_mode=$SENSOR_MODE_2,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video3 -c sensor_mode=$SENSOR_MODE_3,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video4 -c sensor_mode=$SENSOR_MODE_4,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video5 -c sensor_mode=$SENSOR_MODE_5,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video6 -c sensor_mode=$SENSOR_MODE_6,trig_pin=0x00020007,trig_mode=1
# v4l2-ctl -d /dev/video7 -c sensor_mode=$SENSOR_MODE_7,trig_pin=0x00020007,trig_mode=1

green_print "Load modules done."

