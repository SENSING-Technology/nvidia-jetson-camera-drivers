#### Jetpack version

* Jetpack 7.2

#### Supported Camera Modules

* SG8-OX08DC-G2G-Hxxx (Monocular, RAW)
  * support max 2 cameras to bring up at the same time

* SHW5G (Monocular, RAW)
  * support max 4 cameras to bring up at the same time

* Astra S56C (Stereo, RAW)
  * support max 2 cameras to bring up at the same time

* SGX-YUV-GMSL2 (Monocular, YUV)

   * SG2-IMX390C-5200-G2A-Hxxx
      * support max 4 cameras to bring up at the same time

   * SG2-AR0233-5200-G2A-Hxxx
      * support max 4 cameras to bring up at the same time

   * SG3-ISX031C-GMSL2-Hxxx
      * support max 4 cameras to bring up at the same time

   * SG3-ISX031C-GMSL2F-Hxxx
      * support max 4 cameras to bring up at the same time

   * SG5-IMX490C-5300-GMSL2-Hxxx
      * support max 3 cameras to bring up at the same time

   * SG8S-AR0820C-5300-G2A-Hxxx
      * support max 2 cameras to bring up at the same time

   * SG8-OX08DC-5300-G2G-Hxxx
      * support max 2 cameras to bring up at the same time   

   * SHF3L
      * support max 4 cameras to bring up at the same time

   * SHF3H
      * support max 2 cameras to bring up at the same time


#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

   CN7: CAM0

   CN6: CAM1

   CN5: CAM2

   CN4: CAM3


2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/nvidia-jetson-sipl-linux-39.2-jetpack-7.2
   ```
3. Enter the driver directory, run the script "install.sh""

   ```
   cd nvidia-jetson-sipl-linux-39.2-jetpack-7.2
   chmod a+x ./install.sh
   ./install.sh
   ```

4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select camera overly file

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson 22pin CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG4A_NONX_G2Y_A1 SIPL Camera"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

4. Bring up the camera

   After the device reboots, switch the Jetson device to maximum performance mode
   ```
   sudo nvpmodel -m 0
   sudo jetson_clocks
   ```

   4.1 For SG8-OX08DC-G2G-Hxxx Camera Module

   [How to bring up SG8_OX08DC_G2G Camera Module](docs/sg8_ox08dc_g2g.md)


   4.2 For SHW5G Camera Module

   [How to bring up SHW5G Camera Module](docs/shw5g.md)


   4.3 For Astra S56C Camera Module

   [How to bring up Astra S56C Camera Module](docs/s56c.md)


   4.4 For SGX-YUV-GMSL2 Camera Module

   [How to bring up SGX-YUV-GMSL2 Camera Module](docs/sgx_yuv_gmsl2.md)

