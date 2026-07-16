#### Jetpack version

- Jetpack 7.0 L4TR38.2.1

#### Supported Camera

```
Camera Model                  Sensor         Resolution        Output      Interface
SG8-IMX715C-G3A-HXXX       SONY IMX715       3864*2192         RAW12         GMSL3
SG12-IMX577C-G3A-HXXX      SONY IMX577       4056*3040         RAW10         GMSL3
SG17-IMX735C-G3A-HXXX      SONY IMX735       3016*5776         RAW12         GMSL3
SG8-ISX028C-G2G-HXXX       SONY ISX028       3840*2160         YUV8          GMSL2
SG2-AR0234C-G2F-HXXX       ONsemi AR0234     1920*1080         RAW10         GMSL2
SG3S-ISX031C-G2F-HXXX      SONY ISX031       1920*1536         YUV8          GMSL2
SG3S-ISX031C-G2G-HXXX      SONY ISX031       1920*1536         YUV8          GMSL2
```

#### Quick Bring Up

1. Hardware Connect

   1.1 Connect the Camera to the ports on the adapter board.
   The correspondence between CAM ports and device nodes is as follows:
   ```
   PORT                    DeviceTree Node           DEV NODE                    
   CAM0                        cam_0                /dev/video0                 
   CAM1                        cam_1                /dev/video1                 
   CAM2                        cam_2                /dev/video2                 
   CAM3                        cam_3                /dev/video3                 
   CAM4                        cam_4                /dev/video4                 
   CAM5                        cam_5                /dev/video5                 
   CAM6                        cam_6                /dev/video6 
   CAM7                        cam_7                /dev/video7           
   CAM8                        cam_8                /dev/video8                 
   CAM9                        cam_9                /dev/video9                 
   CAM10                       cam_10               /dev/video10                 
   CAM11                       cam_11               /dev/video11                 
   CAM12                       cam_12               /dev/video12                 
   CAM13                       cam_13               /dev/video13                 
   CAM14                       cam_14               /dev/video14 
   CAM15                       cam_15               /dev/video15         
   ```
   1.2 Power Supply
   SG8-AGX-Thor-GMSL3 adapt board need to be powered by 12V.
2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”
   ```
   /home/nvidia/SG16A-AGTH-G3Y-A1_IMX715_IMX735_IMX577_ISX028_JP7.0_L4TR38.2
   ```
3. Enter the driver directory, run the script "install.sh""
   ```
   cd SG16A-AGTH-G3Y-A1_IMX715_IMX735_IMX577_ISX028_JP7.0_L4TR38.2
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device.

   Based on the type of camera you need to enable, execute the command "sudo /opt/nvidia/jetson-io/jetson-io.py" to select the corresponding device tree, and then modify "load\_modules.sh" to load the appropriate camera driver file.
   ```
   Camera Model                        Device tree                          camera driver
   SG8-IMX715C-G3A-HXXX   Jetson Sensing SG16A_AGTH_G3Y_A1 IMX715x16        sg8-imx715c-g3a.ko
   SG12-IMX577C-G3A-HXXX  Jetson Sensing SG16A_AGTH_G3Y_A1 IMX577x16        sg12-imx577c-g3a.ko
   SG17-IMX735C-G3A-HXXX  Jetson Sensing SG16A_AGTH_G3Y_A1 IMX735x16        sg17-imx735c-g3a.ko 
   SG2-AR0234C-G2F-HXXX   Jetson Sensing SG16A_AGTH_G3Y_A1 AR0234Cx16       sg2-ar0234c-g2f.ko
   YUV-camera  Jetson Sensing SG16A_AGTH_G3Y_A1 YUV GMSL2x16      sgx-yuv-gmsl2.ko
   ```
   Here is the example for enabling the SG8-IMX715C-G3A-HXXX:
   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG16A_AGTH_G3Y_A1 IMX715x16"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
5. After the device reboots, modify the "load\_module.sh" script.

   5.1 Select the corresponding driver.

   Use the following commands to select the driver file, choosing the correct ko file according to the connected camera. Please ensure the selected ko file matches the active device tree, or the loading process will fail.
   ```
   # sudo insmod ko/sg17-imx735c-g3a.ko
   # sudo insmod ko/sgx-yuv-gmsl2.ko
   # sudo insmod ko/sg12-imx577c-g3a.ko
   sudo insmod ko/sg8-imx715c-g3a.ko
   # sudo insmod ko/sg2-ar0234c-g2f.ko
   # sudo insmod ko/sgx-yuv-gmsl2.ko enable_3g_all=1
   # sudo insmod ko/sgx-yuv-gmsl2.ko enable_3g_all=0
   ```
   Note:For the YUV camera, it is divided into 3G mode and 6G mode. If it is G2F (using the 96717f serial adapter), please use the command "sudo insmod ko/sgx-yuv-gmsl2.ko enable\_3g\_all=1"

   5.2 Modify the video device configuration command lines.

   The following commands are used to configure the cameras recognized as video0 to video15 in the system. You need to adjust the command parameter trig\_mode and sensor\_mode according to the camera model and the connection used.
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video8 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video9 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video10 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video11 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video12 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video13 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video14 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video15 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0

   ```
   The "trig\_mode" and "trig\_pin" parameters denote the trigger mode and the corresponding trigger pin to be utilized.
   ```
   For Auto-trigger Mode (The cameras are triggered automatically upon camera activation. However, the cameras are not synchronized):trig_mode=0;trig_pin=0x00020007

   For External-Trigger mode (The cameras are synchronously triggered via the trigger signal generated by the external signal generator that is connected to the trigger Pin of the Kit):trig_mode=1;trig_pin=0x00020007
   ```
   Note: Only the SG8-IMX715C-G3A-HXXX cameras does not support initialization in Jetson Orin Trigger Mode and External-Trigger Mode.
