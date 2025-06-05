## Camera Drivers for Jetson Orin Nano Developer Kit adapt with SG2A-G3-M4L

#### Supported Jetpack

* Jetpack 5.1.1

#### Hardware Connect

* Using adapt board connect up to 2 cameras
  ![alt text](../../Picture/SENSING%20Deserializer%20Adapt%20Board/SG2A-G3-M4L-F%20with%20Jetson%20Orin%20Nano&NX%20Devkit.png)

#### Power Supply

* SG2A-G3-M4L adapt board need to be powered by 12V.

#### Camera Version Support

| Type | Camera                     | Jetpack 5.1.1 | Jetpack 5.1.2 | Jetpack 6.0DP | Jetpack 6.0 |
| ---- | -------------------------- | ------------- | ------------- | ------------- | ----------- |
| YUV  | SG8S-AR0820C-5300-G3A-Hxxx | YES           | \             | \             | \           |
| RAW  | SG8-IMX728C-G3A-Hxxx       | YES           | \             | \             | \           |
| RAW  | SG17-IMX735C-G3A-Hxxx      | \             | \             | \             | \           |

#### Camera Mapping

| FAKRA | Video  |
| ----- | ------ |
| GMSL0 | video0 |
| GMSL1 | video1 |
