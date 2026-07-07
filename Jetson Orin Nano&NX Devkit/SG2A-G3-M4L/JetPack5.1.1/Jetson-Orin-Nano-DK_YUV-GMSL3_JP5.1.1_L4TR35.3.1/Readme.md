#### Jetpack version

* Jetpack 5.1.1

#### Supported SENSING Camera Modules

* SG8S-AR0820C-5300-G3A-HXXX

  * support max 1 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/Jetson-Orin-Nano-DK_YUV-GMSL3_JP5.1.1_L4TR35.3.1
   ```
2. Enter the driver directory

   ```
   cd Jetson-Orin-Nano-DK_YUV-GMSL3_JP5.1.1_L4TR35.3.1
   ```
3. Give executable permissions to the script "quick_bring_up.sh" and execute the script

   ```
   chmod a+x quick_bring_up.sh
   sudo ./quick_bring_up.sh
   ```
4. Select the camera type. This step will install Image and DTB, after the script run complete.
   You need to reboot the device to let the Image and DTB take effect.
   For example:

   ```
   This package is use for Jetson_Linux_R35.3.1
   1.sgx-yuv-gmsl3
   Press select your camera type:
   1
   ```

   At this point, you should type 1 to select your camera type and then hit Enter
5. After the device reboots, enter the driver directory and run the script "quick_bring_up.sh"

   ```
   sudo ./quick_bring_up.sh
   ```
6. Select the camera type. Select the sgx-yuv-gmsl3 camera type,  finally enter 0-1 the camera port you are connected to to turn on the camera.

   ```
   This package is use for Jetson_Linux_R35.3.1
   1.sgx-yuv-gmsl3
   Press select your camera type:
   1
   Press select your camera port [0-1]:
   1
   ready bring up camera
   Use the following command to light the camera!
   gst-launch-1.0 v4l2src device=/dev/video1  ! xvimagesink -ev
   ```
7. Select one of the commands prompted above to light the camera

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
   sudo insmod ./ko/max96792.ko
   sudo insmod ./ko/max96793.ko
   sudo insmod ./ko/sgx-yuv-gmsl3.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev
   ```
