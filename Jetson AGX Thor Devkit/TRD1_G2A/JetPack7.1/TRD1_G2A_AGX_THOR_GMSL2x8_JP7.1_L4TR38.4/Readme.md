#### Jetpack version

* Jetpack 7.1

#### Supported Camera Modules
```
Camera Model               Resolution         Output     Interface   MaxDevices  Frame Sync
SG8-OX08DC-G2G             3840*2160V         RAW12      GMSL2-6G        4          MFP7          
SG8-IMX728C-G2G            2880*1860V         RAW12      GMSL2-6G        6          MFP7
SG2S24AFxK                 1920*1080V         YUV422     GMSL2-3G        8          MFP7
SG2-AR0233C-5200-G2A       1920*1080V         YUV422     GMSL2-6G        8          MFP7
SG2-IMX390C-5200-G2A       1920*1080V         YUV422     GMSL2-6G        8          MFP7
SG2-OX03CC-5200-G2F        1920*1080V         YUV422     GMSL2-3G        8          MFP7
SG3S11AFLK                 1920*1536V         YUV422     GMSL2-3G        8          MFP7 
SG3S-ISX031C-GMSL2F        1920*1536V         YUV422     GMSL2-3G        8          MFP7
SG3S-ISX031C-GMSL2         1920*1536V         YUV422     GMSL2-6G        8          MFP7
SG5-IMX490C-5300-GMSL2     2880*1860V         YUV422     GMSL2-6G        6          MFP8
SG8S-AR0820C-5300-G2A      3840*2160V         YUV422     GMSL2-6G        4          MFP7
SHF3L                      1920*1536V         YUV422     GMSL2-6G        8          MFP7
SHF3H                      1920*1536V         YUV422     GMSL2-6G        4          MFP7
SG8-ISX028C-G2G            3840*2160V         YUV422     GMSL2-6G        4          MFP7
```
Note: If the maximum supported number above is not 8, it indicates that the maximum number of connections per MAX96712 is half of that value.

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   CN2 (CAM0/CAM1/CAM2/CAM3)

   CN1 (CAM4/CAM5/CAM6/CAM7)

   The correspondence between CAM ports and device nodes is as follows:

    ```
    PORT                    DeviceTree Node          DEV NODE                    
    CN2(CAM0)               cam_0                    /dev/video0                 
    CN2(CAM1)               cam_1                    /dev/video1                 
    CN2(CAM2)               cam_2                    /dev/video2                 
    CN2(CAM3)               cam_3                    /dev/video3                 
    CN1(CAM4)               cam_4                    /dev/video4                 
    CN1(CAM5)               cam_5                    /dev/video5                 
    CN1(CAM6)               cam_6                    /dev/video6 
    CN1(CAM7)               cam_7                    /dev/video7                 
    ```  


