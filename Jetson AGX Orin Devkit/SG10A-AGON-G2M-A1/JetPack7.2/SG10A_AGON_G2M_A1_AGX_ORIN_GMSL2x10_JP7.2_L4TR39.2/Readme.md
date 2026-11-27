#### Jetpack version

* Jetpack 7.2

#### Camera models

```
Camera Model                   Camera Type                 Resolution  frame_rate    Data Format      GMSL2 Rate      Trigger Pin     MaxDevices
SG2-AR0233C-5200-G2A-Hxxx       Monocular                 1920*1080U    30fps           UYVY            6Gbps          mfp7              10                 
SG3S11AFSK or SYF3L             Monocular                 1920*1536U    30fps           UYVY            3Gbps          mfp7              10
SHF3L                           Monocular                 1920*1536U    30fps           UYVY            6Gbps          mfp7              10
SHW3H                           Monocular                 1920*1536U    60fps           UYVY            6Gbps          mfp7              8
SG8-OX08DC-5300-G2G-Hxxx        Monocular                 3840*2160U    30fps           UYVY            6Gbps          mfp7              8
S56C or S56D                    Stereo                   2560*1984U    30fps           RAW10           6Gbps          mfp7              5
S56                             Stereo                   2560*1984U    30fps           RAW10           6Gbps          mfp7              5
S36 or S36A                     Stereo                   1920*1536U    30fps           UYVY            6Gbps          mfp7              5
SHW5G                           Monocular                 2560*1984U    30fps           RAW10           6Gbps          mfp7              10
SHW3G                           Monocular                 2064*1552U    30fps           RAW12           6Gbps        mfp7、mfp3          9
```

#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   1.1 Mapping of hardware ports to /dev/video nodes

    The mapping between physical CAM ports and their corresponding /dev/video device nodes is illustrated below:
     
    A1 connector mapping: CAM0–9 = J25, J26, J23, J24, J21, J22, J27, J28, J29, J30.
    A1 board photo: [cam.jpg](picture/cam.jpg).
    ```
    ```
    Note: Stereo camera needs an even port (CAM0/2/4/6/8) and the next port must be free.

   1.2 Power Supply

   SG10A_AGON_G2M_A1 adapt board need to be powered by 12V.
 

2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG10A_AGON_G2M_A1_AGX_ORIN_GMSL2x10_JP7.2_L4TR39.2
   ```
3. Select camera for cam_0~cam_9

   Enter the driver directory, run the script "generate_camera_overlay.py" to select camera.

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_GMSL2x10_JP7.2_L4TR39.2
   python3 generate_camera_overlay.py
   ```

   for example
   ```   
   nvidia@nvidia:~/SG10A_AGON_G2M_A1_AGX_ORIN_GMSL2x10_JP7.2_L4TR39.2$ python3 generate_camera_overlay.py
   Available models:
   0: shw3g (raw12)
   1: sgx-yuv-gmsl2 (uyvy)
   2: shw5g (raw10)
   3: S56C or S56D (raw10)
   4: S36 or S36A (uyvy)
   3: s56 (raw10)

   Select camera for cam_0 (0-4): 3
   Placed stereo pair 'S56C or S56D' on cam_0 and cam_1.
   Select camera for cam_2 (0-4): 1
   Select camera for cam_3 (0-4): 1
   Select camera for cam_4 (0-4): 1
   Select camera for cam_5 (0-4): 1
   Select camera for cam_6 (0-4): 3
   Placed stereo pair 'S56C or S56D' on cam_6 and cam_7.
   Select camera for cam_8 (0-4): 1
   Select camera for cam_9 (0-4): 1

   Selected configurations:
   cam_0@1b -> S56C or S56D
   cam_1@1c -> S56C or S56D
   cam_2@1b -> sgx-yuv-gmsl2
   cam_3@1c -> sgx-yuv-gmsl2
   cam_4@1b -> sgx-yuv-gmsl2
   cam_5@1c -> sgx-yuv-gmsl2
   cam_6@1b -> S56C or S56D
   cam_7@1c -> S56C or S56D
   cam_8@1d -> sgx-yuv-gmsl2
   cam_9@1e -> sgx-yuv-gmsl2

   Found cam_0@1b
   Found cam_1@1c
   Found cam_2@1b
   Found cam_3@1c
   Found cam_4@1b
   Found cam_5@1c
   Found cam_6@1b
   Found cam_7@1c
   Found cam_8@1d
   Found cam_9@1e

   Generated: dts/tegra234-camera-sgcamx10-overlay.dts
   Compiling...
   Generated: dts/tegra234-camera-sgcamx10-overlay.dtbo

   --- Final Port Configuration ---
   Port 0 (cam_0@1b): S56C or S56D (raw10)
   Port 1 (cam_1@1c): S56C or S56D (raw10)
   Port 2 (cam_2@1b): sgx-yuv-gmsl2 (uyvy)
   Port 3 (cam_3@1c): sgx-yuv-gmsl2 (uyvy)
   Port 4 (cam_4@1b): sgx-yuv-gmsl2 (uyvy)
   Port 5 (cam_5@1c): sgx-yuv-gmsl2 (uyvy)
   Port 6 (cam_6@1b): S56C or S56D (raw10)
   Port 7 (cam_7@1c): S56C or S56D (raw10)
   Port 8 (cam_8@1d): sgx-yuv-gmsl2 (uyvy)
   Port 9 (cam_9@1e): sgx-yuv-gmsl2 (uyvy)
   --- End of Configuration ---
   ```
   
   After execution, a new DTB file is generated:
   

   dts/tegra234-camera-sgcamx10-overlay.dtbo
