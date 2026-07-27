## How to bring up SHW5G Camera Module

 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    ## For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x0001" --enable-camera-hal -s -Z -12

    ## For CN6 CAM1
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x0010" --enable-camera-hal -s -Z -12

    ## For CN5 CAM2
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x0100" --enable-camera-hal -s -Z -12

    ## For CN4 CAM3
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x1000" --enable-camera-hal -s -Z -12
    ```

2. With on-screen EGL preview

    ```
    ## Example: For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x0001" --enable-camera-hal -s -Z -12 --egl-display
    ```

3. Show EEPROM data (Internal parameters)
    ```
    ## Example: For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/shw5g.json -c SHW5G_4CH -m "0x0001" --enable-camera-hal -s -Z -12 -e
    ```