2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/TRD1_G2A_AGX_THOR_GMSL2x8_JP7.1_L4TR38.4
   ```

3. Enter the driver directory, run the script "install.sh"

   ```
   cd TRD1_G2A_AGX_THOR_GMSL2x8_JP7.1_L4TR38.4
   chmod a+x ./install.sh
   sudo ./install.sh
   ```
   

4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select camera overly file

    Based on the type of camera you need to enable, execute the command "sudo /opt/nvidia/jetson-io/jetson-io.py" to select the corresponding device tree, and then modify "load_modules.sh" to load the appropriate camera driver file.
   ```
   Camera Model                        Device tree                        camera driver
   SG8-OX08DC-G2G         Jetson Sensing SG8A_AGTH_G2Y_A1 OX08Dx8          sg8-ox08dc-g2g.ko
   SG8-IMX728C-G2G        Jetson Sensing SG8A-AGON-G2Y-A1 IMX728x8         sg8-imx728c-g2g.ko
   YUV-Camera             Jetson Sensing SG8A_AGTH_G2Y_A1 GMSL2x8          sgx-yuv-gmsl2.ko 
   ```
   Here is the example for enabling the YUV-Camera:
   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
   If you are unable to import the device tree by executing the "sudo /opt/nvidia/jetson-io/jetson-io.py script", please run update_jetsonio.sh to manually modify the configuration.
   Here is the example for enabling the YUV-Camera:
   ```
   sudo ./update_jetsonio
   ==========================================
   Jetson Camera Configuration Selector
   ==========================================
   Please select the camera to enable:
   0 : SG8-OX08DC-5300-G2G-Hxxx
   1 : SG8-IMX728C-G2G-Hxxx
   2 : YUV-Camera
   ==========================================
   Enter number [0-2]: 2

   Target Configuration: tegra264-camera-yuv-gmsl2x8-overlay.dtbo
   System reset to default state using backup...
   New configuration added successfully.

   Done. Please reboot the system to apply changes: sudo reboot
   ```
   

5. After the device reboots, modify the "load_module.sh" script.

   5.1 Select the corresponding driver.

   Use the following commands to select the driver file, choosing the correct ko file according to the connected camera. Please ensure the selected ko file matches the active device tree, or the loading process will fail.
   ```
   # sudo insmod ko/sg8-ox08dc-g2g.ko
   # sudo insmod ko/sg8-imx728c-g2g.ko
   sudo insmod ko/sgx-yuv-gmsl2.ko enable_3G_0=1,0,0,0 enable_3G_1=0,0,0,0
   ```
   5.2 Modify the camera to the corresponding 3G/6G mode
   ```
   enable_3G_0=,,, enable_3G_1=,,,
   The values in enable_3G_0 correspond to video0-3, and enable_3G_1 corresponds to video4-7. A value of 1 enables 3G mode for the channel, while 0 sets it to 6G mode.
   For example, "sudo insmod ko/sgx-yuv-gmsl2.ko enable_3G_0=1,0,0,0 enable_3G_1=0,0,0,0" indicates that video0 is in 3G mode, while the remaining channels are in 6G mode.
   ```
   5.3 Modify the video device configuration command lines.

   The following commands are used to configure the cameras recognized as video0 to video7 in the system. Adjust the sensor_mode parameter according to the camera resolution, and set the trig_pin and trig_mode parameters based on the camera model and connection used.

   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=0
   ```
   sensor_mode:
   ```
   For RAW camera:
   sensor_mode=0

   For YUV camera:
   sensor_mode=0:1920*1080
   sensor_mode=1:1920*1536
   sensor_mode=2:2880*1860
   sensor_mode=3:3840*2160

   Note: The SG8-ISX028C-G2G requires sensor_mode=5. All other YUV cameras use the default modes corresponding to the resolutions listed above
   ```
   The "trig_mode" and "trig_pin" parameters denote the trigger mode and the corresponding trigger pin to be utilized.
   ```
   For  SG5-IMX490C-5300-GMSL2:
   trig_pin=0x00020008:（DES trigger pin: mfp2; SER trigger pin: mfp8）
   For all others:
   trig_pin=0x00020007:（DES trigger pin: mfp2; SER trigger pin: mfp7）
   ```
   For YUV cameras,trig_mode:
   ```
   Auto-trigger Mode (The cameras are triggered automatically upon camera activation. However, the cameras are not synchronized)trig_mode=0;

   For Jetson Orin Trigger Mode (The cameras are triggered and synchronized through the trigger signal generated from the Jetson Orin):trig_mode=2;

   For External-Trigger mode (The cameras are synchronously triggered via the trigger signal generated by the external signal generator that is connected to the trigger Pin of the Kit):trig_mode=2;
   ```
   For  RAW camera(SG8-OX08DC-G2G and SG8-IMX728C-G2G),trig_mode:
   ```
   Auto-trigger Mode (The cameras are triggered automatically upon camera activation. However, the cameras are not synchronized)trig_mode=0;

   For Jetson Orin Trigger Mode (The cameras are triggered and synchronized through the trigger signal generated from the Jetson Orin):trig_mode=1;

   For External-Trigger mode (The cameras are synchronously triggered via the trigger signal generated by the external signal generator that is connected to the trigger Pin of the Kit):trig_mode=1;
   ```
   Note:For Jetson Orin Trigger Mode and External-Trigger Mode, a trigger signal is required. Please refer to section "7. Camera Trigger Sync" for details.

6. Bring up the camera

   6.1 Install argus_camera
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   After installation, the jetson_multimedia_api folder can be found in the /usr/src directory. Then refer to the documentation "/usr/src/jetson_multimedia_api/argus/README.TXT" to install argus_camera.

   6.2 Bring up RAW Camera Modules

   Start nvargus-daemon in a terminal
   ```
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=CONFIG
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon
   ```

   Start argus_camera in another terminal
   ```
   ## CAM0
   argus_camera -d 0

   ## CAM1
   argus_camera -d 1

   ## CAM2
   argus_camera -d 2

   ## CAM3
   argus_camera -d 3

   ## CAM4
   argus_camera -d 4

   ## CAM5
   argus_camera -d 5

   ## CAM6
   argus_camera -d 6

   ## CAM7
   argus_camera -d 7
   ```

   6.3 Bring up YUV Camera Modules

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
   ```
7. Camera Trigger Sync

   7.1 Modify load_modules.sh script and re-run it.
      ```
      v4l2-ctl -d /dev/video0 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video1 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video2 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video3 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video4 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video5 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video6 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      v4l2-ctl -d /dev/video7 -c sensor_mode=0,trig_pin=0x00020007,trig_mode=2
      ```

   7.2 External Trigger Mode

   External Trigger Port: CN4

   The PIN1(CAM-FSYNC1) and PIN6 correspond to the external trigger signal pin and ground pin respectively. Connect the corresponding pins of the signal generator to these pins.
   ```
   CAM-FSYNC1 Pin Trigger Signal Parameters:
   Frequency: 30 Hz
   Amplitude: 3.3V
   Bias: 1.6V
   Duty Cycle: 10%

   PIN 6: GND
   ```

   7.3 Jetson Thor Trigger Mode

   When utilize Jetson Thor Trigger Mode,it is required to configurate the trigger signal generated from the Jetson Thor via the following steps.
   ```
   # Export PWM channel 0
   echo 0 > /sys/class/pwm/pwmchip4/export

   # Set the period to 33333333 (corresponding to 30 Hz)
   echo 33333333 > /sys/class/pwm/pwmchip4/pwm0/period

   # Set the duty cycle
   echo 3333333 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle

   # Enable PWM output
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
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 ******"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/max96712.ko
   sudo insmod ko/sgx-yuv-gmsl2.ko
   ```
7. Bring up the camera

   Bring up RAW Camera Modules

   ```
    ## CAM0
    argus_camera -d 0

    ## CAM1
    argus_camera -d 1
    ......
   ```

   Bring up YUV Camera Modules

   ```
   ## CAM0
   gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## CAM1
   gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev
   ......
   ```
