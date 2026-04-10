#!/bin/bash

#   0: SG2-AR0233C-5200-G2A-Hxxx    (1920x1080, YUV422, Serializer: MAX9295  )
#   1: SG2-IMX390C-5200-G2A-Hxxx    (1920x1080, YUV422, Serializer: MAX9295  )
#   2: SG2-OX03CC-5200-G2F-Hxxx     (1920x1080, YUV422, Serializer: MAX96717F)
#   3: SG3S-ISX031C-GMSL2F-Hxxx     (1920x1536, YUV422, Serializer: MAX96717F)
#   4: SG3S11AFxK                   (1920x1536, YUV422, Serializer: MAX96717F)
#   5: SG3S-ISX031C-GMSL2-Hxxx      (1920x1536, YUV422, Serializer: MAX9295  )
#   6: SG3S-OX03JC-G2F-Hxxx         (1920x1536, YUV422, Serializer: MAX96717F)
#   7: SG5-IMX490C-5300-GMSL2-Hxxx  (2880x1860, YUV422, Serializer: MAX9295  )
#   8: OMSBDAAN                     (2592x1944 , YUV422, Serializer: MAX9295  )
#   9: DMSBBFAN                     (1600x1300, YUV422, Serializer: MAX96717F)
#   10: SG8S-AR0820C-5300-G2A-Hxxx   (3840x2160, YUV422, Serializer: MAX9295  )
#   11: SG8-ISX028C-G2G-Hxxx         (3840x2160, YUV422, Serializer: MAX96717 )
#   12: SG8-OX08BC-5300-GMSL2-Hxxx   (3840x2160, YUV422, Serializer: MAX9295  )
#   13: SG8-IMX728C-G2G-Hxxx         (3840x2160, RAW12 , Serializer: MAX96717 )

# 3G enable:
#     If Serializer is set to 1 in MAX96717F
# sensormode:
#   For YUV:
#     0=1920, 1080
#     1=1920, 1536
#     2=2880, 1860
#     3=3840, 2160
#     4=1600, 1300
#     5=3840, 2160 (SG8-ISX028C-G2G-Hxxx)
#     6=2592, 1944
#   For RAW:
#     0=3840, 2160 (SG8-IMX728C-G2G-Hxxx)

# 3G enable configuration for cam0-3
ENABLE_3G_0='0,0,0,0'

# 3G enable configuration for cam4-7
ENABLE_3G_1='0,0,0,0'

# Sensor mode configuration for each camera
SENSOR_MODE_0='0'
SENSOR_MODE_1='0'
SENSOR_MODE_2='0'
SENSOR_MODE_3='0'
SENSOR_MODE_4='0'
SENSOR_MODE_5='0'
SENSOR_MODE_6='0'
SENSOR_MODE_7='0'

