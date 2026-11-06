## How to bring up SDT2BC01 Camera Module

1. Supported Camera Specifications

   | Camera Model | GMSL Rate | Resolution | Frame Rate |
   | :----------- | :-------: | :--------: | :--------: |
   | `SDT2BC01`   |    6G     | 2400x1800  |   30 fps   |


   The camera can only be connected to the CAM0/CAM2/CAM4/CAM6 ports.

   The JSON defines all eight ports. Select the connected port with `-m`; no `linkIndex` change is required.

2. Basic camera test

   Print Camera Output Frame Rate

   ```
   # For CAM0
   sudo nvsipl_camera -t query/sg8a_agon_g2y_a1/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R

   # For CAM2
   sudo nvsipl_camera -t query/sg8a_agon_g2y_a1/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0100" --enable-camera-hal -s -Z -012R
   ```

3. With on-screen EGL preview

   Run in the device's unlocked desktop terminal.

   ```
   # Example: For CAM0
   sudo nvsipl_camera -t query/sg8a_agon_g2y_a1/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R --egl-display
   ```

4. Show EEPROM data (Internal parameters)

   ```
   # Example: For CAM0
   sudo nvsipl_camera -t query/sg8a_agon_g2y_a1/sdt2bc01.json -c SDT2BC01_2400X1800_30FPS -m "0x0000 0x0001" --enable-camera-hal -s -Z -012R -e
   ```
