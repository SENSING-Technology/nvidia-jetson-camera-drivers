## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG8A-ORIN-GMSL2-F

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.0 DP
* Jetpack 6.0
* Jetpack 6.1
* Jetpack 6.2

#### Hardware Connect

* Using adapt board connect up to 8 cameras
  ![atl text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG8A-ORIN-GMSL2-F%20with%20Jetson%20AGX%20Orin%20Devkit.png)

#### Power Supply

* SG8A-ORIN-GMSL2-F adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.0DP | Jetpack 6.0 | Jetpack 6.1 | Jetpack 6.2 |
| ---- | --------------------------- | ------------- | ------------- | ----------- | ----------- | ----------- |
| YUV  | SG1-OX01F10C-GMSL-Hxxx      | YES           | YES           | YES         | \           | \           |
| YUV  | SG1S-OX01F10C-G1G-Hxxx      | YES           | \             | \           | \           | \           |
| YUV  | SG2-AR0231C-0202-GMSL-Hxxx  | YES           | YES           | YES         | \           | \           |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | YES           | YES           | YES         | \           | YES         |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | YES           | YES           | YES         | \           | YES         |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | YES           | YES           | YES         | \           | YES         |
| YUV  | SG3S-ISX031C-GMSL2-Hxxx     | YES           | YES           | YES         | \           | YES         |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | YES           | YES           | YES         | \           | YES         |
| YUV  | SG3S-OX03JC-G2F-Hxxx        | YES           | YES           | YES         | \           | \           |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | YES           | YES           | YES         | \           | YES         |
| YUV  | SG5-OX05BC-4000-GMSL2-Hxxx  | YES           | \             | \           | \           | \           |
| YUV  | SG8S-AR0820C-5300-G2A-Hxxx  | YES           | YES           | YES         | \           | YES         |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | YES           | YES           | YES         | \           | YES         |
| YUV  | SG8S-AR0820C-5300-G3A-Hxxx  | \             | \             | YES         | \           | \           |
| YUV  | DMSBBFAN                    | YES           | \             | \           | \           | YES         |
| RAW  | SG2-AR0233C-G2A-Hxxx        | YES           | \             | YES         | \           | \           |
| RAW  | SG2-IMX390C-G2A-Hxxx        | YES           | YES           | YES         | \           | \           |
| RAW  | SG2-IMX662C-G2A-Hxxx        | \             | \             | YES         | \           | \           |
| RAW  | SG2S-OX03CC-GMSL2-Hxxx      | YES           | \             | YES         | \           | \           |
| RAW  | SG2S-OX03CC-G2F-Hxxx        | \             | \             | \           | \           | \           |
| RAW  | SG3S-IMX623C-G2F-Hxxx       | \             | \             | \           | \           | \           |
| RAW  | SG5-IMX490C-GMSL2-Hxxx      | YES           | \             | \           | \           | \           |
| RAW  | SG8S-AR0820C-G2A-Hxxx       | YES           | \             | YES         | \           | \           |
| RAW  | SG8S-AR0823C-G2A-Hxxx       | \             | \             | YES         | \           | \           |
| RAW  | SG8-IMX728C-GMSL2-Hxxx      | YES           | \             | YES         | \           | \           |
| RAW  | SG8-IMX728C-G2G-Hxxx        | YES           | \             | YES         | \           | \           |
| RAW  | SG8S-OX08BC-G2A-Hxxx        | YES           | YES           | YES         | \           | \           |
| RAW  | SG8-OX08DC-G2A-Hxxx         | \             | \             | YES         | \           | \           |
| RAW  | SG8-IMX678C-G2A-Hxxx        | \             | \             | \           | YES         | \           |
| RAW  | SG8-1H1-G2A-Hxxx            | YES           | \             | \           | \           | \           |
| RAW  | SG8-IMX728C-G3A-Hxxx        | \             | \             | YES         | \           | \           |
| RAW  | SG8-IMX715C-G3A-Hxxx        | \             | \             | \           | YES         | \           |
| RAW  | SG12-IMX577C-G3A-Hxxx       | \             | \             | \           | YES         | \           |
| RAW  | SG17-IMX735C-G3A-Hxxx       | \             | \             | YES         | \           | \           |


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
