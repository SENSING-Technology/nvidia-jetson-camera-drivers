## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG8A-AGON-G2Y-B1

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.2

#### Hardware Connect

* Using adapt board connect up to 8 cameras
  ![atl text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-AGON-G2Y-B1.png)

#### Power Supply

* SG8A-AGON-G2Y-B1 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.2   |
| ---- | --------------------------- | ------------- | ------------- |
| YUV  | SG1-OX01F10C-GMSL-Hxxx      | \             | \             |
| YUV  | SG1S-OX01F10C-G1G-Hxxx      | \             | \             |
| YUV  | SG2-AR0231C-0202-GMSL-Hxxx  | \             | \             |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | YES           | YES           |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | YES           | YES           |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | YES           | YES           |
| YUV  | SG3S-ISX031C-GMSL2-Hxxx     | YES           | YES           |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | YES           | YES           |
| YUV  | SG3S-OX03JC-G2F-Hxxx        | \             | \             |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | YES           | YES           |
| YUV  | SG5-OX05BC-4000-GMSL2-Hxxx  | \             | \             |
| YUV  | SG8S-AR0820C-5300-G2A-Hxxx  | YES           | YES           |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | YES           | YES           |


#### Camera Mapping

| FAKRA | Video  |
| ----- | ------ |
| CAM1  | video0 |
| CAM2  | video1 |
| CAM3  | video2 |
| CAM4  | video3 |
| CAM5  | video4 |
| CAM6  | video5 |
| CAM7  | video6 |
| CAM8  | video7 |
