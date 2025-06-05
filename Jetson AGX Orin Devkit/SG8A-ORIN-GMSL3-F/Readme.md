## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG8A-ORIN-GMSL3-F

#### Supported Jetpack

* Jetpack 6.0
* Jetpack 6.1

#### Hardware Connect

* Using adapt board connect up to 8 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-ORIN-GMSL2-F%20with%20Jetson%20AGX%20Orin%20Devkit.png)

#### Power Supply

* SG8A-ORIN-GMSL3-F adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 6.0 | Jetpack 6.1 |
| ---- | --------------------------- | ----------- | ----------- |
| YUV  | SG8S-AR0820C-5300-G3A-Hxxx  | YES         | \           |
| RAW  | SG8-IMX728C-G3A-Hxxx        | YES         | \           |
| RAW  | SG8-IMX715C-G3A-Hxxx        | \           | YES         |
| RAW  | SG12-IMX577C-G3A-Hxxx       | \           | YES         |
| RAW  | SG17-IMX735C-G3A-Hxxx       | YES         | \           |


#### Camera Mapping

| FAKRA | Video  |
| ----- | ------ |
| CAM0  | video0 |
| CAM1  | video1 |
| CAM2  | video2 |
| CAM3  | video3 |
| CAM4  | video4 |
| CAM5  | video5 |
| CAM6  | video6 |
| CAM7  | video7 |