4. Enter the driver directory, run the script "install.sh"

   ```
   cd SG10A_AGON_G2M_A1_AGX_ORIN_GMSL2x10_JP7.2_L4TR39.2
   chmod a+x ./install.sh
   ./install.sh
   ```
   
5. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device.

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG10A_AGON_G2M_A1 SGCAM_GMSL2x10"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
Disable the earlier custom camera overlay when enabling this overlay.

6. Edit the load_modules.sh script and execute it.

   6.1 After reboot,Modify the video device configuration command lines.

   The following commands are used to configure the cameras recognized as video0 to video9 in the system.
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=0,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00070007,trig_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=2,gmsl_mode=1,trig_pin=0x00060007,trig_mode=0
   v4l2-ctl -d /dev/video6 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
   v4l2-ctl -d /dev/video7 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
   v4l2-ctl -d /dev/video8 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
   v4l2-ctl -d /dev/video9 -c sensor_mode=2,gmsl_mode=0,trig_pin=0x00060007,trig_mode=0
   ```
   ```
   # sensor_mode:
   For YUV  Camera:
   1920*1080：sensor_mode=1,1920*1536：sensor_mode=2,2880*1860:sensor_mode=3,3840*2160：sensor_mode=4;
   For RAW  Camera：sensor_mode=0.

   # gmsl_mode:
   
   # gmsl_mode=0:6Gbps, gmsl_mode=1:3Gbps(only SG3S11AFSK or SYF3L).
   

   After the module is loaded, the device nodes /dev/video0~video9 will be generated.

7. Camera Trigger Sync
   # trig_pin / trig_mode :
   `trig_mode=0` for free running and `trig_mode=2` for synchronization from
   either the Orin PWM or an external pulse source. 
   MAX9296 (verified video0~3): trig_pin=0x00070007,trig_mode=2
   MAX9296 / MAX96712 (verified video4~9): trig_pin=0x00060007,trig_mode=2

   7.1 Check the camera configuration before testing a trigger

   ```bash
   
   sudo ./load_modules.sh
   
   ```

   7.2 Synchronization from Orin PWM (J19 jumper required)

   ```bash
   sudo ./pwm.sh
   ```

   `pwm.sh` locates the `pwm-gpio` provider automatically. Run
   `sudo ./pwm.sh` (30 Hz), `sudo ./pwm.sh 20` (20 Hz), or


   7.3 External trigger from a signal generator

   | J19 pin | Signal | Destination |
   | --- | --- | --- |
   | 1 | GND | Ground |
   | 2 | SYNC1 | U19 and U4 |
   | 3 | GND | Ground |
   | 4 | SYNC2 | U13 and U3 |

   turn the generator output OFF. Stop the Orin
   PWM:

   ```bash
   sudo ./pwm.sh stop
   
   ```

8. Bring up cameras

   8.1 Bring up the  YUV camera
   
   ```
   ## Video0
   gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## Video1
   gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## Video2
   gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## Video3
   gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## Video4
   gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## Video5
   gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev

   ## Video6
   gst-launch-1.0 v4l2src device=/dev/video6 ! xvimagesink -ev

   ## Video7
   gst-launch-1.0 v4l2src device=/dev/video7 ! xvimagesink -ev

   ## Video8
   gst-launch-1.0 v4l2src device=/dev/video8 ! xvimagesink -ev

   ## Video9
   gst-launch-1.0 v4l2src device=/dev/video9 ! xvimagesink -ev

   ```
   
   ```

   8.2 Install argus_camera
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   
   sudo ./argus_install.sh
   
   ```
   8.3 Bring up the  RAW camera
   Start nvargus-daemon in a terminal
   ```
   #for shw5g, S56C , S56D, S56
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/shw5g.nito
   sudo -E enableCamInfiniteTimeout=1 nvargus-daemon

   #for shw3g
   sudo service nvargus-daemon stop
   export NVCAMERA_NITO_PATH=/var/nvidia/nvcam/settings/shw3g.nito
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

   ## Video8
   argus_camera -d 8

   ## Video9
   argus_camera -d 9
   ```
 
8. IMU Testing 
   
      Only for S56C or S56D Camera.

     The IMU driver operates in polling mode.

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
