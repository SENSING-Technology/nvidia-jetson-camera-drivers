#### Jetpack version

* Jetpack 7.0  L4TR38.2.1

#### Supported Camera Modules

* SG2-AR0233C-5200-F3A-Hxxx 
  * support max 8 cameras to bring up at the same time

* SG8S-AR0820C-5300-F4A-Hxxx 
  * support max 4 cameras to bring up at the same time

* SG3S-ISX031C-F4A-Hxxx
  * support max 8 cameras to bring up at the same time

* SG3S-ISX031C-F3A-Hxxx
  * support max 8 cameras to bring up at the same time

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   ![alt text](../../../../Picture/SENSING%20Thor%20Developer%20Kit/TRD1%20G2A%20Camera%20Interface%20Definition.jpg)


   ```
   CN1 (CAM4/CAM5/CAM6/CAM7)
   CN2 (CAM0/CAM1/CAM2/CAM3)
   ```
   The correspondence between CAM ports and device nodes is as follows:

    ```
    PORT                    DeviceTree Node            DEV NODE                    
    CN1(COAX0)               cam_4                    /dev/video4                
    CN1(COAX1)               cam_5                    /dev/video5                 
    CN1(COAX2)               cam_6                    /dev/video6                 
    CN1(COAX3)               cam_7                    /dev/video7                 
    CN2(COAX4)               cam_0                    /dev/video0                 
    CN2(COAX5)               cam_1                    /dev/video1                 
    CN2(COAX6)               cam_2                    /dev/video2 
    CN2(COAX7)               cam_3                    /dev/video3                 
     
    ```  


2. Enter the driver directory,

   ```
   cd TRD1_F4B_AGX_THOR_FPDx8_YUV_JP7.0_L4TR38.2.1
   chmod a+x ./install.sh
   ./install.sh
   ```
   
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8_AGX_F4_A1 YUV FPD4x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
4. After the device reboot, run the script "load_module.sh".

   4.1 Modify the script "load_modules.sh"

   SG2-AR0233C-5200-F3A-Hxxx(1920X1080): sensor_mode=0;
   SG3S-ISX031C-F4A-Hxxx(1920X1536): sensor_mode=1;
   SG3S-ISX031C-F3A-Hxxx(1920X1536): sensor_mode=1; 
   SG8S-AR0820C-5300-F4A-Hxxx(3840X2160): sensor_mode=3.

   Orin trigger pin: 0x00000000（DES trigger pin: mfp0; SER trigger pin: mfp0）;

   Ext trigger pin: 0x00020000（DES trigger pin: mfp2; SER trigger pin: mfp0） 

   Auto trigger: trig_mode=0; Orin trigger/ Ext Trigger: trig_mode=1

   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video1 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video2 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video3 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video4 -c sensor_mode=1,trig_pin=0x00020000,trig_mode=1
   v4l2-ctl -d /dev/video5 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=3,trig_pin=0x00000000,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=3,trig_pin=0x00000000,trig_mode=0
   ```

   4.2 Mixed use of FPD4 mode cameras (with F4 identifier: XXX-F4A-XXX) and FPD3 mode cameras (with F3 identifier: XXX-F3A-XXX)

   If you wish to use the mixed mode, we have provided the following methods in the driver for your use.

   a.Determine the corresponding mode for each camera channel, where FPD4 is represented by (1) and FPD3 by (0).

   b.Load the driver manually according to the actual situation.

   ```
   sudo insmod ./ko/ti9724.ko
   sudo insmod ko/sgx-yuv-fpd4.ko enable_fpd4_0=1,1,0,0 enable_fpd4_1=0,0,1,1
   ```

   enable_fpd4_0 represents the first input channel. The value `1,1,0,0` indicates that the first and second cameras operate in FPD4 mode, while the third and fourth cameras operate in FPD3 mode.

   enable_fpd4_1 represents the second input channel. The value `0,0,1,1` indicates that the first and second cameras operate in FPD4 mode, while the third and fourth cameras operate in FPD3 mode.

 
   4.3 run the script "load_module.sh".

   ```
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video7 will be generated.
5. Bring up the camera

   Run the gst-launch-1.0 in a terminal.
   ```
   ## COAX4
   gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## COAX5
   gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## COAX6
   gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## COAX7
   gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## COAX0
   gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## COAX1
   gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## COAX2
   gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## COAX3
   gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev
   ```
   
6. Camera Trigger Sync

   Modify load_modules.sh script and re-run it.

   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video1 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video2 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video3 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video4 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=1
   v4l2-ctl -d /dev/video5 -c sensor_mode=1,trig_pin=0x00000000,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=3,trig_pin=0x00000000,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=3,trig_pin=0x00000000,trig_mode=0
   ```

   6.1 External Trigger Mode

   For Adapter Board CN4, PIN2 (CAM-FSYNC2) corresponds to the external trigger signal from CN1, PIN4 (CAM-FSYNC4) corresponds to the external trigger signal from CN2, and PIN6 is the Ground pin. 
   Connect the corresponding pins of the signal generator to these pins.

   6.2 Internal Trigger Mode

   ```
   a.load the driver
   sudo insmod ko/pwm-gpios.ko
   
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
   3.select "Jetson Sensing SG8_AGX_F4_A1 YUV FPD4x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

6. Install camera driver

   ```
   sudo insmod ./ko/ti9724.ko
   sudo insmod ./ko/sgx-yuv-fpd4.ko
   ```

7. Bring up the camera

   ```
   ## COAX4
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## COAX5
    v4l2-ctl -d /dev/video1 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## COAX6
    v4l2-ctl -d /dev/video2 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## COAX7
    v4l2-ctl -d /dev/video3 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## COAX0
    v4l2-ctl -d /dev/video4 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## COAX1
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## COAX2
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## COAX3
    v4l2-ctl -d /dev/video0 -c sensor_mode=?,trig_pin=?
    gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev
   ```