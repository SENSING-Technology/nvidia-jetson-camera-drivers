
#!/bin/bash
echo 0 > /sys/class/pwm/pwmchip5/unexport
echo 0 > /sys/class/pwm/pwmchip5/export

# echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period #30Hz
# echo 3333333 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# echo 50000000 > /sys/class/pwm/pwmchip5/pwm0/period   #20Hz
# echo 5000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

# echo 52631579 > /sys/class/pwm/pwmchip5/pwm0/period      # 约19Hz
# echo 5263158  > /sys/class/pwm/pwmchip5/pwm0/duty_cycle  # 占空比约10%

 echo 71428571 > /sys/class/pwm/pwmchip5/pwm0/period #14Hz
 echo 64285714 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle



echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable

