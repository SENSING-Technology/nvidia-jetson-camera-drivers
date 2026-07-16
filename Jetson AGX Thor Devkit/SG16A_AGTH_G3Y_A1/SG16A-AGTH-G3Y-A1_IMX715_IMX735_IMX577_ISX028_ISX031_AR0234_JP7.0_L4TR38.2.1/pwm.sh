#!/bin/bash

echo 0 > /sys/class/pwm/pwmchip6/unexport
echo 0 > /sys/class/pwm/pwmchip6/export
echo 33333333 > /sys/class/pwm/pwmchip6/pwm0/period
echo 30000000 > /sys/class/pwm/pwmchip6/pwm0/duty_cycle

#echo 25000000 > /sys/class/pwm/pwmchip6/pwm0/period
#echo 18000000 > /sys/class/pwm/pwmchip6/pwm0/duty_cycle

echo 1 > /sys/class/pwm/pwmchip6/pwm0/enable

