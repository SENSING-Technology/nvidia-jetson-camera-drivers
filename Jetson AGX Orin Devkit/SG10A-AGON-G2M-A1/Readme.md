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

* Gemini 335Lg
* SHW3H(3MP/H120UA)
* SHF3L(3MP/H190XA)

#### Camera Mapping

| FAKRA |      Video      |    Camera    |
| ----- | --------------- | ------------ |
|  J21  |      video0     |     SHW3H    |
|  J22  |      video1     |     SHW3H    |
|  J27  |      video2     |     SHW3H    |
|  J28  |      video3     |     SHW3H    |
|  J29  |      video4     |     SHW3H    |
|  J30  |      video5     |     SHW3H    |
|  J25  | video6~video13  | Gemini 335Lg |
|  J22  | video14~video21 | Gemini 335Lg |
|  J22  | video22~video29 | Gemini 335Lg |
|  J22  | video30~video37 | Gemini 335Lg |
