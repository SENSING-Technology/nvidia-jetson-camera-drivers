#!/bin/bash

PWMCHIP=/sys/class/pwm/pwmchip5
PWMNUM=0
PWMPATH=$PWMCHIP/pwm$PWMNUM

# 如果已导出，先关闭并取消导出
if [ -d "$PWMPATH" ]; then
    echo 0 > $PWMPATH/enable          # 先禁用
    echo $PWMNUM > $PWMCHIP/unexport  # 取消导出
fi

# 重新导出
echo $PWMNUM > $PWMCHIP/export

# 设置参数
#echo 33333333 > $PWMPATH/period      # ～30 Hz (33.3ms)
#echo 30000000 > $PWMPATH/duty_cycle  # ～90% 占空比
echo 40000000 > $PWMPATH/period      # ～30 Hz (33.3ms)
echo 10000000 > $PWMPATH/duty_cycle  # ～90% 占空比
#echo 50000000 > $PWMPATH/period      # ～30 Hz (33.3ms)
#echo 25000000 > $PWMPATH/duty_cycle  # ～90% 占空比
echo 1 > $PWMPATH/enable
