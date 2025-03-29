#### Jetpack version

* Jetpack 6.0

#### Supported SENSING Camera Modules

* Gemini 335Lg

  * support max 4 cameras to light up at the same time
* SHW3H

  * support max 6 cameras to light up at the same time
* SHF3L

  * support max 6 cameras to light up at the same time  

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as "/home/nvidia"

   ```
   /home/nvidia/SG10A-AGON-G2M-A1-AGX_G335Lg_SHW3H&SHF3L_JP6.0_L4TR36.3.0
   ```
2. Enter the driver directory,

   ```
   cd SG10A-AGON-G2M-A1-AGX_G335Lg_SHW3H&SHF3L_JP6.0_L4TR36.3.0
   chmod a+x ./install.sh
   ./install.sh
   ```
3. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Orbbec Camera G335Lg And SH3"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
4. reboot device

   ```
   sudo reboot
   ```
5. Install camera driver

   ```
   cd SG10A-AGON-G2M-A1-AGX_G335Lg_SHW3H&SHF3L_JP6.0_L4TR36.3.0
   chmod +x load_modules.sh
   ./load_modules.sh
   ```
6. Bring up the SHW3H camera (SHW3H camera is connected to the HDR Camera port, and SHF3L as well)

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
7. Bring up the Gemini 335Lg camera (Gemini 335Lg camera connected to D457 Camera port) 
  
   ```
   unzip OrbbecViewer_v2.0.18_202410190639_77d8dff_linux_aarch64.zip -d ./
   cd OrbbecViewer_v2.0.18_202410190639_77d8dff_linux_aarch64
   ./OrbbecViewer
   ```
8. After the program starts, you can select the device to open in the top-left corner
9. Click the Camera button on the left, then sequentially start the Color, Depth, IR Left, and IR Right 4 data streams.   
