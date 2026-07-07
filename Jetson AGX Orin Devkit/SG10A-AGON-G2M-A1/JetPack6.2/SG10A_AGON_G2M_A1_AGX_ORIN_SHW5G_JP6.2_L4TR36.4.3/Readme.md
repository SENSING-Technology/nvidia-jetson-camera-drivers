#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SHW5G

  * support max 9 cameras to light up at the same time
  
  * camera port remap :
	PORT                    DEV NODE                  Camera 
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


#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_Orin_SHW5G_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG10A_AGON_G2M_A1_AGX_Orin_SHW5G_JP6.2_L4TR36.4.3
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
   3.select "Jetson Sensing Camera SHW5G GMSL2x10"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the reboot, run the "load_modules.sh" script

   ```
   chmod a+x load_modules.sh
   sudo ./load_modules.sh
   ```
6. Bring up camera(Take cam0 as an example)
  a. Without using trigger synchronization.
   ```
  v4l2-ctl -c trig_mode=0 -d /dev/video0
  argus_camera -d 0
  ```

  b.Use trigger synchronization (you need to provide an external trigger signal to the adapter board).
  ```
  v4l2-ctl -c trig_mode=1 -d /dev/video0
  argus_camera -d 0
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
   sudo insmod ./ko/shw5g.ko
   ```
5. Bring up the camera

   ```
   argus_camera -d 0
   ```
