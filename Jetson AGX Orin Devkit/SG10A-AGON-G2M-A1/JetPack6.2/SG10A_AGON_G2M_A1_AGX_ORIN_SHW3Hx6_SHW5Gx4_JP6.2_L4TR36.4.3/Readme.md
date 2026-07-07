#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SHW3H

  * support max 6 cameras to light up at the same time
* SHW5G

  * support max 3 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_SHE3Hx6_SHW5Gx4_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_SHE3Hx6_SHW5Gx4_JP6.2_L4TR36.4.3
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
   3.select "Jetson Sensing Camera SHW3Hx6 SHW5Gx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. Install the Argus sample tool `argus_camera` (one-time setup).  
   You only need to do this once unless you re-flash the system or `/usr/src/jetson_multimedia_api` is removed/updated.
   ```
   sudo apt update
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   cd /usr/src/jetson_multimedia_api/argus/
   sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev
   sudo mkdir build && cd build
   # compile
   sudo cmake ..
   sudo make -j8
   sudo make install
   ```
   
6. After the reboot, run the "load_modules.sh" script

   ```
   chmod a+x load_modules.sh
   sudo ./load_modules.sh
   ```
7. Select the camera resolution. Select your camera port,then select the trigger mode, and finally start the camera.
   The correspondence between CAM ports and device nodes is as follows

    ```
	PORT                    DEV NODE                  Camera 
	J25                    /dev/video0                 SHW3H
	J26                    /dev/video1                 SHW3H
	J23                    /dev/video2                 SHW3H
	J24                    /dev/video3                 SHW3H
	J21                    /dev/video4                 SHW3H
	J22                    /dev/video5                 SHW3H
	J27                    /dev/video6                 SHW5G
	J28                    /dev/video7                 SHW5G
	J29                    /dev/video8                 SHW5G
	J30                    /dev/video9                 SHW5G
    ```
   For example:

   ```
   This package is use for Sensing SG10A_AGON_G2M_A1_AGX_ORIN_SHE3Hx6_SHW5Gx4_JP6.2_L4TR36.4.3
   1:shw3h
   2:shw5g
   Press select your camera:
   1
   Please select your camera resolution:
   1:1920x1536
   1
   Press select your camera port [0-5]:
   0
   Select your trigger mode [0:Internal trigger, 1:External trigger]:
   0
   Start bring up camera!
   ```
8. If you choose the "External Trigger" mode, you need to provide a trigger signal to the adapter board. Or you can generate the trigger signal through AGX. The trigger signal interface is J19, with pins from top to bottom labeled as Pin1 through Pin4. Pin2 and Pin4 are connected together.

```
# 30HZ
sudo su
echo 0 > /sys/class/pwm/pwmchip5/export
echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period
echo 3333333 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle
echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable

```
Select "external trigger" mode, refer to the gpio-pwm.sh script

#### Integration with SENSING Driver Source Code

1. Compile Image & dtb
   Refer to the following command to integrate Dtb and Kernel source code to your kernel

   ```
   cp camera-driver-package/source/hardware Linux_for_Tegra/source/public/$YourDir/hardware -r
   cp camera-driver-package/source/kernel Linux_for_Tegra/source/public/$YourDir/kernel -r
   cp camera-driver-package/source/nvidia-oot Linux_for_Tegra/source/public/$YourDir/nvidia-oot -r

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

4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select Configure for compatible hardware
   3.select "Jetson Sensing Camera SHW3Hx6 SHW5Gx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. Install camera driver

   ```
   sudo insmod ./ko/pwm-gpio.ko
   sudo insmod ./ko/shw3h_shw5g.ko
   ```
6. Bring up the camera
   Use different commands depending on the camera module type.
   
   SHW3H
   (Preview via V4L2 + GStreamer)
   ```
   v4l2-ctl -V --set-fmt-video=width=1920,height=1536 --set-ctrl sensor_mode=3,trig_mode=2 -d /dev/video0    
   gst-launch-1.0 v4l2src device=/dev/video0 ! video/x-raw,width=1920,height=1536,format=UYVY   ! xvimagesink -ev
   ```

   SHW5G
   (Preview via Argus sample application)
   ```
   v4l2-ctl -V --set-fmt-video=width=1920,height=1536 --set-ctrl sensor_mode=3,trig_mode=0 -d /dev/video5    
   argus_camera -d 5
   
   ```

