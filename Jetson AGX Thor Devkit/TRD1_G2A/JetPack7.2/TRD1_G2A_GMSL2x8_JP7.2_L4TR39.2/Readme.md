#### Jetpack version

* Jetpack 7.2

#### Supported Camera Modules
```
Camera Model                        Camera Type      Resolution   Frame Rate     Data Format      GMSL2 Rate   Trigger Pin     MaxDevices
SG2-AR0233C-5200-G2A-Hxxx            Monocular       1920*1080U    30fps           UYVY            6Gbps          mfp7              8
SG2-IMX390C-5200-G2A-Hxxx            Monocular       1920*1080U    30fps           UYVY            6Gbps          mfp7              8
SG3S-ISX031C-GMSL2F-Hxxx             Monocular       1920*1536U    30fps           UYVY            3Gbps          mfp7              8
SG3S-ISX031C-GMSL2-Hxxx              Monocular       1920*1536U    30fps           UYVY            6Gbps          mfp7              8
SG5-IMX490C-5300-GMSL2-Hxxx          Monocular       2880*1860U    30fps           UYVY            6Gbps          mfp8              6
SG8S-AR0820C-5300-G2A-Hxxx           Monocular       3840*2160U    30fps           UYVY            6Gbps          mfp7              4
SG8-ISX028C-G2G-Hxxx                 Monocular       3840*2160U    30fps           UYVY            6Gbps          mfp7              4
SG8-OX08DC-5300-G2G-Hxxx             Monocular       3840*2160U    30fps           UYVY            6Gbps          mfp8              4
SG2-ISX021C-G2F-H120KA               Monocular       1920*1080U    30fps           UYVY            3Gbps          mfp7              8
SG3S11AFLK                           Monocular       1920*1536U    30fps           UYVY            3Gbps          mfp7              8
SHW3H                                Monocular       1920*1536U    60fps           UYVY            6Gbps          mfp7              4
SHF3L                                Monocular       1920*1536U    30fps           UYVY            6Gbps          mfp7              8
Astra S36                            Stereo          1920*1536U    30fps           UYVY            6Gbps          mfp7              4
SHW5G                                Monocular       2064*1552U    30fps           RAW10           6Gbps          mfp7              6
SG8-IMX728C-G2G-Hxxx                 Monocular       2880*1860U    30fps           RAW12           6Gbps          mfp7              4
Astra  S56C                          Stereo          2560*1984U    30fps           RAW10           6Gbps          mfp7              4
SHW3G                                Monocular       2064*1552U    30fps           RAW12           6Gbps        mfp7、mfp3           6
SDV11NM1                             Stereo          2592*1944U    30fps           RAW10           6Gbps          mfp7              4
 ```               

#### Quick Bring Up

1. Flashing:

    Since NVIDIA's official pinmux definitions do not enable the I2C functionality for I2C9, nor do they enable GPIO functionality for CAM0_PWDN and CAM1_PWDN, it is necessary to modify the pinmux definitions and re-flash the device.

    Copy and replace the files in TRD1_G2A_GMSL2x8_JP7.2_L4TR39.2/source/Linux_for_Tegra/bootloader/ from the driver package to &lt$work_path&gt/Linux_for_Tegra/bootloader/

    

2. Connect the Camera to the ports on the adapter board.

   ```
   CN1 (CAM0/CAM1/CAM2/CAM3)
   CN2 (CAM4/CAM5/CAM6/CAM7)

   Note: Stereo camera needs an even port (CAM0/2/4/6) and the next port must be free.
   ```
   ![alt text](picture/cam.png)

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
   ![alt text](picture/image-cn.jpg)

   SG8A-AGON-G2Y-A1 adapt board need to be powered by 12V.
3. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/TRD1_G2A_GMSL2x8_JP7.2_L4TR39.2
   ```

4. Select camera for cam_0~cam_7

   Enter the driver directory, run the script "generate_camera_overlay.py" to select camera.

   ```
   cd TRD1_G2A_GMSL2x8_JP7.2_L4TR39.2
   python3 generate_camera_overlay.py
   ```

   for example
   ```   
   nvidia@nvidia:~/TRD1_G2A_GMSL2x8_JP7.2_L4TR39.2$ python3 generate_camera_overlay.py
   Available models:
      0: shw3g (raw12)
      1: sgx-yuv-gmsl2 (uyvy)
      2: imx728 (raw12)
      3: shw5g (raw10)
      4: s36 (uyvy)
      5: s56 (raw10)
      6: sdv11nm1 (raw10)
   
   Select camera for cam_0 (0-6): 6
   Placed stereo pair 'sdv11nm1' on cam_0 and cam_1.
   Select camera for cam_2 (0-6): 1
   Select camera for cam_3 (0-6): 1
   Select camera for cam_4 (0-6): 1
   Select camera for cam_5 (0-6): 1
   Select camera for cam_6 (0-6): 1
   Select camera for cam_7 (0-6): 1
   
   Selected configurations:
   cam_0 -> sdv11nm1
   cam_1 -> sdv11nm1
   cam_2 -> sgx-yuv-gmsl2
   cam_3 -> sgx-yuv-gmsl2
   cam_4 -> sgx-yuv-gmsl2
   cam_5 -> sgx-yuv-gmsl2
   cam_6 -> sgx-yuv-gmsl2
   cam_7 -> sgx-yuv-gmsl2

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
   Port 0 (cam_0): sdv11nm1 (raw10)
   Port 1 (cam_1): sdv11nm1 (raw10)
   Port 2 (cam_2): sgx-yuv-gmsl2 (uyvy)
   Port 3 (cam_3): sgx-yuv-gmsl2 (uyvy)
   Port 4 (cam_4): sgx-yuv-gmsl2 (uyvy)
   Port 5 (cam_5): sgx-yuv-gmsl2 (uyvy)
   Port 6 (cam_6): sgx-yuv-gmsl2 (uyvy)
   Port 7 (cam_7): sgx-yuv-gmsl2 (uyvy)
   --- End of Configuration ---
   ```
   
   After execution, a new DTB file is generated:
   

   dts/tegra264-camera-sgcamx8-overlay.dtbo

5. Install Kernel image and camera overly file

   ```
   cd TRD1_G2A_GMSL2x8_JP7.2_L4TR39.2
   chmod a+x ./install.sh
   ./install.sh
   ```

6. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select camera overly file

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 GMSL2x8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

7. After the device reboot, run the script "load_module.sh".

   7.1 run the script "load_module.sh".

   ```
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video7 will be generated.

   7.2 Mixed use of 3G mode cameras (with F identifier: XXX-GMSL2F-XXX) and 6G mode cameras (without F identifier)

   If you wish to use the mixed mode, we have provided the following methods in the driver for your use.

   a.Determine the corresponding mode for each camera channel, where 3G is represented by (1) and 6G by (0).

   b.Load the driver manually according to the actual situation.

   ```
   sudo insmod ./ko/max96712.ko
   sudo insmod ko/sgcam-gmsl2.ko enable_3G_0=1,1,0,0 enable_3G_1=0,0,1,1
   ```

   enable_3G_0 represents the first input channel. The value `1,1,0,0` indicates that the first and second cameras operate in 3G mode, while the third and fourth cameras operate in 6G mode.

   enable_3G_1 represents the second input channel. The value 0,0,1,1 indicates that the fifth and sixth cameras operate in 6G mode, while the seventh and eighth cameras operate in 3G mode.

