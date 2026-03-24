#### Jetpack version

* Jetpack 6.2 L4TR 36.4.3

#### Supported Camera Modules

* SHW3G (Monocular, RAW)
  * support max 8 cameras to bring up at the same time
* SDV11NM1 (Stereo, RAW)
   * support max 4 cameras to bring up at the same time
* SGX-YUV-GMSL2 (Monocular, YUV)

   * RedFox-D3GN
      * support max 8 cameras to bring up at the same time

   * SG8-ISX028-G2G-Hxxx
      * support max 6 cameras to bring up at the same time,CAM0–3 and CAM4–7 each support a maximum of 3

   * SH3-S11A60-G2A-Hxxx
      * support max 8 cameras to bring up at the same time

   * SN2M4EFGD
      * support max 8 cameras to bring up at the same time

   * SG2-IMX390C-5200-G2-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG2-AR0233-5200-G-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG2-OX03CC-5200-GMSL2F-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG3-ISX031C-GMSL2-Hxxx
      * support max 8 cameras to bring up at the same time
   
   * SG3-ISX031C-GMSL2F-Hxxx
      * support max 8 cameras to bring up at the same time
   
   * SG5-IMX490C-5300-GMSL2-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG8S-AR0820C-5300-G2A-Hxxx
      * support max 7 cameras to bring up at the same time, CAM4 and CAM5 can each connect to at most one camera

   * SG8-OX08BC-5300-GMSL2-Hxxx
      * support max 7 cameras to bring up at the same time,CAM4 and CAM5 can each connect to at most one camera

   * DMSBBFAN
      * support max 8 cameras to bring up at the same time

   * OMSBDAAN-AA
      * support max 8 cameras to bring up at the same time




#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   CN1 (CAM0/CAM1/CAM2/CAM3)

   CN2 (CAM4/CAM5/CAM6/CAM7)

   The correspondence between CAM ports and device nodes is as follows:

    ```
    PORT                    DeviceTree Node          DEV NODE                    
    CN1(CAM0)               cam_0                    /dev/video0                 
    CN1(CAM1)               cam_1                    /dev/video1                 
    CN1(CAM2)               cam_2                    /dev/video2                 
    CN1(CAM3)               cam_3                    /dev/video3                 
    CN2(CAM4)               cam_4                    /dev/video4                 
    CN2(CAM5)               cam_5                    /dev/video5                 
    CN2(CAM6)               cam_6                    /dev/video6 
    CN2(CAM7)               cam_7                    /dev/video7                 
    ```  


2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG8A_AGON_G2Y_A1_AGX_Orin_GMSL2x8_JP6.2_L4TR36.4.3
   ```

3. Select camera for cam_0~cam_7

   Enter the driver directory, run the script "generate_camera_overlay.py" to select camera.

   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_GMSL2x8_JP6.2_L4TR36.4.3
   python3 generate_camera_overlay.py
   ```

   for example
   ```   
   nvidia@nvidia:~/SG8A_AGON_G2Y_A1_AGX_Orin_GMSL2x8_JP6.2_L4TR36.4.3$ python3 generate_camera_overlay.py
   Available models:
   0: sgx-yuv-gmsl2 (uyvy)
   1: shw3g (raw12)
   2: sdv11nm1 (raw10)
  

   Select camera for cam_0 (0-2): 0
   Select camera for cam_1 (0-2): 1
   Select camera for cam_2 (0-2): 2
   Placed stereo pair 'sdv11nm1' on cam_2 and cam_3.
   Select camera for cam_4 (0-2): 0
   Select camera for cam_5 (0-2): 1
   Select camera for cam_6 (0-2): 2
   Placed stereo pair 'sdv11nm1' on cam_6 and cam_7.
  

   Selected configurations:
   cam_0 -> sgx-yuv-gmsl2
   cam_1 -> shw3g
   cam_2 -> sdv11nm1
   cam_3 -> sdv11nm1
   cam_4 -> sgx-yuv-gmsl2
   cam_5 -> shw3g
   cam_6 -> sdv11nm1
   cam_7 -> sdv11nm1

   Found cam_0@20
   Found cam_1@21
   Found cam_2@22
   Found cam_3@23
   Found cam_4@20
   Found cam_5@21
   Found cam_6@22
   Found cam_7@23

   Generated: dts/tegra234-camera-sgcamx8-overlay.dts
   Compiling...
   Generated: dts/tegra234-camera-sgcamx8-overlay.dtbo

   --- Final Port Configuration ---
   Port 0 (cam_0): sgx-yuv-gmsl2 (uyvy)
   Port 1 (cam_1): shw3g (raw12)
   Port 2 (cam_2): sdv11nm1 (raw10)
   Port 3 (cam_3): sdv11nm1 (raw10)
   Port 4 (cam_4): sgx-yuv-gmsl2 (uyvy)
   Port 5 (cam_5): shw3g (raw12)
   Port 6 (cam_6): sdv11nm1 (raw10)
   Port 7 (cam_7): sdv11nm1 (raw10)
   --- End of Configuration ---
   ```

   After execution, a new DTB file is generated:

   dts/tegra234-camera-sgcamx8-overlay.dtbo

   
