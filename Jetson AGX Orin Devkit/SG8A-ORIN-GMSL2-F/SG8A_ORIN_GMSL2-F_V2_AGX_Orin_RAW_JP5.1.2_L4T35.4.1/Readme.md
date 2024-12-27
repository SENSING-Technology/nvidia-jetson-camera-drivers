#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG2-AR0233C-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time
* SG2-IMX390C-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time
* SG2-OX03CC-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time
* SG5-IMX490C-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time
* SG8-AR0820C-G2A-Hxxx

  * support max 7 cameras to light up at the same time
* SG8-IMX728C-GMSL2-Hxxx

  * support max 7 cameras to light up at the same time
* SG8-IMX728C-G2G-Hxxx

  * support max 7 cameras to light up at the same time
* SG8-OX08BC-GMSL2-Hxxx

  * support max 7 cameras to light up at the same time
* SG8-OX08BC-G2A-Hxxx

  * support max 7 cameras to light up at the same time
* SG8-1H1-G2A-Hxxx

  * support max 8 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG8A_ORIN_GMSL2-F_V2_AGX_Orin_RAW_JP5.1.2_L4T35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_RAW_JP5.1.2_L4T35.4.1
   ```
3. Bring up camera with release Image, dtb and ko

   backup device Image and dtb, please refer to /boot/extlinux/extlinux.conf on Jetson device

   ```
   sudo cp driver_package_folder/boot/Image /boot/Image
   sudo cp driver_package_folder/dtb/[camera_module_name]/xxxx.dtb /boot/dtb/kernel_xxxx.dtb
   sync
   ####
   for Jetson Agx Orin Devkit, xxxx is tegra234-p3701-0000-p3737-0000
   for Jetson Agx Orin 32GB, xxxx is tegra234-p3701-0004-p3737-0000
   for Jetson Agx Orin 64GB, xxxx is tegra234-p3701-0005-p3737-0000
   ```
4. reboot device
   For example:

   ```
   sudo reboot
   ```
5. Install camera driver
   For example:

   ```
   cd driver_package_folder/ko/

   sudo insmod max9295.ko
   sudo insmod max9296.ko
   sudo insmod sg2-ar0233c-gmsl2.ko

   # Special specification #
   for camera SG8-IMX728C-G2G-Hxxx, need trans ser_name when insmod ko
   sudo insmod sg8-imx728c-gmsl2.ko ser_name="MAX96717"
   ```
6. Bring up the camera with gst-launch-1.0 tool

   ```
   gst-launch-1.0 nvarguscamerasrc sensor-id=0 ! 'video/x-raw(memory:NVMM),framerate=30/1,format=NV12' ! nvvidconv ! xvimagesink
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
   sudo insmod sg2-ar0233c-gmsl2.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 nvarguscamerasrc sensor-id=0 ! 'video/x-raw(memory:NVMM),framerate=30/1,format=NV12' ! nvvidconv ! xvimagesinkgst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
