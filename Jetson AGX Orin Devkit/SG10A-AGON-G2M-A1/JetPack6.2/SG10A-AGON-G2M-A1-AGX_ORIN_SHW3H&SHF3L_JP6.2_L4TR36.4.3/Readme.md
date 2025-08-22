#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SHW3H

  * support max 8 cameras to light up at the same time
* SHF3L

  * support max 10 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A-AGON-G2M-A1-AGX_ORIN_SHW3H&SHF3L_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG10A-AGON-G2M-A1-AGX_ORIN_SHW3H&SHF3L_JP6.2_L4TR36.4.3
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
   3.select "Jetson Sensing Camera SHW3H SHF3Lx10"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the reboot, run the "quick_bring_up.sh" script

   ```
   chmod a+x quick_bring_up.sh
   sudo ./quick_bring_up.sh
   ```
6. Select the camera resolution. Select your camera port,then select the trigger mode, and finally start the camera.
   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                   Camera
    J25                    /dev/video0                 SHW3H/SHF3L
    J26                    /dev/video1                 SHW3H/SHF3L
    J23                    /dev/video2                 SHW3H/SHF3L
    J24                    /dev/video3                 SHW3H/SHF3L
    J21                    /dev/video4                 SHW3H/SHF3L
    J22                    /dev/video5                 SHW3H/SHF3L
    J27                    /dev/video6                 SHW3H/SHF3L
    J28                    /dev/video7                 SHW3H/SHF3L
    J29                    /dev/video8                 SHF3L     
    J30                    /dev/video9                 SHF3L
    ```
   For example:

   ```
   This package is use for Sensing SG10A-AGON-G2M-A1-AGX_ORIN_SHW3H&SHF3L_JP6.2_L4TR36.4.3
   1:shf3l
   2:shw3h
   Press select your YUV camera:
   1
   Please select your camera resolution:
   1:1280x1280
   2:1920x1536
   1
   Press select your camera port [0-9]:
   0
   Select your trigger mode [0:Internal trigger, 1:External trigger]:
   0
   Start bring up camera!

   ```
   If you choose the "External Trigger" mode, you need to provide a trigger signal to the adapter board. 
   Or you can generate the trigger signal through AGX.
   ```
   # 30HZ
   sudo su
   echo 0 > /sys/class/pwm/pwmchip5/export
   echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period
   echo 3333333 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle
   echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable
   ```

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
4. Install camera driver

   ```
   sudo insmod ./ko/shw3h-shf3l.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
