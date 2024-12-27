#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-G2A-Hxxx

  * support max 2 cameras to light up at the same time
* SG2-AR0233-5200-G2A-Hxxx

  * support max 2 cameras to light up at the same time
* SG2-OX03CC-5200-GMSL2F-Hxxx

  * support max 2 cameras to light up at the same time
* SG3-ISX031C-GMSL2-Hxxx

  * support max 2 cameras to light up at the same time
* SG3-ISX031C-GMSL2F-Hxxx

  * support max 2 cameras to light up at the same time
* SG3S-OX03JC-G2F-Hxxx

  * support max 2 cameras to light up at the same time
* SG4-IMX490C-5300-GMSL2-Hxxx

  * support max 2 cameras to light up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 2 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 2 cameras to light up at the same time

#### Quick Bring Up

> Take the SG2-IMX390C-5200-GMSL2-Hxxx camera as an exampleSG2-IMX390C-MIPI-HXXX

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG2A-G2-M4L-F_OrinNX_OrinNano_YUV_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG2A-G2-M4L-F_OrinNX_OrinNano_YUV_JP5.1.2_L4TR35.4.1
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
   This package is use for SG2A-G2-M4L-F Jetson_Linux_R35.4.1
   1.sgx-yuv-gmsl1
   2.sgx-yuv-gmsl2
   Press select your camera type:
   2
   ```

   At this point, you should type 1 to select your camera type and then hit Enter
5. After the device reboots, enter the driver directory and run the script "quick_bring_up.sh"

   ```
   sudo ./quick_bring_up.sh
   ```
6. Select the camera type. Select the sgx-yuv-gmsl2 camera type, then select SG2-IMX390C-5200-GMSL2,
   and finally enter 0-15 the camera port you are connected to to turn on the camera.

   ```
   This package is use for SG2A-G2-M4L-F Jetson_Linux_R35.4.1
   1:sgx-yuv-gmsl1
   2:sgx-yuv-gmsl2
   3:sg3s-imx623c-gmsl2f
   4:sg8-imx728c-g2g
   Press select your camera type:
   2
   Press select your yuv camera type:
   0:SG2-IMX390C-5200-GMSL2
   1:SG2-AR0233-5300-GMSL2
   2.SG2-OX03CC-5200-GMSL2F
   3.SG3-ISX031C-GMSL2F
   4.SG5-IMX490C-5200-GMSL2
   5.SG8-AR0820C-5300-GMSL2
   6.SG8-OX08BC-5300-GMSL2
   0
   Press select your camera port [0-1]:
   0
   ready bring up camera
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
   sudo insmod ./ko/max9295.ko
   sudo insmod ./ko/max9296.ko
   sudo insmod ./ko/sgx-yuv-gmsl2.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
