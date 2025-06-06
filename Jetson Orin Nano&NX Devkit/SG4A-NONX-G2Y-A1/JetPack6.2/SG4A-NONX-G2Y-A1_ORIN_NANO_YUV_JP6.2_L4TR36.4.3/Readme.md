#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SG2-AR0144-8310-GMSL-Hxxx

  * support max 4 cameras to light up at the same time
* SG2-AR0231-0202-GMSL-Hxxx

  * support max 4 cameras to light up at the same time
* SG2-IMX390C-5200-G2A-Hxxx

  * support max 4 cameras to light up at the same time
* SG2-AR0233-5200-G2A-Hxxx

  * support max 4 cameras to light up at the same time
* SG2-OX03CC-5200-GMSL2F-Hxxx

  * support max 4 cameras to light up at the same time
* SG3-ISX031C-GMSL2-Hxxx

  * support max 4 cameras to light up at the same time
* SG3-ISX031C-GMSL2F-Hxxx

  * support max 4 cameras to light up at the same time
* SG5-IMX490C-5300-GMSL2-Hxxx

  * support max 3 cameras to light up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 2 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 2 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG4A_NONX_G2Y_A1_ORIN_NANO_YUV_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory

   ```
   cd SG4A_NONX_G2Y_A1_ORIN_NANO_YUV_JP6.2_L4TR36.4.3
   ```
3. Grant execute permissions to all scripts, then run the "install.sh" script

   ```
   chmod a+x *.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson 24pin CSI Connector"
   2.select Configure for compatible hardware
   3.select "Jetson Sensing YUV GMSLx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
5. If step four cannot be executed, you can manually modify the extlinux.conf file to apply the device tree.

   ```
   sudo vi /boot/extlinux/extlinux.conf
   ```
6. Modify the file to the following content, then reboot.

   ```
   TIMEOUT 30
   DEFAULT JetsonIO

   MENU TITLE L4T boot options

   LABEL primary
         MENU LABEL primary kernel
         LINUX /boot/Image
         INITRD /boot/initrd
         APPEND ${cbootargs} root=PARTUUID=1171a64d-f038-4b7a-91a9-cb3d448d880c rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0

   # When testing a custom kernel, it is recommended that you create a backup of
   # the original kernel and add a new entry to this file so that the device can
   # fallback to the original kernel. To do this:
   #
   # 1, Make a backup of the original kernel
   #      sudo cp /boot/Image /boot/Image.backup
   #
   # 2, Copy your custom kernel into /boot/Image
   #
   # 3, Uncomment below menu setting lines for the original kernel
   #
   # 4, Reboot

   # LABEL backup
   #    MENU LABEL backup kernel
   #    LINUX /boot/Image.backup
   #    INITRD /boot/initrd
   #    APPEND ${cbootargs}

   LABEL JetsonIO
         MENU LABEL Custom Header Config: <CSI Jetson Sensing YUV GMSLx4>
         LINUX /boot/Image
         FDT /boot/dtb/kernel_tegra234-p3768-0000+p3767-0005-nv.dtb
         INITRD /boot/initrd
         APPEND ${cbootargs} root=PARTUUID=1171a64d-f038-4b7a-91a9-cb3d448d880c rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0
         OVERLAYS /boot/tegra234-camera-yuv-gmslx4-overlay.dtbo
   ```
7. After the device reboots, install v4l-utils plugins, then enter the driver directory and run the script "quick_bring_up.sh".

   ```
   sudo apt update
   sudo apt-get install v4l-utils
   sudo ./quick_bring_up.sh
   ```
8. You can configure the serializer type for each camera, then select Bring up one camera

   ```
   This package is use for Sensing SG4A-NONX-G2Y-A1 on JetPack-6.2-L4T-36.4.3
   Press select your frist camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)
   1
   Press select your second camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)
   1
   Press select your third camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)
   1
   Press select your fourth camera type: (GMSL=0, GMSL2/6G=1, GMSL2/3G=2)
   1
   Press select your camera port [0-3]:
   0
   Press select your camera resolution:
   0:1920x1080
   1:1920x1536
   2:2880x1860
   3:3840x2160
   4:1280x720
   0
   ```
9. If you want to use the external trigger synchronization mode, you need to run the "camera_fsync_set.sh" script after starting the camera.  

   ```
   ./camera_fsync_set.sh
   ```  
10. The external trigger signal is input through the "CN2" port on the adapter board.   

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
5. Select the device tree you want to light

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson 24pin CSI Connector"
   2.select Configure for compatible hardware
   3.select "Jetson Sensing YUV GMSLx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ./ko/max96712.ko
   sudo insmod ./ko/sgx-yuv-gmsl2.ko
   ```
7. Bring up the camera

   ```
   ## CAM0
    gst-launch-1.0 v4l2src device=/dev/video0 ! "video/x-raw, format=UYVY, width=1920, height=1080, framerate=30/1" ! xvimagesink

    ## CAM1
    gst-launch-1.0 v4l2src device=/dev/video1 ! "video/x-raw, format=UYVY, width=1920, height=1080, framerate=30/1" ! xvimagesink

    ## CAM2
    gst-launch-1.0 v4l2src device=/dev/video2 ! "video/x-raw, format=UYVY, width=1920, height=1080, framerate=30/1" ! xvimagesink

    ## CAM3
    gst-launch-1.0 v4l2src device=/dev/video3 ! "video/x-raw, format=UYVY, width=1920, height=1080, framerate=30/1" ! xvimagesink
   ```