#!/bin/bash


sudo rmmod max96792
sudo rmmod max96793

sudo insmod ko/max96792.ko
sudo insmod ko/max96793.ko
sudo insmod ko/sg17-imx735c-gmsl3.ko

