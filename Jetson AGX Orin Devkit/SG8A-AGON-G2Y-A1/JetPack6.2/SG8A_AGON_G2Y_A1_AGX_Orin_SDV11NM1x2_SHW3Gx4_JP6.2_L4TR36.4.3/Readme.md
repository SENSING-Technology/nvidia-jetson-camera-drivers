#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SDV11NM1

  * support max 2 cameras to bring up at the same time
* SHW3G

  * support max 4 cameras to bring up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG8A_AGON_G2Y_A1_AGX_Orin_SDV11NM1x1_SHW3Gx4_JP6.2_L4TR36.4.3
   ```
   
2. Enter the driver directory,

   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_SDV11NM1x1_SHW3Gx4_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
   
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A-AGON-G2Y-A1 SDV11NM1x1 AND SHW3Gx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
   
4. If step 3 cannot be executed, you can manually modify the extlinux.conf file to apply the device tree.

   ```
   sudo vi /boot/extlinux/extlinux.conf
   ```
   
5. Modify the file to the following content, then reboot.

   ```
   TIMEOUT 30
   DEFAULT JetsonIO

   MENU TITLE L4T boot options

   LABEL primary
         MENU LABEL primary kernel
         LINUX /boot/Image
         INITRD /boot/initrd
         APPEND ${cbootargs} root=PARTUUID=fc583382-498b-4600-ac06-ea076435b1f1 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 console=ttyAMA0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0 

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
         MENU LABEL Custom Header Config: <Jetson Sensing SG8A-AGON-G2Y-A1 SDV11NM1x1 AND SHW3Gx4>
         LINUX /boot/Image
         FDT /boot/dtb/kernel_tegra234-p3737-0000+p3701-0000-nv.dtb
         INITRD /boot/initrd
         APPEND ${cbootargs} root=PARTUUID=fc583382-498b-4600-ac06-ea076435b1f1 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 console=ttyAMA0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0
         OVERLAYS /boot/tegra234-camera-sdv11nm1x1-shw3gx4-gmsl2x8-overlay.dtbo
   ```

6. After the device reboots, install v4l-utils argus_camera plugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev v4l-utils busybox -y
   sudo apt-get install nvidia-l4t-jetson-multimedia-api -y
   cd /usr/src/jetson_multimedia_api/argus/
   sudo mkdir build && cd build
   sudo cmake ..
   sudo make -j8
   sudo make install

   cd /home/nvidia/SG8A_AGON_G2Y_A1_AGX_Orin_SDV11NM1x1_SHW3Gx4_JP6.2_L4TR36.4.3
   sudo ./load_module.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video9 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                   Camera
    U1-COAX0               /dev/video0                 SDV11NM1
                           /dev/video1                 
                           /dev/video2                 SDV11NM1
                           /dev/video3                 
    U1-COAX0               /dev/video4                 SHW3G
    U1-COAX1               /dev/video5                 SHW3G
    U1-COAX2               /dev/video6                 SHW3G
    U1-COAX3               /dev/video7                 SHW3G
    ```

7. Bring up the camera

7.1 For SDV11NM1 Modules
  a. Without using trigger synchronization.
   ```
   ## video0 video1
   v4l2-ctl -c trig_mode=0 -d /dev/video0
   v4l2-ctl -c trig_mode=0 -d /dev/video1
   argus_camera -d 0
   argus_camera -d 1
   ```

  b.Use trigger synchronization (you need to provide an external trigger signal to the adapter board).
   ```
   ## video0 video1
   v4l2-ctl -c trig_mode=1 -d /dev/video0
   v4l2-ctl -c trig_mode=1 -d /dev/video1
   argus_camera -d 0
   argus_camera -d 1
   ```
7.2 For SHW3G Modules
  a. Without using trigger synchronization.
   ```
   ## video4
   v4l2-ctl -c trig_mode=0 -d /dev/video4
   argus_camera -d 4
   ```

  b.Use trigger synchronization (you need to provide two external trigger signal to the adapter board).
   ```
   ## video4
   v4l2-ctl -c trig_mode=1 -d /dev/video4
   argus_camera -d 4
   ```

#### Integration with SENSING Driver Source Code

1. Compile Image & dtb
   Refer to the following command to integrate Dtb and Kernel source code to your kernel

```
   cp camera-driver-package/source/hardware Linux_for_Tegra/source/hardware -r
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
   3.select "Jetson Sensing SG8A-AGON-G2Y-A1 SDV11NM1x1 AND SHW3Gx4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ./ko/max96712.ko
   sudo insmod ./ko/sdv11nm1.ko
   sudo insmod ./ko/shw3g.ko
   ```
7. Bring up the camera

   ```
   ## Video0
    argus_camera -d 0

   ## Video1
    argus_camera -d 1
    ...
   ```
