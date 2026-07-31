## How to bring up SHW5G Camera Module

 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    ## For CAM0
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x0001" --enable-camera-hal -s -Z -12

    ## For CAM1
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x0010" --enable-camera-hal -s -Z -12

    ## For CAM2
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x0100" --enable-camera-hal -s -Z -12

    ## For CAM3
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x1000" --enable-camera-hal -s -Z -12

    ## For CAM4
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0001 0x0000" --enable-camera-hal -s -Z -12

    ## For CAM5
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0010 0x0000" --enable-camera-hal -s -Z -12

    ## For CAM6
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0100 0x0000" --enable-camera-hal -s -Z -12

    ## For CAM7
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x1000 0x0000" --enable-camera-hal -s -Z -12
    ```

2. With on-screen EGL preview

    ```
    ## Example: For CAM0
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x0001" --enable-camera-hal -s -Z -12 --egl-display
    ```

3. Show EEPROM data (Internal parameters)
    ```
    ## Example: For CAM0
    sudo nvsipl_camera -t query/trd1_g2a/shw5g.json -c SHW5G_8CH -m "0x0000 0x0001" --enable-camera-hal -s -Z -12 -e
    ```