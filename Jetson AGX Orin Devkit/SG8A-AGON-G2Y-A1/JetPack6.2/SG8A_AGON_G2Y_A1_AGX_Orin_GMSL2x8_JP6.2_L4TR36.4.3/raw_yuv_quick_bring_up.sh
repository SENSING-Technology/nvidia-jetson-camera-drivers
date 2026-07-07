#!/bin/bash
<<COMMENT
#
# 2026-03-17 AGX ORIN
# Modes: 0=GMSL2 6Gbps (Default), 1=GMSL2 3Gbps
#
COMMENT

clear

red_print(){
	echo -e "\e[1;31m$1\e[0m"
}
green_print(){
	echo -e "\e[1;32m$1\e[0m"
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
MODULE_NAME="sgcam_gmsl2" 

if lsmod | grep -q "^${MODULE_NAME}"; then
    green_print "Detected: Module '${MODULE_NAME}' is already loaded."
    skip_load=true
else
    skip_load=false
fi

# ---------------------------------------------------------
# Original Interaction: 3G Mode Camera Setup (Ports 0-7)
# Only runs if skip_load is false
# ---------------------------------------------------------
if [ "$skip_load" = false ]; then
    green_print "Do you want to connect a 3G mode camera? (y/n):"
    read is_3g_mode

    # Initialize arrays for 3G enable flags (4 ports per controller)
    declare -a mask_0=(0 0 0 0) # For ports 0, 1, 2, 3
    declare -a mask_1=(0 0 0 0) # For ports 4, 5, 6, 7

    if [[ "$is_3g_mode" =~ ^[Yy]$ ]]; then
        green_print "Please enter the enabled port numbers (space separated, range 0-7)."
        green_print "Example: '0 1 2' or '4 5' or '0 4 7'"
        read -a ports_input
        
        valid_input=true
        
        for p in "${ports_input[@]}"; do
            if [[ "$p" =~ ^[0-7]$ ]]; then
                if [ "$p" -lt 4 ]; then
                    # Ports 0-3 map to enable_3G_0
                    mask_0[$p]=1
                else
                    # Ports 4-7 map to enable_3G_1 (index = p - 4)
                    idx=$((p - 4))
                    mask_1[$idx]=1
                fi
            else
                red_print "Invalid port number: $p. Please use integers between 0 and 7."
                valid_input=false
                break
            fi
        done

        if [ "$valid_input" = true ]; then
            # Construct the comma-separated strings
            str_0="${mask_0[0]},${mask_0[1]},${mask_0[2]},${mask_0[3]}"
            str_1="${mask_1[0]},${mask_1[1]},${mask_1[2]},${mask_1[3]}"
            
            # green_print "Loading driver with 3G mode enabled for ports: ${ports_input[*]}"
            # green_print "Parameters: enable_3G_0=$str_0 enable_3G_1=$str_1"
            
            # Unload if already loaded (should not happen here due to check above, but safe to keep)
            if lsmod | grep -q "^${MODULE_NAME}"; then
                sudo rmmod ${MODULE_NAME}
            fi
            # Also remove max96712 if dependent
            if lsmod | grep -q "max96712"; then
                sudo rmmod max96712
            fi

            sudo insmod ko/max96712.ko debug_on=1 >/dev/null 2>&1
            sudo insmod ./ko/sgcam-gmsl2.ko enable_3G_0=$str_0 enable_3G_1=$str_1  >/dev/null 2>&1
           
            if [ $? -ne 0 ]; then
                red_print "Failed to load sgcam-gmsl2.ko. Please check dmesg for details."
                exit 1
            fi
            sudo insmod ko/pwm-gpio.ko >/dev/null 2>&1
            green_print "Driver loaded successfully."
        else
            red_print "Aborting due to invalid port input."
            exit 1
        fi
    else
        green_print "Skipping 3G mode specific driver loading (Standard Mode)."
        # Ensure clean state before loading standard
        if lsmod | grep -q "^${MODULE_NAME}"; then
            sudo rmmod ${MODULE_NAME}
        fi
        if lsmod | grep -q "max96712"; then
            sudo rmmod max96712
        fi
        
        sudo insmod ko/max96712.ko debug_on=1 >/dev/null 2>&1
        sudo insmod ./ko/sgcam-gmsl2.ko enable_3G_0=0,0,0,0 enable_3G_1=0,0,0,0 
        
        if [ $? -ne 0 ]; then
             red_print "Failed to load standard driver. Check dmesg."
             exit 1
        fi
    fi
fi

# ---------------------------------------------------------
# Camera Selection (Entry Point for both paths)
# ---------------------------------------------------------

echo "0:SN2M4EFGD(3G)"
echo "1:SG2-IMX390C-5200-G2-Hxxx"
echo "2:SG2-AR0233-5200-G-Hxxx"
echo "3:SG2-OX03CC-5200-GMSL2F-Hxxx(3G)"
echo "4:DMSBBFAN(3G)"
echo "5:SG3-ISX031C-GMSL2-Hxxx"
echo "6:SG3-ISX031C-GMSL2F-Hxxx(3G)"
echo "7:RedFox-D3GN"
echo "8:SH3-S11A60-G2A-Hxxx"
echo "9:OMSBDAAN-AA"
echo "10:SG5-IMX490C-5300-GMSL2"
echo "11:SG8S-AR0820C-5300-GMSL2"
echo "12:SG8-OX08BC-5300-GMSL2-Hxxx"
echo "13:SG8-ISX028-G2G-Hxxx"
echo "14:SHW3G(raw)"
echo "15:SDV11NM1(raw)"
green_print "Press select your yuv camera type [0-15]:" 
read target_cam

green_print "Press select your camera port [0-7]:" 
read port

green_print "Start bring up camera!" 
#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
#trig_mode: 0 = Auto trigger mode, 1 = Orin / Ext Trigger mode, 2= MAX96712-generated Internal Trigger
# Configuration based on camera type
if [[ ${target_cam} == 0 ]]; then # For the SN2M4EFGD camera,When no PWM or external trigger signal is provided, trig_mode must be set to 2. If trig_mode is set to 1, the trigger frequency must be configured to 30 Hz.
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=2,trig_pin=0x00020007
elif [[ ${target_cam} == 1 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 2 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 3 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 4 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=1,trig_mode=2,trig_pin=0x00020007
elif [[ ${target_cam} == 5 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 6 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 7 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 8 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=2,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 9 ]]; then # For the OMSBDAAN-AA camera, When no PWM or external trigger signal is provided, trig_mode must be set to 2. If trig_mode is set to 1, the trigger frequency must be configured to 30 Hz.
        v4l2-ctl -d /dev/video${port} -c sensor_mode=3,trig_mode=2,trig_pin=0x00020007
elif [[ ${target_cam} == 10 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_mode=0,trig_pin=0x00020008
elif [[ ${target_cam} == 11 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=5,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 12 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=4,trig_mode=0,trig_pin=0x00020008
elif [[ ${target_cam} == 13 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=6,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 14 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020007
elif [[ ${target_cam} == 15 ]]; then
        v4l2-ctl -d /dev/video${port} -c sensor_mode=0,trig_mode=0,trig_pin=0x00020007
else
        red_print "Warning: No specific config for camera type ${target_cam}, using defaults."
fi

# Start GStreamer pipeline
green_print "Launching GStreamer pipeline on /dev/video${port}..."
if [[ ${target_cam} -ge 14 && ${target_cam} -le 15 ]];then
       argus_camera -d ${port}
else
        gst-launch-1.0 v4l2src device=/dev/video${port} ! xvimagesink -ev
fi
