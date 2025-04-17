#### Jetpack version

* Jetpack 5.1.2

#### Supported SENSING Camera Modules

* SG8-AR0820C-5300-GMSL2-Hxxx

  * support max 6 cameras to light up at the same time

#### Quick Bring Up

1. Copy the driver package to the working directory of the Jetson device, such as “/home/nvidia”

   ```
   /home/nvidia/SG6C-ORNX-G2-F_OrinNX_OrinNano_AR0820-YUV_MAX9295x6_JP5.1.2_L4TR35.4.1
   ```
2. Enter the driver directory

   ```
   cd SG6C-ORNX-G2-F_OrinNX_OrinNano_AR0820-YUV_MAX9295x6_JP5.1.2_L4TR35.4.1
   ```
3. Grant execute permissions to the scripts, and pay attention to the system version

   ```
   #for Orin NX 8GB:
	chmod +x ./orinnx.8gb.fw.upgrade.sh
	./orinnx.8gb.fw.upgrade.sh
	
	#for Orin NX 16GB:
	chmod +x ./orinnx.16gb.fw.upgrade.sh
	./orinnx.16gb.fw.upgrade.sh
	
	#for Orin Nano 4GB:
	chmod +x ./orinnano.4gb.fw.upgrade
	./orinnano.4gb.fw.upgrade
	
	#for Orin Nano 8GB:
	chmod +x ./orinnano.8gb.fw.upgrade.sh
	./orinnano.8gb.fw.upgrade.sh
   ```
4. After the device reboots, run the script to light up the camera.

   ```
   cd SG6C-ORNX-G2-F_OrinNX_OrinNano_AR0820-YUV_MAX9295x6_JP5.1.2_L4TR35.4.1
   chmod +x ./lightupCamera.sh
   ./lightupCamera.sh
   ```