#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG3-ISX031C-GMSL2F-Hxxx

  * support max 12 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG12A_AGON_G2M_A1_AGX_Orin_YUV_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG12A_AGON_G2M_A1_AGX_Orin_YUV_JP5.1.2_L4TR35.4.1
   ```
3. Grant execute permissions to all scripts, then run the "install.sh" script and wait for the system to reboot

   ```
   chmod a+x *.sh
   ./install.sh
   ```
4. After the reboot, bring up the camera using the one connected to the CN1 port as an example

   ```
   v4l2-ctl -d /dev/video0 --set-ctrl sensor_mode=2
   gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev
   ``` 
