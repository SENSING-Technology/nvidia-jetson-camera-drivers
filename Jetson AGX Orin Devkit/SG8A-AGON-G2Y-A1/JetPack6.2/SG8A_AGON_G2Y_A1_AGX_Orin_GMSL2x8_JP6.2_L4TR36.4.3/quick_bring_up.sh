#!/bin/bash
<<COMMENT
#
# 2026-03-17 AGX ORIN
# Modes: 0=GMSL1, 1=GMSL2 6Gbps (Default), 2=GMSL2 3Gbps
#
COMMENT

clear

red_print(){
	echo -e "\e[1;31m$1\e[0m"
}
green_print(){
	echo -e "\e[1;32m$1\e[0m"
}
yellow_print(){
    echo -e "\e[1;33m$1\e[0m"
}

## Check if v4l2-ctl exists
if ! command -v v4l2-ctl >/dev/null 2>&1; then
        red_print "v4l2-ctl not found, installing v4l-utils..."
        sudo apt update
        sudo apt install -y v4l-utils
fi

red_print "This package is use for AGX_ORIN Jetson_Linux_R36.4.3"
sleep 0.3

# Run boost clock if script exists
if [ -f "./boost_clock.sh" ]; then
    sudo ./boost_clock.sh
else
    red_print "Warning: boost_clock.sh not found, skipping."
fi

# ---------------------------------------------------------
# Check if driver module is already loaded
# ---------------------------------------------------------
MODULE_NAME="sgx_yuv_gmsl2"


if lsmod | grep -q "^${MODULE_NAME}"; then
    green_print "Detected: Module '${MODULE_NAME}' is already loaded."
    skip_load=true
else
    skip_load=false
fi

# ---------------------------------------------------------
# New Interaction: GMSL Mode Configuration per Port
# ---------------------------------------------------------
if [ "$skip_load" = false ]; then
    # Initialize arrays with default value 1 (GMSL2 6Gbps)
    # Ports 0-3 -> mask_0, Ports 4-7 -> mask_1
    declare -a mask_0=(1 1 1 1) 
    declare -a mask_1=(1 1 1 1) 

    # Input for GMSL1 (Mode 0)
    green_print "Please enter port numbers to enable GMSL1 Mode: Space separated, range 0-7. for example, '0 2' or press Enter for none"
    read -a ports_gmsl1
    
    # Input for GMSL2 3Gbps (Mode 2)
    green_print "Please enter port numbers to enable GMSL2 3Gbps Mode: Space separated, range 0-7. for example, '1 5' or press Enter for none"
    read -a ports_3g

    valid_input=true

    # Process GMSL1 inputs
    for p in "${ports_gmsl1[@]}"; do
        if [[ "$p" =~ ^[0-7]$ ]]; then
            if [ "$p" -lt 4 ]; then
                mask_0[$p]=0
            else
                idx=$((p - 4))
                mask_1[$idx]=0
            fi
        else
            red_print "Invalid port number for GMSL1: $p."
            valid_input=false
        fi
    done

    # Process GMSL2 3Gbps inputs
    for p in "${ports_3g[@]}"; do
        if [[ "$p" =~ ^[0-7]$ ]]; then
            # Check for conflict (if user entered same port in both lists)
            current_val=0
            if [ "$p" -lt 4 ]; then current_val=${mask_0[$p]}; else current_val=${mask_1[$((p-4))]}; fi
            
            # If it was already set to 0 by previous step, warn about override
            if [ "$current_val" -eq 0 ]; then
                yellow_print "Warning: Port $p was set to GMSL1, now overriding to GMSL2 3Gbps."
            fi

            if [ "$p" -lt 4 ]; then
                mask_0[$p]=2
            else
                idx=$((p - 4))
                mask_1[$idx]=2
            fi
        else
            red_print "Invalid port number for 3Gbps: $p."
            valid_input=false
        fi
    done

    if [ "$valid_input" = true ]; then
        # Construct the comma-separated strings
        str_0="${mask_0[0]},${mask_0[1]},${mask_0[2]},${mask_0[3]}"
        str_1="${mask_1[0]},${mask_1[1]},${mask_1[2]},${mask_1[3]}"
        
        # green_print "Configuration Summary:"
        # green_print "  Ports 0-3 Modes: $str_0"
        # green_print "  Ports 4-7 Modes: $str_1"
        sleep 1

        # Unload existing modules if any
        if lsmod | grep -q "^${MODULE_NAME}"; then
            sudo rmmod ${MODULE_NAME}
        fi
        if lsmod | grep -q "max96712"; then
            sudo rmmod max96712
        fi

        sudo insmod ko/max96712.ko debug_on=1 >/dev/null 2>&1
        sudo insmod ko/sgx-yuv-gmsl2.ko GMSLMODE_0=$str_0 GMSLMODE_1=$str_1
        
        if [ $? -ne 0 ]; then
            red_print "Failed to load driver. Please check dmesg for details."
            exit 1
        fi
        sudo insmod ko/pwm-gpio.ko >/dev/null 2>&1
        green_print "Driver loaded successfully with custom GMSL modes."
    else
        red_print "Aborting due to invalid port input."
        exit 1
    fi
