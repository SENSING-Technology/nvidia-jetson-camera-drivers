# SENSING Camera Drivers For NVIDIA Jetson Devices

SENSING Camera Drivers are developed base on NVIDIA Jetson Devices with or without SENSING Deserializer Adapt Board.

Users who are using SENSING Cameras can reference the driver to light up cameras on NVIDIA Jetson Devices.

#### **Supported NVIDIA Jetson Devices:**

* **Jetson AGX Orin Developer Kit**

  * Support AGX Orin 32G and 64G Module
    ![atl text](./Picture/NVIDIA%20Jetson%20Devices/Jetson%20AGX%20Orin%20Developer%20Kit.jpeg)
* **Jetson Orin Nano Developer Kit**

  * Support Orin Nano 4G and 8G Module
  * Support Orin NX 8G and 16G Module
    ![atl text](./Picture/NVIDIA%20Jetson%20Devices/Jetson%20Orin%20Nano%20Developer%20Kit.jpeg)

#### **Supported SENSING Deserialzer Adapt Boards:**

* **SG2A-G2-M4L-F**
  * SENSING Deserialzer Adapt Board with Maxim GMSL2 Deserialzer witch can support 2 GMSL/GMSL2 cameras
  * [Camera Support List](./Jetson%20Orin%20Nano&NX%20Devkit/SG2A-G2-M4L-F/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20Orin%20Nano&NX%20Devkit/SG2A-G2-M4L-F/)
  * Adapt to use with Jetson Orin Nano Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG2A-G2-M4L-F%20with%20Jetson%20Orin%20Nano&NX%20Devkit.jpg)
* **SG2A-G3-M4L**
  * SENSING Deserialzer Adapt Board with Maxim GMSL3 Deserialzer witch can support 2 GMSL3 cameras
  * [Camera Support List](./Jetson%20Orin%20Nano&NX%20Devkit/SG2A-G3-M4L/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20Orin%20Nano&NX%20Devkit/SG2A-G3-M4L/)
  * Adapt to use with Jetson Orin Nano Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG2A-G3-M4L-F%20with%20Jetson%20Orin%20Nano&NX%20Devkit.png)
* **SG4A-ORIN-GMSL2 & SG4A-NONX-G2Y-A1**
  * SG4A-ORIN-GMSL2 and SG4A-NONX-G2Y-A1 are identical in hardware
  * SENSING Deserialzer Adapt Board with Maxim GMSL2 Deserialzer witch can support 4 GMSL/GMSL2 cameras
  * User can stack 4 SG4A-ORIN-GMSL2 board to support up to 16 GMSL/GMSL2 cameras
  * [Camera Support List](./Jetson%20AGX%20Orin%20Devkit/SG4A-ORIN-GMSL2/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20AGX%20Orin%20Devkit/SG4A-ORIN-GMSL2/)
  * Adapt to use with Jetson AGX Orin Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG4A-ORIN-GMSL2%20with%20Jetson%20AGX%20Orin%20Devkit.png)
  * Adapt to use with Jetson Orin NANO Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG4A-NONX-G2Y-A1%20with%20Jetson%20Orin%20Nano&NX%20Devkit.png)  
* **SG8A-ORIN-GMSL2-F**
  * SENSING Deserialzer Adapt Board with Maxim GMSL2 Deserialzer witch can support 8 GMSL/GMSL2 cameras
  * [Camera Support List](./Jetson%20AGX%20Orin%20Devkit/SG8A-ORIN-GMSL2-F/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20AGX%20Orin%20Devkit/SG8A-ORIN-GMSL2-F/)
  * Adapt to use with Jetson AGX Orin Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-ORIN-GMSL2-F%20with%20Jetson%20AGX%20Orin%20Devkit.png)
  * Installation Video
    [Click to Watch](./Video/SG8A-ORIN-GMSL2-F%20Installation%20Video.mp4) 
* **SG8A-AGON-G2Y-B1**
  * SENSING Deserialzer Adapt Board with Maxim GMSL2 Deserialzer witch can support 8 GMSL2 cameras
  * [Camera Support List](./Jetson%20AGX%20Orin%20Devkit/SG8A-AGON-G2Y-B1/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20AGX%20Orin%20Devkit/SG8A-AGON-G2Y-B1/)
  * Adapt to use with Jetson AGX Orin Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-AGON-G2Y-B1.png)    
* **SG8A-ORIN-GMSL3-F**
  * SENSING Deserialzer Adapt Board with Maxim GMSL3 Deserialzer witch can support 8 GMSL3 cameras
  * [Camera Support List](./Jetson%20AGX%20Orin%20Devkit/SG8A-ORIN-GMSL3-F/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20AGX%20Orin%20Devkit/SG8A-ORIN-GMSL3-F/)
  * Adapt to use with Jetson AGX Orin Developer Kit
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-ORIN-GMSL2-F%20with%20Jetson%20AGX%20Orin%20Devkit.png)
* **SG10A-AGON-G2M-A1** 
  * SENSING Deserialzer Adapt Board with Maxim GMSL2 Deserialzer witch can support 10 GMSL/GMSL2 cameras  
  * [Camera Support List](./Jetson%20AGX%20Orin%20Devkit/SG10A-AGON-G2M-A1/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20AGX%20Orin%20Devkit/SG10A-AGON-G2M-A1/)
  * Adapter Board Image
    ![atl text](./Picture/SENSING%20Deserializer%20Adapt%20Board/SG10A-AGON-G2M-A1.png) 
  * Installation Video
    [Click to Watch](./Video/SG10A-AGON-G2M-A1%20Installation%20Video.mp4) 

#### **Supported SENSING Jetson Orin NANO&NX Carrier Board:**

#### **Download Specified Camera Driver Package:**

* **SG6C-ORNX-G2-F**
  * SENSING Jetson Orin NANO&NX Carrier Board with Maxim GMSL2 Deserialzer witch can support 6 GMSL/GMSL2 cameras 
  * [Camera Support List](./Jetson%20Orin%20Nano%20Carrier%20Board/SG6C-ORNX-G2-F/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20Orin%20Nano%20Carrier%20Board/SG6C-ORNX-G2-F/)
  * Adapter Board Image
    ![atl text](./Picture/SENSING%20Carrier%20Board/SG6C-ORNX-G2-F.png) 

* **SG6C-ORNX-G2-FA**
  * SENSING Jetson Orin NANO&NX Carrier Board with Maxim GMSL2 Deserialzer witch can support 6 GMSL/GMSL2 cameras 
  * [Camera Support List](./Jetson%20Orin%20Nano%20Carrier%20Board/SG6C-ORNX-G2-FA/Readme.md#camera-version-support)
  * [Camera Driver Package](./Jetson%20Orin%20Nano%20Carrier%20Board/SG6C-ORNX-G2-FA/)
  * Adapter Board Image
    ![atl text](./Picture/SENSING%20Carrier%20Board/SG6C-ORNX-G2-FA.png)

You can use DownGit to download specified camera driver package folder.

* Enter the path of the driver package folder to download and copy the link address in the browser's address bar
* Open the DownGit (https://minhaskamal.github.io/DownGit/#/home) webpage, and paste the link copied in the previous step into the address input box. Then click the Download button to start the download.
