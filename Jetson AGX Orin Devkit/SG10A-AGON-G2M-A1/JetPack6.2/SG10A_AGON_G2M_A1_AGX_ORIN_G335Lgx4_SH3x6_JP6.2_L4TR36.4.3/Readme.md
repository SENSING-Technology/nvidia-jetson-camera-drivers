#### Jetpack version

* Jetpack 6.2

#### Supported Camera Modules

* Gemini 335Lg

  * support max 4 cameras to bring up at the same time
* SHF3L/SG3S-ISX031C-GMSL2F
  * support max 6 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.
SHF3L: J21/J22/J27/J28/J29/J30
335Lg: J23/J24/J25/J26/

2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_G335Lgx4_SHF3Lx6_JP6.2_L4TR36.4.3
   ```
3. Enter the driver directory, run the script "install.sh""

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_G335Lgx4_SHF3Lx6_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing Camera G335Lg And SH3 x6"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the device reboots, install v4l-utils plugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install v4l-utils busybox
   sudo ./load_module.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video3 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    J21                     /dev/video0                 SHF3L
    J22                     /dev/video1                 SHF3L
    J27                     /dev/video2                 SHF3L
    J29                     /dev/video3                 SHF3L
    J29                     /dev/video4                 SHF3L
    J30                     /dev/video5                 SHF3L

    J25                     /dev/video6                 G335Lg
                            /dev/video7
                            /dev/video8
                            /dev/video9
                            /dev/video10
                            /dev/video11
                            /dev/video12
                            /dev/video13

    J26                     /dev/video14                G335Lg
                            /dev/video15
                            /dev/video16
                            /dev/video27
                            /dev/video18
                            /dev/video19
                            /dev/video20
                            /dev/video21

    J23                     /dev/video22                G335Lg
                            /dev/video23
                            /dev/video24
                            /dev/video25
                            /dev/video26
                            /dev/video27
                            /dev/video28
                            /dev/video29

    J24                     /dev/video30                G335Lg
                            /dev/video31
                            /dev/video32
                            /dev/video33
                            /dev/video34
                            /dev/video35
                            /dev/video35
                            /dev/video37
    ```

6. Bring up the camera

6.1 For SHF3L/SG3S-ISX031C-GMSL2F Modules
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
   ```
6.2 For G335Lg Modules

6.2.1 Get the Orbbec Viewer

   https://github.com/orbbec/OrbbecSDK_v2/releases

   It is recommended to download the following version or a newer one.
   ```
   OrbbecViewer_v2.4.3_202505191359_e32b948_linux_aarch64.zip
   ```

6.2.1 Bring up the G335Lg Camera
   Run the following command to launch the Orbbec Viewer and preview the camera image
   ```
   sudo ./OrbbecViewer
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
   3.select "Jetson Sensing Camera G335Lg And SH3 x6"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/serdes.ko
   sudo insmod ko/fzcam.ko
   sudo insmod ko/serdesa.ko
   sudo insmod ko/fzcama.ko
   sudo insmod ko/max9296.ko
   sudo insmod ko/max9295.ko
   sudo insmod ko/g2xx.ko
   ```
7. Bring up the camera

   ```
   ## Video0
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## Video1
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev
    ...
   ```