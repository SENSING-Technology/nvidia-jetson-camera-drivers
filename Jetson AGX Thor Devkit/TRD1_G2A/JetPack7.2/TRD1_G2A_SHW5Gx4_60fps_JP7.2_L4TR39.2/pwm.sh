#!/bin/bash

PWMCHIP=/sys/class/pwm/pwmchip4
PWMNUM=0
PWMPATH=$PWMCHIP/pwm$PWMNUM

if [ -d "$PWMPATH" ]; then
    echo 0 > $PWMPATH/enable          
    echo $PWMNUM > $PWMCHIP/unexport  
fi

echo $PWMNUM > $PWMCHIP/export

# # set up parameters
#  echo 33333333 > $PWMPATH/period      # 30 Hz 
#  echo 30000000 > $PWMPATH/duty_cycle  

echo 16000000 > $PWMPATH/period      # 60 Hz (周期约为 16.67ms)
echo 3333333 > $PWMPATH/duty_cycle   # 50% 占空比 (高电平约为 8.33ms)

# echo 40000000 > $PWMPATH/period      # 25 Hz
# echo 30000000 > $PWMPATH/duty_cycle  

# echo 50000000 > $PWMPATH/period      # 20 Hz
# echo 40000000 > $PWMPATH/duty_cycle  

echo 1 > $PWMPATH/enable
