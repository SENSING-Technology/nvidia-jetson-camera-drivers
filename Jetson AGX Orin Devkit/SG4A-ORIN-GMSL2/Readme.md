## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG4A-ORIN-GMSL2

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.2

#### Hardware Connect

* Using one adapt boart connect up to 4 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG4A-ORIN-GMSL2-1%20with%20Jetson%20AGX%20Orin.png)
* Using four adapt board connect up to 16 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG4A-ORIN-GMSL2%20with%20Jetson%20AGX%20Orin%20Devkit.png)

#### Power Supply

* SG4A-ORIN-GMSL2 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.0DP | Jetpack 6.2 |
| ---- | --------------------------- | ------------- | ------------- | ----------- |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | YES           | \             | YES         |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | YES           | \             | YES         |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | YES           | \             | YES         |
| YUV  | SG3S-ISX031C-GMSL2-Hxxx     | YES           | \             | YES         |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | YES           | \             | YES         |
| YUV  | SG3S-OX03JC-G2F-Hxxx        | YES           | \             | YES         |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | YES           | \             | YES         |
| YUV  | SG5-OX05BC-4000-GMSL2-Hxxx  | \             | \             | \           |
| YUV  | SG8S-AR0820C-5300-G2A-Hxxx  | YES           | \             | YES         |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | YES           | \             | YES         |
| YUV  | SN2M4EFGD                   | \             | \             | YES         |

#### Camera Mapping

| SG4A-ORIN | FAKRA | Video   |
| --------- | ----- | ------- |
| FPC1      | CAM0  | video0  |
| FPC1      | CAM1  | video1  |
| FPC1      | CAM2  | video2  |
| FPC1      | CAM3  | video3  |
| FPC2      | CAM4  | video4  |
| FPC2      | CAM5  | video5  |
| FPC2      | CAM6  | video6  |
| FPC2      | CAM7  | video7  |
| FPC3      | CAM8  | video8  |
| FPC3      | CAM9  | video9  |
| FPC3      | CAM10 | video10 |
| FPC3      | CAM11 | video11 |
| FPC4      | CAM12 | video12 |
| FPC4      | CAM13 | video13 |
| FPC4      | CAM14 | video14 |
| FPC4      | CAM15 | video15 |
