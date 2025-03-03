## Camera Drivers for Jetson Orin Nano Developer Kit adapt with SG4P-AP-G2Y

#### Supported Jetpack

* Jetpack 6.0
* Jetpack 6.1

#### Hardware Connect

* Using adapt board connect up to 4 cameras
  ![atl text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG4A-NONX-G2Y-A1%20with%20Jetson%20Orin%20Nano&NX%20Devkit.png)

#### Power Supply

* SG4A-NONX-G2Y-A1 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.0 | Jetpack 6.1 |
| ---- | --------------------------- | ------------- | ----------- | ----------- |
| YUV  | SG1-AR0144C-8310-GMSL-Hxxx  | \             | YES         | YES         |
| YUV  | SG2-AR0231C-0202-GMSL-Hxxx  | \             | YES         | YES         |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | \             | YES         | YES         |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | \             | YES         | YES         |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | \             | YES         | YES         |
| YUV  | SG3S-ISX031C-GMSL2-Hxxx     | \             | YES         | YES         |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | \             | YES         | YES         |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | \             | YES         | YES         |
| YUV  | SG5-OX05BC-4000-GMSL2-Hxxx  | \             | \           | \           |
| YUV  | SG8S-AR0820C-5300-G3A-Hxxx  | \             | YES         | YES         |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | \             | YES         | YES         |

#### Camera Mapping

| FAKRA | Video  |
| ----- | ------ |
|  CN7  | video0 |
|  CN6  | video1 |
|  CN5  | video2 |
|  CN4  | video3 |
