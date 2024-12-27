## SENSING Camera Drivers for Jetson Orin Nano Developer Kit adapt with SG2A-G2-M4L-F

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.0

#### Hardware Connect

* Using adapt board connect up to 2 cameras
  ![atl text](../../SENSING%20Deserializer%20Adapt%20Board/SG2A-G2-M4L-F%20with%20Jetson%20Orin%20Nano&NX%20Devkit.jpg)

#### Power Supply

* SG2A-G2-M4L-F adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.0DP | Jetpack 6.0 |
| ---- | --------------------------- | ------------- | ------------- | ----------- |
| YUV  | SG1-OX01F10C-GMSL-Hxxx      | \             | \             | \           |
| YUV  | SG1S-OX01F10C-G1G-Hxxx      | \             | \             | \           |
| YUV  | SG2-AR0231C-0202-GMSL-Hxxx  | \             | \             | \           |
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
| YUV  | SGN-NV6-G2F-Hxxx            | YES           | \             | \           |
| YUV  | SG8S-AR0820C-5300-G3A-Hxxx  | \             | \             | \           |
| RAW  | SG2-AR0233C-G2A-Hxxx        | \             | \             | \           |
| RAW  | SG2-IMX390C-G2A-Hxxx        | \             | \             | \           |
| RAW  | SG2-IMX662C-G2A-Hxxx        | \             | \             | \           |
| RAW  | SG2S-OX03CC-GMSL2-Hxxx      | \             | \             | \           |
| RAW  | SG2S-OX03CC-G2F-Hxxx        | \             | \             | \           |
| RAW  | SG3S-IMX623C-G2F-Hxxx       | YES           | \             | \           |
| RAW  | SG8S-AR0820C-G2A-Hxxx       | \             | \             | \           |
| RAW  | SG8S-AR0823C-G2A-Hxxx       | \             | \             | \           |
| RAW  | SG8-IMX728C-GMSL2-Hxxx      | \             | \             | \           |
| RAW  | SG8-IMX728C-G2G-Hxxx        | YES           | \             | \           |
| RAW  | SG8S-OX08BC-G2A-Hxxx        | \             | \             | \           |
| RAW  | SG8-OX08DC-G2A-Hxxx         | \             | \             | \           |
| RAW  | SG8-1H1-G2A-Hxxx            | \             | \             | \           |
| RAW  | SG8-IMX728C-G3A-Hxxx        | \             | \             | \           |
| RAW  | SG17-IMX735C-G3A-Hxxx       | \             | \             | \           |

#### Camera Mapping

| FAKRA | Video  |
| ----- | ------ |
| GMSL0 | video0 |
| GMSL1 | video1 |
