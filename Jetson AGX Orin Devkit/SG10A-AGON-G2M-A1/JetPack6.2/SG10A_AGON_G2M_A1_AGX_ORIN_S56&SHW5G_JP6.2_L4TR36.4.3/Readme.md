#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SHW5G
  * support max 9 cameras to light up at the same time

* S56
  * support max 4 cameras to light up at the same time

* S56&SHW5G
  * support max 2 S56 and 5 SHW5G to light up at the same time


#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_Orin_S56&SHW5G_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG10A_AGON_G2M_A1_AGX_Orin_S56&SHW5G_JP6.2_L4TR36.4.3
   ```
3. Grant execute permissions to all scripts, then run the "install.sh" script and wait for the system to reboot

   ```
   chmod a+x *.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select Configure for compatible hardware
   For SHW5G
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 SHW5G GMSL2x10"
   For S56
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 S56 GMSL2x4"
   For S56&SHW5G
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 S56x2 And SHW5Gx6"

   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the reboot, run the "load_modules.sh" script

   ```
   chmod a+x load_modules.sh
   sudo ./load_modules.sh
   ```
   The correspondence between CAM ports and device nodes is as follows

    ```
    For SHW5G
    PORT                    DEV NODE                   Camera
    J25                    /dev/video0                 SHW5G
    J26                    /dev/video1                 SHW5G
    J23                    /dev/video2                 SHW5G
    J24                    /dev/video3                 SHW5G
    J21                    /dev/video4                 SHW5G
    J22                    /dev/video5                 SHW5G
    J27                    /dev/video6                 SHW5G
    J28                    /dev/video7                 SHW5G
    J29                    /dev/video8                 SHW5G    
    J30                    /dev/video9                 SHW5G
    ```
    ```
    For S56
    PORT                    DEV NODE                   Camera
    J25                    /dev/video0                 S56
    J26                    /dev/video1                 
    J23                    /dev/video2                 S56
    J24                    /dev/video3                 
    J21                    /dev/video4                 S56
    J22                    /dev/video5                 
    J27                    /dev/video6                 S56
    J28                    /dev/video7                 
    J29                    /dev/video8                     
    J30                    /dev/video9                 
    ```
    ```
    For S56&SHW5G
    PORT                    DEV NODE                   Camera
    J25                    /dev/video0                 S56
    J26                    /dev/video1                 
    J23                    /dev/video2                 S56
    J24                    /dev/video3                 
    J21                    /dev/video4                 SHW5G
    J22                    /dev/video5                 SHW5G
    J27                    /dev/video6                 SHW5G
    J28                    /dev/video7                 SHW5G
    J29                    /dev/video8                 SHW5G    
    J30                    /dev/video9                 SHW5G
    ```

6. Bring up camera(Take cam0 as an example)
  a. Without using trigger synchronization.
  ```
  For SHW5G
  v4l2-ctl -c trig_mode=0 -d /dev/video0
  argus_camera -d 0
  ```
  ```
  For S56
  v4l2-ctl -c trig_mode=0 -d /dev/video0
  v4l2-ctl -c trig_mode=0 -d /dev/video1
  argus_camera -d 0
  argus_camera -d 1
  ```
   
  b.Use trigger synchronization (you need to provide an external trigger signal to the adapter board).
  ```
  For SHW5G
  v4l2-ctl -c trig_mode=1 -d /dev/video0
  argus_camera -d 0
  ```
   ```
  For S56
  v4l2-ctl -c trig_mode=1 -d /dev/video0
  v4l2-ctl -c trig_mode=1 -d /dev/video1
  argus_camera -d 0
  argus_camera -d 1
  ```
  If you choose the "External Trigger" mode, you need to provide a trigger signal to the adapter board. 
   Or you can generate the trigger signal through AGX.
   The trigger signal interface is J19, with pins from top to bottom labeled as Pin1 through Pin4. Pin2 and Pin4 are connected together.
   ```
   # 30HZ
   sudo su
   echo 0 > /sys/class/pwm/pwmchip5/export
   echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period
   echo 3333333 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle
   echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable
   ```
  After launching the camera via Argus, there is video lag/stuttering. It is necessary to adjust the Power Mode to maximum/peak performance.
  ```
  ## Power mode
  sudo /usr/sbin/nvpmodel -m  0
  ```
#### Integration with SENSING Driver Source Code

1. Compile Image & dtb
   Refer to the following command to integrate Dtb and Kernel source code to your kernel

   ```
   cp camera-driver-package/source/hardware Linux_for_Tegra/source/public/$YourDir/hardware -r
   cp camera-driver-package/source/kernel Linux_for_Tegra/source/public/$YourDir/kernel -r
   ```
2. Go to the root directory of your source code and recompile

   ```
   cd  Linux_for_Tegra/source/public/$YourDir/
   export CROSS_COMPILE_AARCH64_PATH=toolchain-path
   export CROSS_COMPILE_AARCH64=toolchain-path/bin/aarch64-buildroot-linux-gnu-
   mkdir kernel_out
   ./nvbuild.sh -o $PWD/kernel_out
   ```
3. Install the newly generated Image and dtb to your nvidia device and reboot to let them take effect

   ```
   dtb:kernel_out/arch/arm64/boot/dts/nvidia/
   Image: kernel_out/arch/arm64/boot/Image
   ```
4. Install camera driver

   ```
   sudo insmod ./ko/s56-shw5gc.ko
   ```
5. Bring up the camera

   ```
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```
