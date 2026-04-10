#### Jetpack version

* Jetpack 6.2

#### Supported Camera Modules

* S56
  * support max 1 cameras to bring up at the same time

* SHW3G/SHF3G
  * support max 6 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.
SHW3G: J21/J22/J23/J24/J29/J30
S56: J25

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_SHW3Gx5_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory, run the script "install.sh""

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_SHW3Gx5_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select Configure for compatible hardware
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 S56x1 SHW3Gx2 SHF3Gx3"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"

   ```

4. After the device reboots, then enter the driver directory and run the script "load_modules.sh".

   ```
   cd /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_S56x1_SHW3Gx5_JP6.2_L4TR36.4.3
   sudo ./load_modules.sh
   ```
   When running the script, you will be prompted to select the trigger pin frequency (frame rate):
   - 1) 10 Hz
   - 2) 15 Hz
   - 3) 30 Hz (default)
   
   Select the desired frequency by entering the corresponding number. The PWM signal for frame synchronization will be configured accordingly.
   
   After the module is loaded, the device nodes /dev/video0~video9 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    J25                     /dev/video0                 S56
                            /dev/video1                 S56
    J21                     /dev/video4                 SHW3G
    J22                     /dev/video5                 SHW3G
    J23                     /dev/video2                 SHW3G
    J24                     /dev/video3                 SHW3G
    J29                     /dev/video8                 SHW3G
    J30                     /dev/video9                 SHW3G

    ```

5. Bring up the camera

6.1 For S56 Modules


  a. Without using trigger synchronization.
   ```
   ## video0
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```

  b.Use trigger synchronization (The triggering signal comes from the MCU.).
   ```
   ## video0
   v4l2-ctl -c trig_mode=1 -d /dev/video0
   argus_camera -d 0

   ```
   c. Test frame rate.
   ```
   v4l2-ctl -V --set-fmt-video=width=2560,height=1984 --set-ctrl bypass_mode=0,sensor_mode=0 --stream-mmap -d /dev/video0
   ```
   The output will show the current frame rate (e.g., `<<<<<<<<<<<<<<<< 15.00 fps`).

6.2 For SHW3G Modules
   a. Without using trigger synchronization.
   ```
   ## video2
   v4l2-ctl -c trig_mode=0 -d /dev/video2
   argus_camera -d 2
   ```

  b.Use trigger synchronization (The triggering signal comes from the MCU.).
   ```
   ## video2
   v4l2-ctl -c trig_mode=1 -d /dev/video2
   argus_camera -d 2
   ```

  c. Test frame rate.
   ```
   v4l2-ctl -V --set-fmt-video=width=2064,height=1552 --set-ctrl bypass_mode=0,sensor_mode=0 --stream-mmap -d /dev/video2
   ```
   The output will show the current frame rate (e.g., `<<<<<<<<<<<<<<<< 15.00 fps`).

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
   sudo insmod ./ko/s56-shw3gc.ko
   ```
5. Bring up the camera

   ```
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```
