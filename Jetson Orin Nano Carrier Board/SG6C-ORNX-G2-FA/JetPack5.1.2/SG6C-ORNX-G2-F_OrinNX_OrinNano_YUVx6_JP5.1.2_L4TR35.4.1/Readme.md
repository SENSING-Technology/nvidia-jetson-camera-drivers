#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-G2A-Hxxx

  * support max 6 cameras to light up at the same time
* SG2-AR0233-5200-G2A-Hxxx

  * support max 6 cameras to light up at the same time

* SG5-IMX490C-5300-GMSL2-Hxxx

  * support max 5 cameras to light up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 4 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 4 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG6C-ORNX-G2-F_OrinNX_OrinNano_YUVx6_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG6C-ORNX-G2-F_OrinNX_OrinNano_YUVx6_JP5.1.2_L4TR35.4.1
   ```
3. Grant execute permissions to all scripts, then run the "install.sh" script and wait for the system to reboot

   ```
   chmod a+x *.sh
   ./install.sh
   ```
4. After the reboot, run the "quick_bring_up.sh" script

   ```
   chmod a+x quick_bring_up.sh
   sudo ./quick_bring_up.sh
   ```
5. Select the camera resolution. Select your camera port,then select the trigger mode, and finally start the camera.
   For example:

   ```
   This package is use for Sensing SG6C_ORIN_GMSL2 on JetPack-5.1.2-L4T-35.4.1

   1:1920x1080
   2:2880x1860
   3:3840x2160
   Press select your YUV camera resolution:
   1
   Press select your camera port [0-5]:
   0
   Press select your trigger mode [0:Internal trigger, 1:External trigger]:
   1
   Start bring up camera!
   ```
   If you select the "External Trigger" mode, you need to input the trigger signal through the IO07 pin on the carrier board. 
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
   sudo insmod ./ko/fzcam.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