4. Install Kernel image and camera overly file

   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_GMSL2x8_JP6.2_L4TR36.4
   chmod a+x ./install.sh
   ./install.sh
   ```

5. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select camera overly file

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A-AGON-G2Y-A1 GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

6. Bring up the camera 

   6.1 Install argus_camera

   If you want to bring up RAW camera modules, you need to install argus_camera first.
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   After installation, the jetson_multimedia_api folder can be found in the /usr/src directory. Then refer to the documentation "/usr/src/jetson_multimedia_api/argus/README.TXT" to install argus_camera.

   6.2 run the script "raw_yuv_quick_bring_up.sh"
   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_GMSL2x8_JP6.2_L4TR36.4
   chmod a+x ./raw_yuv_quick_bring_up.sh
   ./raw_yuv_quick_bring_up.sh
   ```
   
   Select the corresponding camera model and port to initialize the camera. The example below demonstrates how to initialize the SG2-AR0233C-5200-G2A camera connected to cam1, while configuring cam0, cam2, and cam3 for 3G mode operation.
   ```
   This package is use for AGX_ORIN Jetson_Linux_R36.4.3
   832000000
   1011200000
   642900000
   3199000000
   Do you want to connect a 3G mode camera? (y/n):
   y
   Please enter the enabled port numbers (space separated, range 0-7).
   Example: '0 1 2' or '4 5' or '0 4 7'
   0 2 3
   Driver loaded successfully.
   0:SN2M4EFGD(3G)
   1:SG2-IMX390C-5200-G2-Hxxx
   2:SG2-AR0233-5200-G-Hxxx
   3:SG2-OX03CC-5200-GMSL2F-Hxxx
   4:DMSBBFAN(3G)
   5:SG3-ISX031C-GMSL2-Hxxx
   6:SG3-ISX031C-GMSL2F-Hxxx(3G)
   7:RedFox-D3GN
   8:SH3-S11A60-G2A-Hxxx
   9:OMSBDAAN-AA
   10:SG5-IMX490C-5300-GMSL2
   11:SG8S-AR0820C-5300-GMSL2
   12:SG8-OX08BC-5300-GMSL2-Hxxx
   13:SG8-ISX028-G2G-Hxxx
   14:SHW3G(raw)
   15:SDV11NM1(raw)
   Press select your yuv camera type [0-15]:
   2
   Press select your camera port [0-7]:
   1
   Start bring up camera!
   Launching GStreamer pipeline on /dev/video1...
   ```

7. Camera Trigger Sync

   7.1 Enable camera slave Mode

   Modify the script "raw_yuv_quick_bring_up.sh"，according to the above descriptions of  trig_mode to enable slave mode,then re-run it

   trig_mode:
   ```
   0 = Auto trigger mode, 1 = Orin / Ext Trigger mode, 2= MAX96712-generated Internal Trigger
   
   Note:
   For the DMSBBFAN camera, trig_mode must be set to 0. When trig_mode is set to 1, avoid frequently powering the camera on and off; otherwise, the camera may fail to output a video stream.
   For both the OMSBDAAN-AA and SN2M4EFGD camera models, when no PWM or external trigger signal is provided, trig_mode must be set to 2. If trig_mode is set to 1, the trigger frequency must be configured to 30 Hz.Therefore, when using these two cameras alongside others, please set trig_mode uniformly to 2, or uniformly to 1 while configuring a 30 Hz trigger frequency signal.
   ```
   trig_pin:
   ```
   For  SG5-IMX490C-5300-GMSL2-Hxxx and SG8-OX08BC-5300-GMSL2-Hxxx
   0x00020008 (Left to Right):
   0002: Deserializer trigger pin = mfp2
   0008: Serializer trigger pin = mfp8

   For other camera
   0x00020007 (Left to Right):
   0002: Deserializer trigger pin = mfp2
   0007: Serializer trigger pin = mfp7
   ```
   For example:
   ```
   #For  SG5-IMX490C-5300-GMSL2-Hxxx and SG8-OX08BC-5300-GMSL2-Hxxx
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x00020008,trig_mode=1

   #For other camera
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   ```
   7.2 External Trigger Mode

   External Trigger Port: CN4

   The PIN1(CAM-FSYNC1) and PIN6 correspond to the external trigger signal pin and ground pin respectively. 
   Connect the corresponding pins of the signal generator to these pins.

   ```
   CAM-FSYNC1 Pin Trigger Signal Parameters:
   Frequency: 30 Hz
   Amplitude: 3.3V
   Bias: 1.6V
   Duty Cycle: 10%

   PIN 6: GND
   ```

   7.3 Internal Trigger Mode

   ```
   # Export PWM channel 0
   echo 0 > /sys/class/pwm/pwmchip5/export

   # Set the period to 33333333 (corresponding to 30 Hz)
   echo 33333333 > /sys/class/pwm/pwmchip5/pwm0/period

   # Set the duty cycle
   echo 30000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle

   # Enable PWM output
   echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable
   ```

#### Integration with SENSING Driver Source Code

1. Compile Image & dtb
   Refer to the following command to integrate Dtb and Kernel source code to your kernel

   ```
   cp camera-driver-package/source/hardware Linux_for_Tegra/source/$YourDir/hardware -r
   cp camera-driver-package/source/kernel Linux_for_Tegra/source/$YourDir/kernel -r
   cp camera-driver-package/source/nvidia-oot Linux_for_Tegra/source/$YourDir/nvidia-oot -r
   ```
2. Go to the root directory of your source code and recompile

   ```
   cd <install-path>/Linux_for_Tegra/source/$YourDir/
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
   3.select "Jetson Sensing SG8A-AGON-G2Y-A1 GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/max96712.ko
   sudo insmod ko/sgcam-gmsl2.ko
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