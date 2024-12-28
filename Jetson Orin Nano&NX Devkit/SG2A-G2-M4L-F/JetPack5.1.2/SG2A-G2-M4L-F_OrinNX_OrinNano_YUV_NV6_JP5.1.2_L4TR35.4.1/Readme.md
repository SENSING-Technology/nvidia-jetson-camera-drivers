#### Supported SENSING Camera Modules

* SGN-NV6-G2F-Hxxx

  * support max 1 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG2A-G2-M4L-F_OrinNX_OrinNano_YUV_NV6_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG2A-G2-M4L-F_OrinNX_OrinNano_YUV_NV6_JP5.1.2_L4TR35.4.1
   ```
3. Give executable permissions to the script "update.sh" and execute it

   ```
   chmod a+x update.sh
   sudo ./update.sh
   ```
4. reboot

   ```
   sudo reboot
   ```
5. After the device reboots, enter the driver directory and run the script "quick_bring_up.sh"

   ```
   cd SG2A-G2-M4L-F_OrinNX_OrinNano_YUV_NV6_JP5.1.2_L4TR35.4.1
   chmod a+x quick_bring_up.sh
   sudo ./quick_bring_up.sh
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
   sudo insmod ./ko/max9295.ko
   sudo insmod ./ko/max9296.ko
   sudo insmod ./ko/nv_tc358748.ko
   ```
5. Bring up the camera

   ```
   v4l2-ctl --set-ctrl bypass_mode=0,sensor_mode=3 -d /dev/video0
   gst-launch-1.0 v4l2src device=/dev/video0 ! video/x-raw,format=UYVY,width=640,height=512,framerate=50/1 ! xvimagesink -ev
   ```
