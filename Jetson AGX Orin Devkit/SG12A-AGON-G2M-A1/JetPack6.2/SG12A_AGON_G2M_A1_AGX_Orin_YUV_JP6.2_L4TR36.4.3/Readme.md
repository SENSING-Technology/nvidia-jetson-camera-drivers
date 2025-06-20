#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-G2A-Hxxx

  * support max 12 cameras to light up at the same time
* SG2-AR0233C-5200-G2A-Hxxx

  * support max 12 cameras to light up at the same time
* SG2-OX03CC-5200-G2F-Hxxx

  * support max 12 cameras to light up at the same time
* SG3-ISX031C-GMSL2F-Hxxx

  * support max 12 cameras to light up at the same time
* SG5-IMX490C-5300-GMSL2-Hxxx

  * support max 10 cameras to light up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 8 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 8 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG12A_AGON_G2M_A1_AGX_Orin_YUV_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG12A_AGON_G2M_A1_AGX_Orin_YUV_JP6.2_L4TR36.4.3
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
   3.select "Jetson Sensing YUV GMSL2x12""
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the reboot, run the "quick_bring_up.sh" script

   ```
   chmod a+x quick_bring_up.sh
   sudo ./quick_bring_up.sh
   ```
6. Select the camera resolution. Select your camera port,then select the trigger mode, and finally start the camera.
   For example:

   ```
   This package is use for Sensing SG12A_AGON_G2M_A1 on JetPack-6.2-L4T-36.4.3
   1:1920x1080
   2:1920x1536
   3:2880x1860
   4:3840x2160
   Press select your YUV camera resolution:
   1
   Press select your camera port [0-11]:
   0
   Please select your camera serializer type [0: GMSL2_6G, 1: GMSL2_3G]:
   0
   Select your trigger mode [0:Internal trigger, 1:External trigger]:
   0
   Start bring up camera!
   ```
   If you select the "External Trigger" mode, you need to provide a trigger signal to the adapter board. 
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
   sudo insmod ./ko/sgx-yuv-gmsl2.ko
   ```
5. Bring up the camera

   ```
   gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
   ```