else
    green_print "Skipping driver loading (Module already loaded)."
    # Optional: If you want to re-configure an already loaded module, you must rmmod first.
    # For now, we proceed to camera selection assuming the current load is correct.
fi

# ---------------------------------------------------------
# Camera Selection
# ---------------------------------------------------------
echo "0 : SG1Z2AESH(GMSL1)"
echo "1 : SN2M4EFGD(3G)"
echo "2 : SG2-IMX390C-5200-G2-Hxxx"
echo "3 : SG2-AR0233-5200-G-Hxxx"
echo "4 : SG2-OX03CC-5200-GMSL2F-Hxxx(3G)"
echo "5 : SG3-ISX031C-GMSL2-Hxxx"
echo "6 : SG3-ISX031C-GMSL2F-Hxxx (3G)"
echo "7 : RedFox-D3GN"
echo "8 : SH3-S11A60-G2A-Hxxx"
echo "9 : SG5-IMX490C-5300-GMSL2"
echo "10: SG8S-AR0820C-5300-GMSL2"
echo "11: SG8-OX08BC-5300-GMSL2-Hxxx"
echo "12: SG8-ISX028-G2G-Hxxx"
echo "13: DMSBBFAN (3G)"
echo "14: OMSBDAAN-AA"

green_print "Select your YUV camera type [0-14]:" 
read target_cam

green_print "Select your camera port [0-7]:" 
read port

# Validate port input roughly
if ! [[ "$port" =~ ^[0-7]$ ]]; then
    red_print "Invalid port number. Must be 0-7."
    exit 1
fi

green_print "Starting camera bring-up on port ${port}..." 
#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0

#trig_mode:0 = Auto trigger mode(Rising Edge),1 = Auto trigger mode(Falling  Edge), 2 = Orin / Ext Trigger mode, 3= MAX96712-generated Internal Trigger
# Configuration based on camera type
if [[ ${target_cam} == 0 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020000
elif [[ ${target_cam} == 1 ]]; then # For the SN2M4EFGD camera,when no PWM or external trigger signal is provided, trig_mode must be set to 3. If trig_mode is set to 2, the trigger frequency must be configured to 30 Hz.
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_mode=3,trig_pin=0x00020007
elif [[ ${target_cam} == 2 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 3 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_mode=0,trig_pin=0x00020007         
elif [[ ${target_cam} == 4 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 5 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 6 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007         
elif [[ ${target_cam} == 7 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 8 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 9 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_mode=0,trig_pin=0x00020008
elif [[ ${target_cam} == 10 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 11 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_mode=0,trig_pin=0x00020008
elif [[ ${target_cam} == 12 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=5,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 13 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=6,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 14 ]]; then  # For the OMSBDAAN-AA camera, when no PWM or external trigger signal is provided, trig_mode must be set to 3. If trig_mode is set to 2, the trigger frequency must be configured to 30 Hz.
        v4l2-ctl -d /dev/video${port} -c sensor_mode=7,trig_mode=3,trig_pin=0x00020007
else
        red_print "Warning: No specific config for camera type ${target_cam}, using defaults."
fi


gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev
