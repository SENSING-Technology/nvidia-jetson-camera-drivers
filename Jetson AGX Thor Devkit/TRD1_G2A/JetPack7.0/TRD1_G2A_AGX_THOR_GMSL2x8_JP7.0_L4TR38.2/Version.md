20260521: 

1. Supports the following cameras:

IMX728
OX03H10
SG8-OX08DC-G2A
SHW3G
SHW5G
SGX-YUV-GMSL2
S36
S56
SDV11NM1

notice:Add support for the SG3-OX03H10C-G2F and SG8-IMX728C-G2G camera.

2. Supports heterogeneous camera connections.




Known Issue:
1. When connecting cameras with different pixel formats (e.g., RAW10 and RAW12) to the same deserializer, argus_camera cannot simultaneously activate them.
https://forums.developer.nvidia.com/t/argus-camera-wont-work-with-different-cameras-on-one-max96712/349548/16