
Reference Documentation:
https://docs.nvidia.com/jetson/archives/r35.4.1/DeveloperGuide/text/SD/Kernel/Bmi088ImuIioDriver.html

1. Load Modules
$ sudo insmod ../../ko/kfifo_buf.ko
$ sudo insmod ../../ko/bmi088.ko

2. Compile sample
$ make clean && make

3. Testing BMI088 Driver

3.1 Accelerometer Sample Output
$ sudo ./iio_generic_buffer -a -c 10 --device-name accelerometer -g

log:
iio device number being used is 0
trigger-less mode selected
Enabling all channels
Enabling: in_accel_x_en
Enabling: in_accel_z_en
Enabling: in_timestamp_en
Enabling: in_accel_y_en
-1.018992 -0.226044 -9.503716 2481308413888
-1.044108 -0.230529 -9.579960 2481387959136
-1.048593 -0.235911 -9.579960 2481467503520
-1.037829 -0.228735 -9.582651 2481547040576
-1.033344 -0.221559 -9.573681 2481626574240
-1.031550 -0.235911 -9.566505 2481706107648
-1.041417 -0.234117 -9.579063 2481785639776
-1.039623 -0.231426 -9.584445 2481865177376
-1.028859 -0.246675 -9.572784 2481944712320
-1.027962 -0.231426 -9.565608 2482024249600
Disabling: in_accel_x_en
Disabling: in_accel_z_en
Disabling: in_timestamp_en
Disabling: in_accel_y_en

3.2 Gyroscope Sample Output
$ sudo ./iio_generic_buffer -a -c 10 --device-name gyroscope -g

log:
iio device number being used is 0
trigger-less mode selected
Enabling all channels
Enabling: in_accel_x_en
Enabling: in_accel_z_en
Enabling: in_timestamp_en
Enabling: in_accel_y_en
-1.041417 -0.209001 -9.512685 2194233169568
-1.038726 -0.224250 -9.614944 2194312719168
-1.019889 -0.232323 -9.571887 2194392267744
-1.011816 -0.227838 -9.562020 2194471817312
-1.029756 -0.222456 -9.579960 2194551368704
-1.034241 -0.220662 -9.583549 2194630921152
-1.021683 -0.232323 -9.570093 2194710475840
-1.021683 -0.231426 -9.567402 2194790028000
-1.037829 -0.221559 -9.573681 2194869576960
-1.033344 -0.234117 -9.582651 2194949131936
Disabling: in_accel_x_en
Disabling: in_accel_z_en
Disabling: in_timestamp_en
Disabling: in_accel_y_en
