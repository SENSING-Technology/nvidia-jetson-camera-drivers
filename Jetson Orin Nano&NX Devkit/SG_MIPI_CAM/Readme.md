## SENSING Camera Drivers for Jetson Orin Nano Developer Kit adapt with SG_MIPI_CAM

#### Supported Jetpack

* Jetpack 5.1.1
* Jetpack 5.1.2
* Jetpack 6.0 DP
* Jetpack 6.1

#### Hardware Connect

* Jetson Orin Nano Developer Kit connect up to 2 cameras
  ![atl text](../../SENSING%20Deserializer%20Adapt%20Board/NVIDIA%20Jetson%20Orin%20Nano.png)

#### Power Supply

* Jetson Orin Nano Developer Kit need to be powered by 12V

#### Camera Version Support

| Type | Camera                 | Jetpack 5.1.1 | Jetpack 5.1.2 | Jetpack 6.0DP | Jetpack 6.1 |
| ---- | ---------------------- | ------------- | ------------- | ------------- | ----------- |
| YUV  | SG3-ISX031C-MIPI-Hxxx  | \             | YES           | \             | YES         |
| RAW  | SG1-SC1336C-MIPI-HXXX  | \             | \             | YES           | \           |
| RAW  | SG2-AR0231C-MIPI-HXXX  | \             | \             | YES           | \           |
| RAW  | SG2-IMX390C-MIPI-Hxxx  | YES           | YES           | \             | \           |
| RAW  | SG2-IMX662C-MIPI-Hxxx  | YES           | YES           | YES           | YES         |
| RAW  | SG3-ISX031C-MIPI-HXXX  | YES           | \             | \             | \           |
| RAW  | SG5-IMX675C-MIPI-HXXX  | YES           | YES           | \             | \           |
| RAW  | SG8-IMX334C-MIPI-Hxxx  | \             | YES           | \             | \           |
| RAW  | SG8-IMX515C-MIPI-HXXX  | YES           | \             | \             | \           |
| RAW  | SG8-IMX585C-MIPI-HXXX  | YES           | YES           | \             | \           |
| RAW  | SG8-IMX676C-MIPI-Hxxx  | YES           | YES           | \             | \           |
| RAW  | SG8-IMX678C-MIPI-Hxxx  | YES           | YES           | \             | YES         |
| RAW  | SG8-IMX715C-MIPI-HXXX  | YES           | YES           | \             | \           |
| RAW  | SG8-OX08BC-MIPI-HXXX   | \             | \             | YES           | \           |
| RAW  | SG12-IMX577C-MIPI-Hxxx | YES           | YES           | YES           | YES         |
| RAW  | SG12-IMX676C-MIPI-Hxxx | YES           | YES           | \             | \           |
| RAW  | SG20-IMX283C-MIPI-Hxxx | \             | YES           | \             | YES         |

#### Camera Mapping

| Camera | Video  |
| ------ | ------ |
| CAM0   | video0 |
| CAM1   | video1 |
