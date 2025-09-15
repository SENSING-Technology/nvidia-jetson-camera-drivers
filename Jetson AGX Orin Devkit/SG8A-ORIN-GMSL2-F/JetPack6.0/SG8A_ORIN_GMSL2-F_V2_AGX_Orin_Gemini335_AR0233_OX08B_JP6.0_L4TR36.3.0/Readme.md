#### Jetpack version

* Jetpack 6.0

#### Supported SENSING Camera Modules

* Gemini 335Lg

  * support max 2 cameras to light up at the same time
* SG2-AR0233C-5200-G2A-Hxxx

  * support max 6 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx

  * support max 5 cameras to light up at the same time

#### Quick Bring Up
1. Connect the Camera to the ports on the carrier board.

   Gemini 335Lg: CAM0/CAM1
   SG2-AR0233C-5200-G2A/SG8-OX08BC-5300-GMSL2: CAM2/CAM3/CAM4/CAM5/CAM6/CAM7
   
   Note: CAM6/CAM7 cannot simultaneously connect two OX08B cameras.

2. Copy the driver package to the working directory of the Jetson device, such as "/home/nvidia"

   ```
   /home/nvidia/SG8A_ORIN_GMSL2-F_V2_AGX_Orin_Gemini335_AR0233_JP6.0_L4TR36.3.0
   ```
3. Enter the driver directory,

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_Gemini335_AR0233_JP6.0_L4TR36.3.0
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing Camera G335Lg AR0233 And OX08B"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
5. reboot device

   ```
   sudo reboot
   ```
6. Install camera driver

   Update load_modules.sh file based on connected camera resolution
   ```
   # sensor_mode, used for resolution settings (0: 1920×1080, 1: 3840×2160)
   v4l2-ctl -d /dev/video0 -c sensor_mode=0
   v4l2-ctl -d /dev/video1 -c sensor_mode=0
   v4l2-ctl -d /dev/video2 -c sensor_mode=0
   v4l2-ctl -d /dev/video3 -c sensor_mode=0
   v4l2-ctl -d /dev/video4 -c sensor_mode=0
   v4l2-ctl -d /dev/video5 -c sensor_mode=0
   ```

   then, load modules

   ```
   cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_Gemini335_AR0233_JP6.0_L4TR36.3.0
   chmod +x load_modules.sh
   ./load_modules.sh
   ```
7. After the device power on, the device nodes /dev/video0~video21 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    CAM2                    /dev/video0                 AR0233/OX08B
    CAM3                    /dev/video1                 AR0233/OX08B
    CAM4                    /dev/video2                 AR0233/OX08B
    CAM5                    /dev/video3                 AR0233/OX08B
    CAM6                    /dev/video4                 AR0233/OX08B
    CAM7                    /dev/video5                 AR0233/OX08B

    CAM0                    /dev/video6                 G335Lg
                            /dev/video7
                            /dev/video8
                            /dev/video9
                            /dev/video10
                            /dev/video11
                            /dev/video12
                            /dev/video13

    CAM1                    /dev/video14                G335Lg
                            /dev/video15
                            /dev/video16
                            /dev/video27
                            /dev/video18
                            /dev/video19
                            /dev/video20
                            /dev/video21
    ```
6. Bring up the AR0233/OX08B camera

   ```
   ## CAM2
    gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

   ## CAM3
    gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

   ## CAM4
    gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

   ## CAM5
    gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

   ## CAM6
    gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

   ## CAM7
    gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev
   ```
7. Bring up the Gemini 335Lg camera (The Gemini335 camera must be connected to the CAM0 and CAM1 ports) 
  
   ```
   unzip OrbbecViewer_v2.0.18_202410190639_77d8dff_linux_aarch64.zip -d ./
   cd OrbbecViewer_v2.0.18_202410190639_77d8dff_linux_aarch64
   ./OrbbecViewer
   ```
8. After the program starts, you can select the device to open in the top-left corner
9. Click the Camera button on the left, then sequentially start the Color, Depth, IR Left, and IR Right 4 data streams.   
