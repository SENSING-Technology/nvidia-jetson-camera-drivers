## SENSING Camera Drivers for Jetson AGX Orin Developer Kit adapt with SG10A-AGON-G2M-A1

#### Supported Jetpack

* Jetpack 6.0
* Jetpack 6.2

#### Hardware Connect

* Using adapt board connect up to 10 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG10A-AGON-G2M-A1%20with%20Jetson%20AGX%20Orin%20Devkit.png)

#### Power Supply

* SG10A-AGON-G2M-A1 adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                      | Jetpack 6.0 | Jetpack 6.2 |
| ---- | --------------------------- | ----------- | ----------- |
| YUV  | Gemini 335Lg                | \           | YES         |
| YUV  | SHW3H(3MP/H120UA)           | YES         | YES         |
| YUV  | SHF3L(3MP/H190XA)           | YES         | YES         |
| YUV  | Astra S36                   | \           | YES         |
| YUV  | Intel RealSense D457        | \           | YES         |
| YUV  | SHW3G/SHN3G                 | \           | YES         |
| YUV  | SG3S-ISX031C-GMSL2F-Hxxx    | \           | YES         |

#### Camera Mapping

| FAKRA |       Video     |
| ----- | --------------- |
|  J25  |      video0     |
|  J26  |      video1     |
|  J23  |      video2     |
|  J24  |      video3     |
|  J21  |      video4     |
|  J22  |      video5     |
|  J27  |      video6     |
|  J28  |      video7     |
|  J29  |      video8     |
|  J30  |      video9     |
