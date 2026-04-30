#!/bin/bash

red_print(){
        echo -e "\e[1;31m$1\e[0m"
}
green_print(){
        echo -e "\e[1;32m$1\e[0m"
}

sudo rmmod bmi088 2>/dev/null || true
sudo rmmod kfifo_buf 2>/dev/null || true
sudo rmmod sgx_yuv_gmsl2 2>/dev/null || true
sudo rmmod s56_shw3gc 2>/dev/null || true

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

chmod a+x boost_clock.sh
sudo ./boost_clock.sh >/dev/null 2>&1
sleep 0.5

sudo busybox devmem 0x02448020 w 0x1008  #PAC.04 ouptput mode for poc_ctrl
sudo busybox devmem 0x0c302028 w 0x0009  #PCC.02 ouptput mode for trigger

# Check if pwm-gpio module is already loaded
if lsmod | grep -q pwm_gpio; then
    echo "pwm-gpio module is already loaded"
else
    echo "Loading pwm-gpio module..."
    sudo insmod ./ko/pwm-gpio.ko >/dev/null 2>&1
fi
sleep 0.5
sudo chmod 777 gpio-pwm.sh

# Check if PWM device is available
if [[ ! -d "/sys/class/pwm/pwmchip5" ]]; then
    echo "ERROR: PWM chip not found at /sys/class/pwm/pwmchip5" >&2
    echo "Please ensure pwm-gpio.ko module is loaded correctly" >&2
    exit 1
fi
# Frame rate selection
if [[ $# -eq 0 ]]; then
    echo "Select frame rate:"
    echo "  1) 10 Hz"
    echo "  2) 15 Hz"
    echo "  3) 20 Hz"
    echo "  4) 30 Hz (default)"
    echo "  5) 60 Hz"
    echo -n "Enter choice [1-5] or direct Hz value (10/15/20/30/60): "
    read -r choice

    case $choice in
        1|10) FRAME_RATE=10 ;;
        2|15) FRAME_RATE=15 ;;
        3|20) FRAME_RATE=20 ;;
        4|30) FRAME_RATE=30 ;;
        5|60) FRAME_RATE=60 ;;
        *)
            echo "Invalid choice, using default: 30 Hz"
            FRAME_RATE=30
            ;;
    esac
else
    # Check if argument is a valid frame rate
    case $1 in
        10|15|20|30|60)
            FRAME_RATE=$1
            ;;
        *)
            echo "Invalid frame rate: $1. Using default: 30 Hz"
            FRAME_RATE=30
            ;;
    esac
fi

echo "Starting PWM configuration with frame rate: ${FRAME_RATE} Hz"
sudo ./gpio-pwm.sh "$FRAME_RATE"

sudo insmod ko/s56-shw3gc.ko
sudo insmod ko/sgx-yuv-gmsl2.ko

sudo insmod ko/kfifo_buf.ko
sudo insmod ko/bmi088.ko

## For S56
## trig_mode: 0 = No sync trigger used; 1 = Use AGX Orin's trigger signal for camera sync.
v4l2-ctl -d /dev/video0 -c trig_mode=1
v4l2-ctl -d /dev/video1 -c trig_mode=1
v4l2-ctl -d /dev/video2 -c trig_mode=1
v4l2-ctl -d /dev/video3 -c trig_mode=1

## For SHF3L/SHF3H
## sensor_mode: 2 = Resolution 1920x1536.
## trig_mode: 0 = No sync trigger used; 2 = Use AGX Orin's trigger signal for camera sync.
v4l2-ctl -d /dev/video4 -c sensor_mode=2,trig_mode=2
v4l2-ctl -d /dev/video5 -c sensor_mode=2,trig_mode=2
v4l2-ctl -d /dev/video6 -c sensor_mode=2,trig_mode=2
v4l2-ctl -d /dev/video7 -c sensor_mode=2,trig_mode=2
v4l2-ctl -d /dev/video8 -c sensor_mode=2,trig_mode=2
v4l2-ctl -d /dev/video9 -c sensor_mode=2,trig_mode=2