8. Bring up the camera

   8.1 Install argus_camera
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   After installation, the jetson_multimedia_api folder can be found in the /usr/src directory. Then refer to the documentation "/usr/src/jetson_multimedia_api/argus/README.TXT" to install argus_camera.

   You can refer to the commands in "argus_install.sh" for installation.

   8.2 Bring up RAW Camera Modules

   Start nvargus-daemon in a terminal
   ```
   #for SHW3G
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/shw3g.nito
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon

   #for IMX728
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/imx728.nito
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon

   #for S56C、SHW5G
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/shw5g.nito
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon

   #for sdv11nm1
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/sdv11nm1.nito
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon
   ```
   Note:This version does not support mixing different RAW cameras, with the exception of mixing Astra S56C and SHW5G.

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
   
   8.3 Bring up YUV Camera Modules

   Set YUV camera format

   ```
   v4l2-ctl -d /dev/video* -c sensor_mode=1,trig_pin=0x00020007,trig_mode=0
   ```

   **/dev/video*** ： For the corresponding video node

   **sensor_mode**：Different YUV camera resolutions

   SG2-AR0233-5200-G2A-Hxxx、SG2-IMX390C-5200-G2A-Hxxx、SG2-ISX021C-G2F-H120KA：sensor_mode=0

   SG3S-ISX031C-GMSL2F-Hxxx、SG3S-ISX031C-GMSL2-Hxxx、SG3S11AFLK 、SHF3L、SHW3H： sensor_mode=1

   SG5-IMX490C-5300-GMSL2-Hxxx ：sensor_mode=2

   SG8S-AR0820-5200-G2A-Hxxx、SG8-OX08DC-5300-G2G-Hxxx： sensor_mode=3

   SG8-ISX028C-G2G-Hxxx：sensor_mode=5

   **trig_pin、trig_mode**：The trigger mode will be used. Now, it will be set to the default settings.

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

9. Camera Trigger Sync

   9.1 Enable camera slave Mode

   Below is a reference configuration to enable camera slave mode:

   ```
   # For shw3g module
   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x36723377,trig_mode=1

   For SG5-IMX490C-5300-GMSL2-Hxxx
   v4l2-ctl -d /dev/video* -c sensor_mode=2,trig_pin=0x00020008,trig_mode=1

   # For other camera modules
   v4l2-ctl -d /dev/video* -c sensor_mode=*,trig_pin=0x00020007,trig_mode=1
   ```

   These configurations are interpreted as follows:

   ```
   trig_mode:0 = Master mode, 1 = Slave mode
   ```

   ```
   trig_pin:
   0x36723377 (Left to Right):
      36: Deserializer first trigger pin = mfp6, tx_id = 3
      72: Deserializer second trigger pin = mfp2, tx_id = 7
      33: Serializer first trigger pin = mfp3, rx_id = 3
      77: Serializer second trigger pin = mfp7, rx_id = 7

   0x00020007 (Left to Right):
      0002: Deserializer trigger pin = mfp2
      0007: Serializer trigger pin = mfp7

   0x00020008 (Left to Right):
      0002: Deserializer trigger pin = mfp2
      0008: Serializer trigger pin = mfp8
   ```


   9.2 External Trigger Mode

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


   9.3 Internal Trigger Mode

   Note: Internal trigger mode is not supported for SHW3G modules, but is supported for other modules.

   ```
   # Export PWM channel 0

   echo 0 > /sys/class/pwm/pwmchip4/export

   # Set the period to 33333333 (corresponding to 30 Hz)

   echo 33333333 > /sys/class/pwm/pwmchip4/pwm0/period

   # Set the duty cycle

   echo 30000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle

   # Enable PWM output

   echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable
   ```
10. IMU Testing 
   
      Only for S56 Camera.

      Since no interrupt pin is reserved in the hardware, the IMU driver operates in polling mode.

      ```
      sudo rmmod bmi088  >/dev/null 2>&1
      sudo rmmod kfifo_buf  >/dev/null 2>&1
      sudo insmod ko/kfifo_buf.ko
      sudo insmod ko/bmi088.ko
      cd sample/bmi088/
      make clean && make
      ```

      Accelerometer Sample Output
      ```
      sudo ./iio_generic_buffer -a -c 10 --device-name accelerometer -g
      ```

      Gyroscope Sample Output
      ```
      sudo ./iio_generic_buffer -a -c 10 --device-name gyroscope -g
      ```
