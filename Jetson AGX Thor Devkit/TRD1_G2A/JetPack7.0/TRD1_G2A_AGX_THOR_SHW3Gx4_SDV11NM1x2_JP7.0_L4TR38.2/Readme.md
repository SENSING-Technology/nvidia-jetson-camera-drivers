#### Jetpack version

* Jetpack 7.0

#### Supported Camera Modules

* SHW3G
  * support max 4 cameras to bring up at the same time
* SDV11NM1
  * support max 2 cameras to bring up at the same time


#### Quick Bring Up

1. Connect the Camera to the ports on the adapter board.

2. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/TRD1_G2A_AGX_THOR_SHW3Gx4_SDV11NM1x2_JP7.0_L4TR38.2
   ```
3. Enter the driver directory, run the script "install.sh""

   ```
   cd TRD1_G2A_AGX_THOR_SHW3Gx4_SDV11NM1x2_JP7.0_L4TR38.2
   chmod a+x ./install.sh
   ./install.sh
   ```
4. Use the "sudo /opt/nvidia/jetson-io/jetson-io.py" command to select the corresponding device

   ```
   sudo /opt/nvidia/jetson-io/jetson-io.py

   1.select "Configure Jetson AGX CSI Connector"
   2.select "Configure for compatible hardware"
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 SHW3Gx4+SDV11NM1x2"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```

5. After the device reboots, install v4l-utils plugins, then enter the driver directory and run the script "load_module.sh".

   ```
   sudo apt update
   sudo apt-get install v4l-utils
   sudo ./load_modules.sh
   ```
   After the module is loaded, the device nodes /dev/video0~video7 will be generated

   The correspondence between CAM ports and device nodes is as follows

    ```
    PORT                    DEV NODE                    Camera
    CN2(COAX4)              /dev/video0                 SHW3G
    CN2(COAX5)              /dev/video1                 SHW3G
    CN2(COAX6)              /dev/video2                 SHW3G
    CN2(COAX7)              /dev/video3                 SHW3G
    CN1(COAX0)              /dev/video4                 SDV11NM1
                            /dev/video5                 
    CN1(COAX2)              /dev/video6                 SDV11NM1
                            /dev/video7                 
 
    ```  

6. Bring up the camera

    6.1 Install argus_camera
    ```
    sudo apt-get install nvidia-l4t-jetson-multimedia-api
    ```
    After installation, the jetson_multimedia_api folder can be found in the /usr/src directory. Then refer to the documentation /usr/src/jetson_multimedia_api/argus/README.TXT to install argus_camera.

    6.2 Bring up SHW3G and SDV11NM1 Modules

    Start nvargus-daemon in a terminal
    ```
    sudo service nvargus-daemon stop
    export NVCAMERA_NITO_PATH=CONFIG
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
    ```

7. Camera Trigger Sync

   Modify load_modules.sh script and re-run it

   ```
   # For shw3g
   v4l2-ctl -d /dev/video0 -c trig_pin=0x36723377,trig_mode=1
   v4l2-ctl -d /dev/video1 -c trig_pin=0x36723377,trig_mode=1
   v4l2-ctl -d /dev/video2 -c trig_pin=0x36723377,trig_mode=1
   v4l2-ctl -d /dev/video3 -c trig_pin=0x36723377,trig_mode=1
   # For sdv11nm1
   v4l2-ctl -d /dev/video4 -c trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video5 -c trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video6 -c trig_pin=0x00020007,trig_mode=1
   v4l2-ctl -d /dev/video7 -c trig_pin=0x00020007,trig_mode=1
   ```

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

   7.1 External Trigger Mode

   External Trigger Port: CN4

   The PIN1(CAM-FSYNC1) and PIN6 correspond to the external trigger signal pin and ground pin respectively. 
   Connect the corresponding pins of the signal generator to these pins.

   For the SWH5G module, an additional 83kHz PWM signal is required on PIN4 (CAM-FSYNC1).
   
   ```
   CAM-FSYNC1 Pin Trigger Signal Parameters:
   Frequency: 30 Hz
   Amplitude: 3.3V
   Bias: 1.6V
   Duty Cycle: 10%

   CAM-FSYNC4 Pin Trigger Signal Parameters:
   Frequency: 83 kHz
   Amplitude: 3.3V
   Bias: 1.6V
   Duty Cycle: 90%

   PIN 6: GND
   ```

   7.2 Internal Trigger Mode

   Note: Internal trigger mode only works for SDV11NM1 modules, not for SHW3G modules.

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
   3.select "Jetson Sensing SG8A_AGTH_G2Y_A1 SHW3Gx8"
   4.select "Save pin changes"
   5.select "Save and reboot to reconfigure pins"
   ```
6. Install camera driver

   ```
   sudo insmod ko/max96712.ko
   sudo insmod ko/shw3g.ko
   sudo insmod ko/sdv11nm1.ko
   ```
7. Bring up the camera

   ```
    ## Video0
    argus_camera -d 0

    ## Video1
    argus_camera -d 1
    ......
   ```