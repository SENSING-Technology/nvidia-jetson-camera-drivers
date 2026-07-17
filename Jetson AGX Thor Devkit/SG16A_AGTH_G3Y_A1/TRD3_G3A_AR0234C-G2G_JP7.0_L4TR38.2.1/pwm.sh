#!/bin/bash

echo 0 > /sys/class/pwm/pwmchip6/unexport
echo 0 > /sys/class/pwm/pwmchip6/export

echo 16666666 > /sys/class/pwm/pwmchip6/pwm0/period #60HZ
echo 15000000 > /sys/class/pwm/pwmchip6/pwm0/duty_cycle

#echo 8333333 > /sys/class/pwm/pwmchip6/pwm0/period #120HZ
#echo 7500000 > /sys/class/pwm/pwmchip6/pwm0/duty_cycle

echo 1 > /sys/class/pwm/pwmchip6/pwm0/enable

