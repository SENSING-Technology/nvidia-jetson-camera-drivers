## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG8A-AGON-G2Y-A1

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.2
* Jetpack 6.2.1

#### Hardware Connect

* Using adapt board connect up to 8 cameras
  ![atl text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-AGON-G2Y-A1.png)

#### Power Supply

* SG8A-AGON-G2Y-A1 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.2   | Jetpack 6.2.1 |
| ---- | --------------------------- | ------------- | ------------- | ------------- |
| YUV  | SG1-OX01F10C-GMSL-Hxxx      | \             | \             | \             |
| YUV  | SG1S-OX01F10C-G1G-Hxxx      | \             | \             | \             |
| YUV  | SG2-AR0231C-0202-GMSL-Hxxx  | \             | \             | \             |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | YES           | YES           | YES           |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | YES           | YES           | YES           |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | YES           | YES           | YES           |
| YUV  | SG3S-ISX031C-GMSL2-Hxxx     | YES           | YES           | YES           |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | YES           | YES           | YES           |
| YUV  | SG3S-OX03JC-G2F-Hxxx        | \             | \             | YES           |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | YES           | YES           | YES           |
| YUV  | OMSBDAAN                    | \             | YES           | YES           |
| YUV  | DMSBBFAN                    | \             | YES           | YES           |
| YUV  | SG8S-AR0820C-5300-G2A-Hxxx  | YES           | YES           | YES           |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | YES           | YES           | YES           |
| YUV  | SG8-ISX028C-G2G-Hxxx        | \             | YES           | YES           |
| YUV  | RedFox-D3GN                 | \             | YES           | \             |
| YUV  | SH3-S11A60-G2A-Hxxx         | \             | YES           | \             |
| YUV  | SN2M4EFGD                   | \             | YES           | \             |
| YUV  | SG1Z2AESH                   | \             | YES           | \             |
| RAW  | SG8-IMX728C-G2G-Hxxx        | \             | \             | YES           |
| RAW  | SDV11NM1                    | \             | YES           | \             |
| RAW  | SHW3G                       | \             | YES           | \             |


#### Camera Mapping

|    PORT    |   DEV NODE  |
| ---------- | ----------- |
| CN2(CAM0)  | /dev/video0 |
| CN2(CAM1)  | /dev/video1 |
| CN2(CAM2)  | /dev/video2 |
| CN2(CAM3)  | /dev/video3 |
| CN1(CAM4)  | /dev/video4 |
| CN1(CAM5)  | /dev/video5 |
| CN1(CAM6)  | /dev/video6 |
| CN1(CAM7)  | /dev/video7 |
