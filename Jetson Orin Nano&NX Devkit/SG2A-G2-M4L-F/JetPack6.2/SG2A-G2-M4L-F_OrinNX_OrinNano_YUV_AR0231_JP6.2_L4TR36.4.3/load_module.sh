#!/bin/bash


sudo insmod ko/max9296.ko
sudo insmod ko/max9295.ko i2c_reg8=1
sudo insmod ko/sgx-yuv-gmsl1.ko
