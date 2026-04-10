#### Jetpack version

- Jetpack 6.2.1

#### Supported Camera Modules

- SGX-YUV-GMSL2 (Monocular)
  - YUV
    - SG2-AR0233C-5200-G2A-Hxxx
    - SG2-IMX390C-5200-G2A-Hxxx
    - SG2-OX03CC-5200-G2F-Hxxx
    - SG3S-ISX031C-GMSL2F-Hxxx
    - SG3S11AFxK
    - SG3S-ISX031C-GMSL2-Hxxx
    - SG3S-OX03JC-G2F-Hxxx
    - SG5-IMX490C-5300-GMSL2-Hxxx
    - OMSBDAAN
    - DMSBBFAN
    - SG8S-AR0820C-5300-G2A-Hxxx
    - SG8-ISX028C-G2G-Hxxx
    - SG8-OX08BC-5300-GMSL2-Hxxx
  - RAW
    - SG8-IMX728C-G2G-Hxxx

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
   /home/nvidia/SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4
   ```
   If you are using the real-time kernel:
   ```
   /home/nvidia/SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4_RT
   ```
3. Select camera for cam\_0\~cam\_7

   Enter the driver directory, run the script "generate\_camera\_overlay.py" to select camera.
   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4
   (cd SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4_rt)
   python3 generate_camera_overlay.py
   ```
   for example

   ```
   nvidia@nvidia-desktop:~/Desktop/SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4$ python3 generate_camera_overlay.py 
   Available models:
   0: imx728 (raw12)
   1: sgx-yuv-gmsl2 (uyvy)

   Select camera for cam_0 (0-1): 0
   Select camera for cam_1 (0-1): 0
   Select camera for cam_2 (0-1): 1
   Select camera for cam_3 (0-1): 1
   Select camera for cam_4 (0-1): 0
   Select camera for cam_5 (0-1): 0
   Select camera for cam_6 (0-1): 1
   Select camera for cam_7 (0-1): 1

   Selected configurations:
   cam_0 -> imx728
   cam_1 -> imx728
   cam_2 -> sgx-yuv-gmsl2
   cam_3 -> sgx-yuv-gmsl2
   cam_4 -> imx728
   cam_5 -> imx728
   cam_6 -> sgx-yuv-gmsl2
   cam_7 -> sgx-yuv-gmsl2

   Found cam_0@1a
   Found cam_1@1b
   Found cam_2@1c
   Found cam_3@1d
   Found cam_4@1a
   Found cam_5@1b
   Found cam_6@1c
   Found cam_7@1d

   Generated: dts/tegra234-camera-sgcamx8-overlay.dts
   Generated: dts/tegra234-camera-sgcamx8-overlay.dtbo

   --- Final Port Configuration ---
   Port 0 (cam_0): imx728 (raw12)
   Port 1 (cam_1): imx728 (raw12)
   Port 2 (cam_2): sgx-yuv-gmsl2 (uyvy)
   Port 3 (cam_3): sgx-yuv-gmsl2 (uyvy)
   Port 4 (cam_4): imx728 (raw12)
   Port 5 (cam_5): imx728 (raw12)
   Port 6 (cam_6): sgx-yuv-gmsl2 (uyvy)
   Port 7 (cam_7): sgx-yuv-gmsl2 (uyvy)
   --- End of Configuration ---

   ```
   Modify the rate mode and sensor mode in the camera_config.sh file:
   `camera_config.sh`
4. Install Kernel image and camera overly file
   ```
   cd SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4
   (cd SG8A_AGON_G2Y_A1_AGX_Orin_YUV_JP6.2.1_L4TR36.4.4_rt)
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
6. After the device reboot, run the script "load\_module.sh".

   5.1 Modify the script "load\_modules.sh"
   If you have already created the file "camera\_config.sh", then there is no need to make any modifications.

   If you want to modify the trigger mode, please refer to the following steps.

   trigger pin: 0x00020007（DES trigger pin: mfp2; SER trigger pin: mfp7）

   For some cameras, the trigger pin is MFP8. Please refer to the manual for confirmation.

   Auto trigger: trig\_mode=0; Orin trigger/ Ext Trigger: trig\_mode=1
   ```
   v4l2-ctl -d /dev/video0 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video1 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video2 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video3 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video4 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video5 -c sensor_mode=1,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video6 -c sensor_mode=4,trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video7 -c sensor_mode=4,trig_pin=0x00020007,trig_mode=1
   ```
   5.2 run the script "load\_module.sh".
   ```
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0\~video7 will be generated.
7. Bring up the camera

   6.1 Install argus\_camera
   ```
   sudo apt-get install nvidia-l4t-jetson-multimedia-api
   ```
   After installation, the jetson\_multimedia\_api folder can be found in the /usr/src directory. Then refer to the documentation "/usr/src/jetson\_multimedia\_api/argus/README.TXT" to install argus\_camera.

   6.2 Bring up YUV Camera Modules

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
8. Camera Trigger Sync

   7.1 Enable camera slave Mode

   Follow the "Camera Configuration Instructions.pdf", modify load\_modules.sh script to enale slave mode, then re-run it.

   Below is a reference configuration to enable camera slave mode:
   ```
   # For shw3g module

   v4l2-ctl -d /dev/video* -c sensor_mode=0,trig_pin=0x00020007,trig_mode=1
   ```
   These configurations are interpreted as follows:

   trig\_mode
   ```
   0 = Master mode, 1 = Slave mode
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
v4l2-ctl --stream-mmap --stream-count=0 -d /dev/video6
v4l2-ctl --stream-mmap --stream-count=0 -d /dev/video6 --verbose

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

