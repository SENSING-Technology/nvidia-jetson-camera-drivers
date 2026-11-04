#!/bin/bash

echo 0 > /sys/class/pwm/pwmchip5/unexport
echo 0 > /sys/class/pwm/pwmchip5/export
 echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period
 echo 3333333 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle
# echo 50000000 > /sys/class/pwm/pwmchip5/pwm0/period
# echo 5000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle
# echo 40000000 > /sys/class/pwm/pwmchip5/pwm0/period
# echo 4000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable

