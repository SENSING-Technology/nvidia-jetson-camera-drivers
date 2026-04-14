#!/bin/bash
echo 0 > /sys/class/pwm/pwmchip4/unexport
echo 0 > /sys/class/pwm/pwmchip4/export
# echo 33333333 > /sys/class/pwm/pwmchip4/pwm0/period
# echo 30000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle
echo 62500000  > /sys/class/pwm/pwmchip4/pwm0/period
echo 2000000  > /sys/class/pwm/pwmchip4/pwm0/duty_cycle
echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable

