#!/bin/bash
echo 0 > /sys/class/pwm/pwmchip4/unexport
echo 0 > /sys/class/pwm/pwmchip4/export
#15fps
echo 66666666  > /sys/class/pwm/pwmchip4/pwm0/period 
echo 60000000   > /sys/class/pwm/pwmchip4/pwm0/duty_cycle
echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable

