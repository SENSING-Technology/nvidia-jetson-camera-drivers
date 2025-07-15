#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* Astra S36

  * support max 2 cameras to bring up at the same time
* SHF3L/SG3S-ISX031C-GMSL2F
  * support max 6 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.
SHF3L/SG3S-ISX031C-GMSL2F: J25/J26/J27/J28/J29/J30
Astra S36: J21/J23

2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_S36_SHF3L_JP6.2_L4TR36.4.3
   ```
3. Enter the driver directory, run the script "install.sh""

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_S36_SHF3L_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing Camera S36x2 and SHF3LX6"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the device reboots, modify load_module.sh file
for SHF3L + S36 Module
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video8 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video9 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   ```

for SG3S-ISX031C-GMSL2F + S36 Module
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=2,gmsl_mode=0,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   v4l2-ctl -d /dev/video8 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   v4l2-ctl -d /dev/video9 -c sensor_mode=2,gmsl_mode=1,trig_mode=0
   ```

6. Install v4l-utils and busyboxplugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install v4l-utils busybox
   sudo ./load_module.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video9 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    J25                     /dev/video0                 SHF3L
    J26                     /dev/video1                 SHF3L
    J23                     /dev/video2                 S36(Sensor 0)
                            /dev/video3                 S36(Sensor 1)
    J21                     /dev/video4                 S36(Sensor 0)
                            /dev/video5                 S36(Sensor 1)
    J27                     /dev/video6                 SHF3L
    J28                     /dev/video7                 SHF3L
    J29                     /dev/video8                 SHF3L
    J30                     /dev/video9                 SHF3L
    ```

6. Bring up the camera

   ```
    ## Video0
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

    ## Video1
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

    ## Video2
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

    ## Video3
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

    ## Video4
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

    ## Video5
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

    ## Video6
    gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

    ## Video7
    gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev

    ## Video08
    gst-launch-1.0 v4l2src device=/dev/video8 ! xvimagesink -ev

    ## Video8
    gst-launch-1.0 v4l2src device=/dev/video9 ! xvimagesink -ev
   ```


#### Integration with SENSING Driver Source Code

1. Compile Image & dtb
   Refer to the following command to integrate Dtb and Kernel source code to your kernel

   ```
   cp camera-driver-package/source/hardware Linux_for_Tegra/source/hardware -r
   cp camera-driver-package/source/kernel Linux_for_Tegra/source/kernel -r
   cp camera-driver-package/source/nvidia-oot Linux_for_Tegra/source/nvidia-oot -r
   ```
2. Go to the root directory of your source code and recompile

   ```
   cd <install-path>/Linux_for_Tegra/source
   export CROSS_COMPILE_AARCH64=toolchain-path/bin/aarch64-buildroot-linux-gnu-
   export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
   export INSTALL_MOD_PATH=<install-path>/Linux_for_Tegra/rootfs/
   make -C kernel
   make modules
   make dtbs
   sudo -E make install -C kernel

   cp kernel/kernel-jammy-src/arch/arm64/boot/Image <install-path>/Linux_for_Tegra/kernel/Image
   cp nvidia-oot/device-tree/platform/generic-dts/dtbs/* <install-path>/Linux_for_Tegra/kernel/dtb/
   ```
3. Install the newly generated Image and dtb to your nvidia device and reboot to let them take effect

   ```
   dtb:nvidia-oot/device-tree/platform/generic-dts/dtbs/
   Image: kernel/kernel-jammy-src/arch/arm64/boot/

   tegra-camera.ko:nvidia-oot/drivers/media/platform/tegra/camera/
   nvhost-nvcsi-t194.ko:nvidia-oot/drivers/video/tegra/host/nvcsi/
   ```
4. Copy the image,dtb,ko generated by the above compilation to the corresponding location of jetson

   ```
   sudo cp *.dtbo /boot/
   sudo cp Image /boot/Image
   sudo cp tegra-camera.ko /lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
   sudo cp nvhost-nvcsi-t194.ko /lib/modules/5.15.148-tegra/updates/drivers/video/tegra/host/nvcsi/
   ```
5. Select the device tree you installed

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing Camera S36x2 and SHF3LX6"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/sgx_yuv_cam.ko
   ```
7. Bring up the camera

   ```
   ## Video0
   v4l2-ctl -d /dev/video0 -c sensor_mode=?,gmsl_mode=?,trig_mode=?
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## Video1
    v4l2-ctl -d /dev/video1 -c sensor_mode=?,gmsl_mode=?,trig_mode=?
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev
    ...
   ```