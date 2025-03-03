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

