#### Jetpack version

* Jetpack 6.2

#### Supported Camera Modules

* S56
  * support max 1 cameras to bring up at the same time

* AR0234
  * support max 5 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.
AR0234: J21/J23/J27/J28/J30
S56: J25

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_AR0234x5_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory, run the script "install.sh""

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_AR0234x5_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select Configure for compatible hardware
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 S56x1 AND AR0234X5"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"

   ```

4. After the device reboots, then enter the driver directory and run the script "load_modules.sh".

   ```
   cd /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_AR0234x5_JP6.2_L4TR36.4.3
   sudo ./load_modules.sh
   ```
   When running the script, you will be prompted to select the trigger pin frequency (frame rate):
   Select frame rate:
   1) 10 Hz
   2) 15 Hz
   3) 20 Hz
   4) 30 Hz (default)
   5) 60 Hz

   
   Select the desired frequency by entering the corresponding number. The PWM signal for frame synchronization will be configured accordingly.
   
   After the module is loaded, the device nodes /dev/video0~video9 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    J25                     /dev/video0                 S56
                            /dev/video1                 S56

    J21                     /dev/video4                 AR0234
    J23                     /dev/video2                 AR0234
    J27                     /dev/video6                 AR0234
    J28                     /dev/video7                 AR0234
    J30                     /dev/video9                 AR0234

    ```

5. Bring up the camera

6.1 For S56 Modules


  a. Without using trigger synchronization.
   ```
   ## video0
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```

  b.Use trigger synchronization (The triggering signal comes from the ORIN.).
   ```
   ## video0
   v4l2-ctl -c trig_mode=1 -d /dev/video0
   v4l2-ctl -c trig_mode=1 -d /dev/video1
   argus_camera -d 0
   argus_camera -d 1

   ```
   c. Test frame rate.
   ```
   v4l2-ctl -V --set-fmt-video=width=1920,height=1080 --set-ctrl bypass_mode=0,sensor_mode=0 --stream-mmap -d /dev/video0
   ```
   The output will show the current frame rate (e.g., `<<<<<<<<<<<<<<<< 15.00 fps`).

6.2 For AR0234 Modules
   a. Without using trigger synchronization.

   ```
   ## video2
   v4l2-ctl -c trig_mode=0 -d /dev/video2
   argus_camera -d 2
   ```

  b.Use trigger synchronization (The triggering signal comes from the ORIN.)
   ```
   ## video2
   v4l2-ctl -c trig_mode=1 -d /dev/video2
   argus_camera -d 2
   ```

  c. Test frame rate.
   ```
   v4l2-ctl -V --set-fmt-video=width=1920,height=1080 --set-ctrl bypass_mode=0,sensor_mode=0 --stream-mmap -d /dev/video2
   ```
   The output will show the current frame rate (e.g., `<<<<<<<<<<<<<<<< 15.00 fps`).

 7. driver interface

    7.1 version

    Using the instruction can display the current version number of the driver.

    ```
    $ v4l2-ctl -C version -d /dev/video0
    version: 'linux-36.4.3-jetpack-7.2_S56X1_AR0234X5_Date20260519_V1.0'
    ```

    7.2 Camera disconnection detection

    Just follow the instructions to operate and you will be able to display the current link status of the camera. 00 indicates that the camera is properly connected, while 01 indicates that the camera has disconnected.

    ```
    $ v4l2-ctl -C serdes_status -d /dev/video0
    serdes_status: '00'
    ```

    7.3 GMSL2 Link Detection

    Just follow the instructions to operate and you will be able to display the current gmsl status of the camera.00 indicates that the GMSL2 link has data and the data is normal. 01 indicates that the GMSL2 link has data, but the data is abnormal.

    ```
    $ v4l2-ctl -C gmsl2_status -d /dev/video0
    gmsl2_status: '00'
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
   sudo insmod ./ko/s56-ar0234.ko
   ```
5. Bring up the camera

   ```
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```