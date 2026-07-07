#### Jetpack version

* Jetpack 6.2

#### Supported Camera Modules

* Intel RealSense D457
  * support max 4 cameras to bring up at the same time

* SHW3G/SHN3G
  * support max 6 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.
SHW3G: J21/J22/J27/J28/J29/J30
D457: J23/J24/J25/J26/

Note:
For a single D457 camera, connect it to J24 if using ports J23 and J24.
For a single D457 camera, connect it to J26 if using ports J25 and J26.

2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_D457x4_SHW3Gx6_JP6.2_L4TR36.4.3
   ```
3. Enter the driver directory, run the script "install.sh""

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_D457x4_SHW3Gx6_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson 40pin Header"
   2.select "Configure header pins manually"
   3.select "pwm1 pwm5 pwm8"
   4.select  Two "back"
   5.select "Configure Jetson AGX CSI Connector"
   6.select "Configure for compatible hardware"
   7.select "Jetson Sensing Camera D457 And SHW3G x6"
   8.select "Save pin changes"
   9.select "Save and reboot to reconfigure pins"
   ```

5. After the device reboots, install v4l-utils argus_camera plugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev v4l-utils busybox -y
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   cd /usr/src/jetson_multimedia_api/argus/
   sudo mkdir build && cd build
   sudo cmake ..
   sudo make -j8
   sudo make install

   cd /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_D457x4_SHW3Gx6_JP6.2_L4TR36.4.3
   sudo ./load_module.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video5 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    J21                     /dev/video0                 SHW3G(EEPROM_ADDR:0x31)
    J22                     /dev/video1                 SHW3G(EEPROM_ADDR:0x32)
    J27                     /dev/video2                 SHW3G(EEPROM_ADDR:0x31)
    J29                     /dev/video3                 SHW3G(EEPROM_ADDR:0x32)
    J29                     /dev/video4                 SHW3G(EEPROM_ADDR:0x33)
    J30                     /dev/video5                 SHW3G(EEPROM_ADDR:0x34)

    J23                     /dev/video-rs-color-0       D457
                            /dev/video-rs-color-0
                            /dev/video-rs-color-md-0
                            /dev/video-rs-depth-md-0
                            /dev/video-rs-imu-0
                            /dev/video-rs-ir-0

    J24                     /dev/video-rs-color-1       D457
                            /dev/video-rs-color-1
                            /dev/video-rs-color-md-1
                            /dev/video-rs-depth-md-1
                            /dev/video-rs-imu-1
                            /dev/video-rs-ir-1

    J25                     /dev/video-rs-color-2       D457
                            /dev/video-rs-color-2
                            /dev/video-rs-color-md-2
                            /dev/video-rs-depth-md-2
                            /dev/video-rs-imu-2
                            /dev/video-rs-ir-2

    J26                     /dev/video-rs-color-3       D457
                            /dev/video-rs-color-3
                            /dev/video-rs-color-md-3
                            /dev/video-rs-depth-md-3
                            /dev/video-rs-imu-3
                            /dev/video-rs-ir-3
    ```

6. Bring up the camera

6.1 For SHW3G/SG3-IMX900-G2G Modules


  a. Without using trigger synchronization.
   ```
   ## video0
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   argus_camera -d 0
   ```

  b.Use trigger synchronization (you need to provide an external trigger signal to the adapter board).
   ```
   ## video0
   v4l2-ctl -c trig_mode=1 -d /dev/video0
   argus_camera -d 0
   ```
6.2 For D457 Modules

6.2.1 Installing librealsense on Jetson (for D457 cameras)

Note:
- Refer to the official guide for detailed instructions:
  https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_jetson.md

a. Register the server's public key
   ```
   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
   ```

b. Add the server to the list of repositories
   ```
   sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u
   ```

c. Install the SDK packages
   ```
   sudo apt install librealsense2-udev-rules
   sudo apt install librealsense2-utils
   sudo apt install librealsense2-dev
   ```

6.2.1 Bring up the D457 Camera
   ```
   realsense-viewer
   ```
   By default, only one D457 camera is active. Click "Add Source" in the realsense-viewer GUI to add other cameras.


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

   1.select "Configure Jetson 40pin Header"
   2.select "Configure header pins manually"
   3.select "pwm1 pwm5 pwm8"
   4.select  Two "back"
   5.select "Configure Jetson AGX CSI Connector"
   6.select "Configure for compatible hardware"
   7.select "Jetson Sensing Camera D457 And SHW3G x6"
   8.select "Save pin changes"
   9.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/shw3g.ko
   sudo insmod ko/max9296.ko
   sudo insmod ko/max9295.ko
   sudo insmod ko/d4xx.ko
   ```
7. Bring up the camera

   ```
   ## Video0
    argus_camera -d 0

   ## Video1
    argus_camera -d 1
    ...
   ```
