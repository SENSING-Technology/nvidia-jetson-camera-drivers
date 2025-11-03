#### Jetpack version

* Jetpack 7.0

#### Supported SENSING Camera Modules

* SDV11NM1

  * support max 4 cameras to bring up at the same time
#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/TRD1_G2A_SDV11NM1x4_JP7.0_L4TR38.2
   ```
   
2. Enter the driver directory,

   ```
   cd TRD1_G2A_SDV11NM1x4_JP7.0_L4TR38.2
   chmod a+x ./install.sh
   ./install.sh
   ```
   
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 SDV11NM1X4"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
   
4. After the device reboots, install v4l-utils plugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install v4l-utils
   chmod 777 *
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video7 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    CN2                     /dev/video0                 SDV11NM1
                            /dev/video1                 
    CN2                     /dev/video2                 SDV11NM1
                            /dev/video3                 
    CN1                     /dev/video4                 SDV11NM1
                            /dev/video5                 
    CN1                     /dev/video6                 SDV11NM1
                            /dev/video7                 
 
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
         APPEND ${cbootargs} root=PARTUUID=d2f22c03-8ac9-473f-ba9a-8c8cea392567 rw rootwait rootfstype=ext4 mminit_loglevel=4 earlycon=tegra_utc,mmio32,0xc5a0000 console=ttyUTC0,115200 clk_ignore_unused firmware_class.path=/etc/firmware fbcon=map:0 efi=runtime

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
           MENU LABEL Custom Header Config: <CSI Jetson Sensing SG8A_AGTH_G2Y_A1 S36X4>
           LINUX /boot/Image
           FDT /boot/dtb/kernel_tegra264-p4071-0000+p3834-0008-nv.dtb
           INITRD /boot/initrd
           APPEND ${cbootargs} root=PARTUUID=d2f22c03-8ac9-473f-ba9a-8c8cea392567 rw rootwait rootfstype=ext4 mminit_loglevel=4 earlycon=tegra_utc,mmio32,0xc5a0000 console=ttyUTC0,115200 clk_ignore_unused firmware_class.path=/etc/firmware fbcon=map:0 efi=runtime
           OVERLAYS /boot/tegra264-camera-sdv11nm1x4-overlay.dtbo
   ```

6. Bring up the camera

   6.1 Install argus_camera
   
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   

After installation, the jetson_multimedia_api folder can be found in the /usr/src directory. Then refer to the documentation /usr/src/jetson_multimedia_api/argus/README.TXT to install argus_camera.

6.2 Bring up SDV11NM1 Modules

   ```
   This package is use for AGX Thor & Jetson_Linux_R38.2.0
   sudo insmod ko/max96712.ko
   sudo insmod ko/sdv11nm1.ko
   ```

   Start nvargus-daemon in a terminal

   ```
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=CONFIG
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon
   ```

   Start argus_camera in another terminal

   ```
   ## Video0
   
   argus_camera -d 0
   
   ## Video1
   
   argus_camera -d 1
   
   ## Video2
   
   argus_camera -d 2
   
   ## Video3
   
   argus_camera -d 3
   
   ## Video4
   
   argus_camera -d 4
   
   ## Video5
   
   argus_camera -d 5
   
   ## Video6
   
   argus_camera -d 6
   
   ## Video7
   
   argus_camera -d 7
   ```


7. Camera Trigger Sync

   Modify quick_bring_up.sh script and re-run it.

   ```
   v4l2-ctl -d /dev/video0 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video1 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video2 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video3 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video4 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video5 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video6 -c trig_pin=0x00020007,trig_mode=2
   v4l2-ctl -d /dev/video7 -c trig_pin=0x00020007,trig_mode=2
   ```

   7.1 External Trigger Mode

   For Adapter Board CN4, the PIN1(CAM-FSYNC1) and PIN6 correspond to the external trigger signal pin and ground pin respectively. 
   Connect the corresponding pins of the signal generator to these pins.

   7.2 Internal Trigger Mode

   ```
   a.load the driver
   sudo insmod ko/pwm-gpio.ko
   
   b.Export PWM channel 0 (pwmchip4 is a newly generated node after loading the driver)
   echo 0 > /sys/class/pwm/pwmchip4/export
   
   c.Set the period to 33333333 (corresponding to 30 Hz)
   echo 33333333 > /sys/class/pwm/pwmchip4/pwm0/period
   
   d.Set the duty cycle
   echo 10000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle
   
   e.Enable PWM output
   echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable
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
export KERNEL_HEADERS=$PWD/kernel/kernel-noble
export INSTALL_MOD_PATH=<install-path>/Linux_for_Tegra/rootfs/
make -C kernel
make modules
make dtbs
sudo -E make install -C kernel

cp kernel/kernel-noble/arch/arm64/boot/Image <install-path>/Linux_for_Tegra/kernel/Image
cp nvidia-oot/device-tree/platform/generic-dts/dtbs/* <install-path>/Linux_for_Tegra/kernel/dtb/
```

3. Install the newly generated Image and dtb to your nvidia device and reboot to let them take effect

```
dtb:nvidia-oot/device-tree/platform/generic-dts/dtbs/
Image: kernel/kernel-noble/arch/arm64/boot/

tegra-camera.ko:nvidia-oot/drivers/media/platform/tegra/camera/
nvhost-nvcsi.ko:nvidia-oot/drivers/video/tegra/host/nvcsi/
```

4. Copy the image,dtb,ko generated by the above compilation to the corresponding location of jetson

```
sudo cp *.dtbo /boot/
sudo cp Image /boot/Image
sudo cp tegra-camera.ko /lib/modules/6.8.12-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp nvhost-nvcsi.ko /lib/modules/6.8.12-tegra/updates/drivers/video/tegra/host/nvcsi/
```

5. Select the device tree you installed

```
sudo /opt/nvidia/jetson-io/jetson-io.py

1.select "Configure Jetson AGX CSI Connector"
2.select "Configure for compatible hardware"
3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 SDV11NM1X4"
4.select "Save pin changes"
5.select "Save and reboot to reconfigure pins"
```

6. Install camera driver

```
sudo insmod ./ko/max96712.ko
sudo insmod ./ko/sdv11nm1.ko
```

7. Bring up the camera

   ```
   
   ## Video0
   
    argus_camera -d 0

   ## Video1
   
    argus_camera -d 1

   ## Video2
   argus_camera -d 2
   
   ## Video3
   
   argus_camera -d 3
   
   ## Video4
   
   argus_camera -d 4
   
   ## Video5
   
   argus_camera -d 5
   
   ## Video6
   
   argus_camera -d 6
   
   ## Video7
   
   argus_camera -d 7

   ```
