#### Jetpack version

* Jetpack 6.2

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-G2A-Hxxx

  * support max 8 cameras to bring up at the same time
* SG2-AR0233-5200-G2A-Hxxx

  * support max 8 cameras to bring up at the same time
* SG2-OX03CC-5200-GMSL2F-Hxxx

  * support max 8 cameras to bring up at the same time
* SG3-ISX031C-GMSL2-Hxxx

  * support max 8 cameras to bring up at the same time
* SG3-ISX031C-GMSL2F-Hxxx

  * support max 8 cameras to bring up at the same time
* SG3S-OX03JC-G2F-Hxxx

  * support max 8 cameras to bring up at the same time
* SG5-IMX490C-5300-GMSL2-Hxxx

  * support max 5 cameras to bring up at the same time
* SG8S-AR0820C-5300-G2A-Hxxx

  * support max 6 cameras to bring up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 4 cameras to bring up at the same time
* DMSBBFAN

  * support max 8 cameras to bring up at the same time
* OMSBDAAN-AA

  * support max 8 cameras to bring up at the same time
* OMSBDAAN-AB

  * support max 4 cameras to bring up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP6.2_L4TR36.4.3
   ```
2. Enter the driver directory,

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP6.2_L4TR36.4.3
   chmod a+x ./install.sh
   ./install.sh
   ```
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing YUV GMSL2x8"
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
         APPEND ${cbootargs} root=PARTUUID=9d4f3bcf-0bd3-4d25-ae2c-1105fbc02a98 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 console=ttyAMA0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0 

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
         MENU LABEL Custom Header Config: <CSI Jetson Sensing YUV GMSL2x8>
         LINUX /boot/Image
         FDT /boot/dtb/kernel_tegra234-p3737-0000+p3701-0000-nv.dtb
         INITRD /boot/initrd
         APPEND ${cbootargs} root=PARTUUID=9d4f3bcf-0bd3-4d25-ae2c-1105fbc02a98 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 console=ttyAMA0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0
         OVERLAYS /boot/tegra234-camera-yuv-gmsl2x8-overlay.dtbo
   ```

6. Install camera driver

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP6.2_L4TR36.4.3
   chmod +x quick_bring_up.sh
   ./quick_bring_up.sh
   ```
   Select the corresponding camera model.

6. Bring up the camera

   ```
   ## CAM0
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## CAM1
    v4l2-ctl -d /dev/video1 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## CAM2
    v4l2-ctl -d /dev/video2 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## CAM3
    v4l2-ctl -d /dev/video3 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## CAM4
    v4l2-ctl -d /dev/video4 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## CAM5
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## CAM6
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## CAM7
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev
   ```
Select one of the commands prompted above to bring up the camera.

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
   sudo cp tegra-camera.ko /lib/modules/5.15.136-tegra/updates/drivers/media/platform/tegra/camera/
   sudo cp nvhost-nvcsi-t194.ko /lib/modules/5.15.136-tegra/updates/drivers/video/tegra/host/nvcsi/
   ```
5. Select the device tree you installed

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing YUV GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ./ko/max9295.ko
   sudo insmod ./ko/max9296.ko
   sudo insmod ./ko/sgx-yuv-gmsl2.ko
   ```
7. Bring up the camera

   ```
   ## CAM0
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## CAM1
    v4l2-ctl -d /dev/video1 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## CAM2
    v4l2-ctl -d /dev/video2 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## CAM3
    v4l2-ctl -d /dev/video3 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## CAM4
    v4l2-ctl -d /dev/video4 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## CAM5
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## CAM6
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## CAM7
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev
   ```
