## How to bring up S56Cx1 + SHW5Gx2 Camera Module

Connect the S56C to the CAM0 port, and the SHW5G to the CAM2 and CAM3 ports.
Connect the S56C to the CAM4 port, and the SHW5G to the CAM6 and CAM7 ports.


 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    sudo nvsipl_camera -t query/trd1_g2a/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x0000 0x1101" --enable-camera-hal -s -Z -12

    sudo nvsipl_camera -t query/trd1_g2a/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x1101 0x0000" --enable-camera-hal -s -Z -12
    ```

2. With on-screen EGL preview

    ```
    sudo nvsipl_camera -t query/trd1_g2a/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x0000 0x1101" --enable-camera-hal -s -Z -12 --egl-display

    sudo nvsipl_camera -t query/trd1_g2a/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x1101 0x0000" --enable-camera-hal -s -Z -12 --egl-display
    ```
