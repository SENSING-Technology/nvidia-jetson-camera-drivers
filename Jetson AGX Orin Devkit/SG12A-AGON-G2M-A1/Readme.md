## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG12A-AGON-G2M-A1

#### Supported Jetpack

* Jetpack 5.1.2
* Jetpack 6.2

#### Hardware Connect

* Using adapt board connect up to 12 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG12A-AGON-G2M-A1.png)

#### Power Supply

* SG12A-AGON-G2M-A1 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 5.1.2 | Jetpack 6.2 |
| ---- | --------------------------- | ------------- | ----------- |
| YUV  | SG2-AR0233C-5200-G2A-Hxxx   | /             | YES         |
| YUV  | SG2-IMX390C-5200-G2A-Hxxx   | /             | YES         |
| YUV  | SG2-OX03CC-5200-GMSL2F-Hxxx | /             | YES         |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | YES           | YES         |
| YUV  | SG5-IMX490C-5300-GMSL2-Hxxx | /             | YES         |
| YUV  | SG8S-AR0820C-5300-G2A-Hxxx  | /             | YES         |
| YUV  | SG8-OX08BC-5300-GMSL2-Hxxx  | /             | YES         |

#### Camera Mapping

| FAKRA |      Video      |
| ----- | --------------- |
| CN1   |   /dev/video0   |
| CN2   |   /dev/video1   |
| CN3   |   /dev/video2   |
| CN4   |   /dev/video3   |
| CN5   |   /dev/video4   |
| CN6   |   /dev/video5   | 
| CN7   |   /dev/video6   |
| CN8   |   /dev/video7   |
| CN9   |   /dev/video10  |
| CN10  |   /dev/video11  |
| CN11  |   /dev/video8   |
| CN12  |   /dev/video9   |
