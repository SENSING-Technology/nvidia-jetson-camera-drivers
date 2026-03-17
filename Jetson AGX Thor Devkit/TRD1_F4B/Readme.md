## SENSING Camera Drivers for Jetson AGX Thor Developer Kit adapt with TRD1 F4B

#### Supported Jetpack

* Jetpack 7.0

#### Hardware Connect

* Using adapt board connect up to 8 cameras
  ![alt text](../../Picture/SENSING%20Thor%20Developer%20Kit/TRD1%20G2A%20Camera%20Interface%20Definition.jpg)

#### Power Supply

* SG8-AGX-Thor-9724 adapt board need to be powered by 12V.

  ![alt text](../../Picture/SENSING%20Thor%20Developer%20Kit/TRD1%20G2A%20Power%20and%20Trigger%20Interface%20Definition.jpg)

#### Camera Version Support

| Type | Camera                      |  Jetpack 7.0 |
| ---- | --------------------------- | -----------  |
| YUV  | SG2-AR0233C-5200-F3A-Hxxx   |      YES     |
| YUV  | SG2-AR0233C-5200-F4A-Hxxx   |      YES     |
| YUV  | SG8S-AR0820C-5300-F4A-Hxxx  |      YES     |
| YUV  | SG3S-ISX031C-F4A-Hxxx       |      YES     |


#### Camera Mapping

| FAKRA |      Video      |
| ----- | --------------- |
| COAX4 |   /dev/video0   |
| COAX5 |   /dev/video1   |
| COAX6 |   /dev/video2   |
| COAX7 |   /dev/video3   |
| COAX0 |   /dev/video4   |
| COAX1 |   /dev/video5   | 
| COAX2 |   /dev/video6   |
| COAX3 |   /dev/video7   |