6. Bring up the camera

   6.1 run the script "load\_module.sh".
   ```
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0\~video15 will be generated.

   6.2 Install argus\_camera
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   After installation, the jetson\_multimedia\_api folder can be found in the /usr/src directory. Then refer to the documentation /usr/src/jetson\_multimedia\_api/argus/README.TXT to install argus\_camera.

   6.3 Bring up the RAW camera

   If you don't have an ISP file:
   Start nvargus-daemon in a terminal
   ```
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=CONFIG
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon
   ```
   Start argus\_camera in another terminal
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

   ## Video8
   argus_camera -d 8

   ## Video9
   argus_camera -d 9

   ## Video10
   argus_camera -d 10

   ## Video11
   argus_camera -d 11

   ## Video12
   argus_camera -d 12

   ## Video13
   argus_camera -d 13

   ## Video14
   argus_camera -d 14

   ## Video15
   argus_camera -d 15

   ```
   6.4 Bring up YUV Camera Modules

   Run the gst-launch-1.0 in a terminal.
   ```
   ## CAM0
   gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## CAM1
   gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## CAM2
   gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## CAM3
   gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## CAM4
   gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## CAM5
   gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## CAM6
   gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## CAM7
   gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev

   ## CAM8
   gst-launch-1.0 v4l2src device=/dev/video8 ! xvimagesink -ev

   ## CAM9
   gst-launch-1.0 v4l2src device=/dev/video9 ! xvimagesink -ev

   ## CAM10
   gst-launch-1.0 v4l2src device=/dev/video10 ! xvimagesink -ev

   ## CAM11
   gst-launch-1.0 v4l2src device=/dev/video11 ! xvimagesink -ev

   ## CAM12
   gst-launch-1.0 v4l2src device=/dev/video12 ! xvimagesink -ev

   ## CAM13
   gst-launch-1.0 v4l2src device=/dev/video13 ! xvimagesink -ev

   ## CAM14
   gst-launch-1.0 v4l2src device=/dev/video14 ! xvimagesink -ev

   ## CAM15
   gst-launch-1.0 v4l2src device=/dev/video15 ! xvimagesink -ev
   ```
   Or use：
   ```
   v4l2-ctl -d /dev/video0 \
   --set-ctrl bypass_mode=0 \
   --set-fmt-video=width=3840,height=2160,pixelformat=UYVY \
   --stream-mmap=3 --stream-to=- 2>/dev/null | \
   gst-launch-1.0 fdsrc fd=0 ! 
   rawvideoparse format=uyvy width=3840 height=2160 framerate=30/1 ! \
   videoconvert ! fpsdisplaysink video-sink=autovideosink text-overlay=true 
   sync=false
   ```
7. Provide Trigger Sync signal

   7.1 Modify load\_modules.sh script and re-run it.
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video8 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video9 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video10 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video11 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video12 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video13 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video14 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video15 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   ```
   Note: Only the SG8-IMX715C-G3A-HXXX cameras does not support initialization in Jetson Orin Trigger Mode and External-Trigger Mode.

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
   export CROSS_COMPILE=<toolchain-path>/aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
   export KERNEL_HEADERS=$PWD/kernel/kernel-noble
   export kernel_name=noble
   export INSTALL_MOD_PATH=<install-path>/Linux_for_Tegra/rootfs/
   make -C kernel
   make modules
   make dtbs
   sudo -E make install -C kernel
   sudo -E make modules_install

   cp kernel/kernel-noble/arch/arm64/boot/Image <install-path>/Linux_for_Tegra/kernel/Image
   cp kernel-devicetree/generic-dts/dtbs/* <install-path>/Linux_for_Tegra/kernel/dtb/
   ```
3. Install the newly generated Image and dtb to your nvidia device and reboot to let them take effect
   ```
   dtbo: kernel-devicetree/generic-dts/dtbs/
   Image: kernel/kernel-noble/arch/arm64/boot/

   tegra-camera.ko: nvidia-oot/drivers/media/platform/tegra/camera/
   nvhost-nvcsi.ko: nvidia-oot/drivers/video/tegra/host/nvcsi/nvhost-nvcsi.ko
   ```
4. Copy the image,dtb,ko generated by the above compilation to the corresponding location of jetson
   ```
   sudo cp *.dtbo /boot/
   sudo cp Image /boot/Image
   sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-tegra/updates/drivers/media/platform/tegra/camera/
   sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-tegra/updates/drivers/video/tegra/host/nvcsi/
   ```
5. Select the device tree you installed
   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G3Y_A1 IMX715x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver
   ```
   sudo insmod ko/max96726.ko
   sudo insmod ko/sg8-imx715c-g3a.ko
   ```
7. Bring up the camera
   ```
    ## Video0
    argus_camera -d 0

    ## Video1
    argus_camera -d 1
    ......
   ```

