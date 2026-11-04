## How to bring up SDT2BC01 Camera Module

The camera can only be connected to the CAM0/CAM2/CAM4/CAM6 ports.

1. Supported Camera Specifications

   | Camera Model | GMSL Rate | Resolution | Frame Rate |
   | :----------- | :-------: | :--------: | :--------: |
   | `SDT2BC01`   |    6G     | 2400x1800  |   30 fps   |

2. Basic camera test

   Print Camera Output Frame Rate

   ```
   # For CAM0
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R

   # For CAM2
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0100" --enable-camera-hal -s -Z -012R

   # For CAM4
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0001 0x0000" --enable-camera-hal -s -Z -012R

   # For CAM6
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0100 0x0000" --enable-camera-hal -s -Z -012R
   ```

3. With on-screen EGL preview

   ```
   # Example: For CAM0
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R --egl-display
   ```

4. Show EEPROM data (Internal parameters)

    Note: For stereo camera systems, EEPROM data must be read from one camera at a time. Reading the EEPROMs of multiple cameras simultaneously may result in incorrect or corrupted data.

   ```
   # Example: For CAM0
   sudo nvsipl_camera -t query/trd1_g2a/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R -e
   ```
