#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-G2A-Hxxx

  * support max 8 cameras to light up at the same time
* SG2-AR0233-5200-G2A-Hxxx

  * support max 8 cameras to light up at the same time
* SG2-OX03CC-5200-G2F

  * support max 8 cameras to light up at the same time
* SG3S-ISX031C-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time
* SG3S-ISX031C-GMSL2F-Hxxx

  * support max 8 cameras to light up at the same time
* SG3S-OX03JC-G2F

  * support max 8 cameras to light up at the same time 
* SG5-IMX490C-5300-GMSL2-Hxxx

  * support max 5 cameras to light up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 4 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 4 cameras to light up at the same time
* OMSBDAAN-AA

  * support max 4 cameras to light up at the same time
* OMSBDAAN-AB	

  * support max 4 cameras to light up at the same time
* DMSBBFAN

  * support max 4 cameras to light up at the same time
* SG2-AR0231C-0202-GMSL-1080P

  * support max 8 cameras to light up at the same time 
#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP5.1.2_L4TR35.4.1
   ```
3. Give executable permissions to the script "quick_bring_up.sh" and execute the script

   ```
   chmod a+x *.sh

   //If you are using the Jetson AGX Orin 32G version, then execute:
   sudo ./quick_bring_up_32g.sh

   //If you are using the Jetson AGX Orin 64G version, then execute:
   sudo ./quick_bring_up_64g.sh
   ```
4. When you run the "quick_bring_up.sh" script for the first time, it will install the Image and DTB. After the script completes, you need to reboot the device for the Image and DTB to take effect.

   ```
   sudo reboot
   ```
5. After the device reboots, first install v4l2-ctl, then enter the driver directory and run the script "quick_bring_up.sh".

   ```
   //install v4l2-ctl
   sudo apt update
   sudo apt install v4l-utils 

   //If you are using the Jetson AGX Orin 32G version, then execute:
   sudo ./quick_bring_up_32g.sh

   //If you are using the Jetson AGX Orin 64G version, then execute:
   sudo ./quick_bring_up_64g.sh
   ```
6. Select the camera type for each group of channels (cam0 and cam1 as a group, cam2 and cam3 as a group, and so on). For example:

    * cam0, cam1: Two Pilot640 cameras
    * cam2, cam3: Two SG2-AR0233-5300-GMSL2 cameras
    * cam4, cam5: Two SG3-ISX031C-GMSL2F cameras
    * cam6, cam7: Two SG8-AR0820C-5300-GMSL2 cameras

   ```
   This package is use for Sensing SG8A-ORING-GMSL on JetPack-5.1.2-L4T-35.4.1
   Press select your first group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)
   0
   Press select your second group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)
   1
   Press select your third group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)
   2
   Press select your fourth group camera type:(0-GMSL1, 1-GMSL2_6G, 2-GMSL2_3G)
   1
   ```
7. Then, select any channel and confirm the camera model to start the camera.
   ```
   Press select your yuv camera type:
   0:SG2-IMX390C-5200-GMSL2
   1:SG2-AR0233-5300-GMSL2
   2:SG3-ISX031C-GMSL2
   3:SG3-ISX031C-GMSL2F
   4:SG5-IMX490C-5200-GMSL2
   5:OMSBDAAN
   6:SG8-AR0820C-5300-GMSL2
   7:SG8-OX08BC-5300-GMSL2
   8:SG2-AR0231C-0202-GMSL-1080P
   9:Pilot640
   1
   Press select your camera port [0-7]:
   2
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
   sudo insmod ./ko/sgx-yuv-gmsl2.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
