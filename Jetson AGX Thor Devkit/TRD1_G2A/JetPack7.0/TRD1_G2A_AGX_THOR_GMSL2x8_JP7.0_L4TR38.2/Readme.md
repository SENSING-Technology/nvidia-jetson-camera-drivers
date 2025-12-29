#### Jetpack version

* Jetpack 7.0

#### Supported Camera Modules

* SG8-OX08DC-G2G (Monocular, RAW)
  * support max 4 cameras to bring up at the same time

* SHW3G (Monocular, RAW)
  * support max 8 cameras to bring up at the same time

* SHW5G (Monocular, RAW)
  * support max 6 cameras to bring up at the same time

* SDV11NM1 (Stereo, RAW)
  * support max 4 cameras to bring up at the same time

* Astra S56 (Stereo, RAW)
  * support max 2 cameras to bring up at the same time
 
* Astra S36 (Stereo, YUV)
  * support max 4 cameras to bring up at the same time

* SGX-YUV-GMSL2 (Monocular, YUV)

   * SG2-IMX390C-5200-G2A-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG2-AR0233-5200-G2A-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG3-ISX031C-GMSL2-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG3-ISX031C-GMSL2F-Hxxx
      * support max 8 cameras to bring up at the same time

   * SG5-IMX490C-5300-GMSL2-Hxxx
      * support max 6 cameras to bring up at the same time

   * SG8S-AR0820C-5300-G2A-Hxxx
      * support max 4 cameras to bring up at the same time

   * SHF3L
      * support max 8 cameras to bring up at the same time

   * SHF3H
      * support max 4 cameras to bring up at the same time


#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   CN2 (CAM0/CAM1/CAM2/CAM3)

   CN1 (CAM4/CAM5/CAM6/CAM7)

   Note: Stereo camera needs an even port (CAM0/2/4/6) and the next port must be free.


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
   /home/nvidia/TRD1_G2A_AGX_THOR_GMSL2x8_JP7.0_L4TR38.2
   ```

3. Select camera for cam_0~cam_7

   Enter the driver directory, run the script "generate_camera_overlay.py" to select camera.

   ```
   cd TRD1_G2A_AGX_THOR_GMSL2x8_JP7.0_L4TR38.2
   python3 generate_camera_overlay.py
   ```

   for example
   ```   
   nvidia@nvidia:~/TRD1_G2A_AGX_THOR_GMSL2x8_JP7.0_L4TR38.2$ python3 generate_camera_overlay.py
   Available models:
   0: ox08d (raw12)
   1: shw3g (raw12)
   2: shw5g (raw10)
   3: sgx-yuv-gmsl2 (uyvy)
   4: s36 (uyvy)
   5: s56 (raw10)
   6: sdv11nm1 (raw10)

   Select camera for cam_0 (0-6): 3
   Select camera for cam_1 (0-6): 3
   Select camera for cam_2 (0-6): 4
   Placed stereo pair 's36' on cam_2 and cam_3.
   Select camera for cam_4 (0-6): 5
   Placed stereo pair 's56' on cam_4 and cam_5.
   Select camera for cam_6 (0-6): 6
   Placed stereo pair 'sdv11nm1' on cam_6 and cam_7.

   Selected configurations:
   cam_0 -> sgx-yuv-gmsl2
   cam_1 -> sgx-yuv-gmsl2
   cam_2 -> s36
   cam_3 -> s36
   cam_4 -> s56
   cam_5 -> s56
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

   Generated: dts/tegra264-camera-sgcamx8-overlay.dts
   Compiling...
   Generated: dts/tegra264-camera-sgcamx8-overlay.dtbo

   --- Final Port Configuration ---
   Port 0 (cam_0): sgx-yuv-gmsl2 (uyvy)
   Port 1 (cam_1): sgx-yuv-gmsl2 (uyvy)
   Port 2 (cam_2): s36 (uyvy)
   Port 3 (cam_3): s36 (uyvy)
   Port 4 (cam_4): s56 (raw10)
   Port 5 (cam_5): s56 (raw10)
   Port 6 (cam_6): sdv11nm1 (raw10)
   Port 7 (cam_7): sdv11nm1 (raw10)
   --- End of Configuration ---
   ```

   After execution, a new DTB file is generated:

   dts/tegra264-camera-sgcamx8-overlay.dtbo

   
3. Install Kernel image and camera overly file

   ```
   cd TRD1_G2A_AGX_THOR_GMSL2x8_JP7.0_L4TR38.2
   chmod a+x ./install.sh
   ./install.sh
   ```

4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select camera overly file

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the device reboot, run the script "load_module.sh".

   5.1 Modify the script "load_modules.sh"

   Follow the "Camera Configuration Instructions.pdf" to modify load_modules.sh for the connected cameras.

   5.2 run the script "load_module.sh".
   ```
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video7 will be generated.
   
   5.3 Mixed use of 3G mode cameras (with F identifier: XXX-GMSL2F-XXX) and 6G mode cameras (without F identifier)

   If you wish to use the mixed mode, we have provided the following methods in the driver for your use.

   a.Determine the corresponding mode for each camera channel, where 3G is represented by (1) and 6G by (0).

   b.Load the driver manually according to the actual situation.

   ```
   sudo insmod ./ko/max96712.ko
   sudo insmod ko/sgcam-gmsl2.ko enable_3G_0=1,1,0,0 enable_3G_1=0,0,1,1
   ```
   
   enable_3G_0 represents the first input channel. The value `1,1,0,0` indicates that the first and second cameras operate in 3G mode, while the third and fourth cameras operate in 6G mode.
   
   enable_3G_1 represents the second input channel. The value `0,0,1,1` indicates that the first and second cameras operate in 6G mode, while the third and fourth cameras operate in 3G mode.

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

   7.1 Enable camera slave Mode

   Follow the "Camera Configuration Instructions.pdf", modify load_modules.sh script to enale slave mode, then re-run it.

   Below is a reference configuration to enable camera slave mode:

   ```
   # For shw3g module
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x36723377,trig_mode=1

   # For SG5-IMX490C-5300-GMSL2 module
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x00020008,trig_mode=1

   # For other camera modules
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   ```

   These configurations are interpreted as follows:

   trig_mode
   ```
   0 = Master mode, 1 = Slave mode
   ```

   trig_pin
   ```
   0x36723377 (Left to Right):
   36: Deserializer first trigger pin = mfp6, tx_id = 3
   72: Deserializer second trigger pin = mfp2, tx_id = 7
   33: Serializer first trigger pin = mfp3, rx_id = 3
   77: Serializer second trigger pin = mfp7, rx_id = 7

   0x00020007 (Left to Right):
   0002: Deserializer trigger pin = mfp2
   0007: Serializer trigger pin = mfp7
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

   For the SWH3G module, an additional 83kHz PWM signal is required on PIN4 (CAM-FSYNC4, for CAM0~CAM3) and PIN2 (CAM-FSYNC2, for CAM4~CAM5).
   
   ```
   CAM-FSYNC4 pin and CAM-FSYNC2 Pin Trigger Signal Parameters:
   Frequency: 83 kHz
   Amplitude: 3.3V
   Bias: 1.6V
   Duty Cycle: 90%
   ```

   7.2 Internal Trigger Mode

   Note: Internal trigger mode is not supported for SHW3G modules, but is supported for other modules.

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