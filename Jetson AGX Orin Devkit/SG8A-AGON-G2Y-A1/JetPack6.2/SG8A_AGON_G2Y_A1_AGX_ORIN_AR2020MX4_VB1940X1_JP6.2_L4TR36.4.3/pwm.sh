
#!/bin/bash
echo 0 > /sys/class/pwm/pwmchip5/unexport
echo 0 > /sys/class/pwm/pwmchip5/export

# echo 50000000 > /sys/class/pwm/pwmchip5/pwm0/period   #20Hz
# echo 45000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# 设置周期为 100ms (对应 10Hz)
# echo 100000000 > /sys/class/pwm/pwmchip5/pwm0/period  #10Hz
 #echo 90000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# 设置周期约为 90.9ms (对应 11Hz)
# echo 90909091 > /sys/class/pwm/pwmchip5/pwm0/period  #11Hz
# echo 81818182 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# # 设置周期约为 83.3ms (对应 12Hz)
# echo 83333333 > /sys/class/pwm/pwmchip5/pwm0/period #12Hz
# echo 75000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# # 设置周期约为 76.9ms (对应 13Hz)
# echo 76923077 > /sys/class/pwm/pwmchip5/pwm0/period #13Hz
# echo 69230769 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

echo 71428571 > /sys/class/pwm/pwmchip5/pwm0/period #14Hz
echo 64285714 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle


echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable

