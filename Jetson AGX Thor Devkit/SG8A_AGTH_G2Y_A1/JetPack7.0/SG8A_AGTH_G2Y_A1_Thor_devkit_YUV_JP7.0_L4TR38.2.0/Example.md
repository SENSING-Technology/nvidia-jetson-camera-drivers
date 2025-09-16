# External Trigger Mode

```
1.For Adapter Board CN4, the red wire and brown wire correspond to the external trigger signal pin and ground pin respectively. Connect the corresponding pins of the signal generator to these pins.
2.Execute the following command to load the driver (for 2MP camera) in the path of the board driver package.

sudo insmod ko/max96712.ko
sudo insmod ko/sgx-yuv-gmsl2.ko enable_3G_0=0,0,0,0 enable_3G_1=0,0,0,0 

v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video0
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video1
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video2
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video3
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video4
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video5
v4l2-ctl --set-fmt-video=width=1920,height=1080 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video6
v4l2-ctl --set-fmt-video=width=1920,height=1536 --set-ctrl bypass_mode=0,sensor_mode=1,trig_mode=2,trig_pin=0x00020007, -d /dev/video7

sudo ./boost_clock.sh

3.Use the command to print the frame rate.
v4l2-ctl -V --set-ctrl bypass_mode=0 --stream-mmap --stream-count=10000000 -d /dev/video0
```

# Internal Trigger Mode

```
1.Navigate to the board driver package directory and enter the following command to load the internal trigger pin driver.
 a.load the driver
 sudo insmod ko/pwm-gpio.ko
 
 b.Export PWM channel 0 (pwmchip4 is a newly generated node after loading the driver)
 echo 0 > /sys/class/pwm/pwmchip4/export
 
 c.Set the period to 33333333 (corresponding to 30 Hz)
 echo 33333333 > /sys/class/pwm/pwmchip4/pwm0/period
 
 d.Set the duty cycle
 echo 10000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle
 
 e.Enable PWM output
 echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable
 
2.Operate according to the above External Trigger Mode

```

