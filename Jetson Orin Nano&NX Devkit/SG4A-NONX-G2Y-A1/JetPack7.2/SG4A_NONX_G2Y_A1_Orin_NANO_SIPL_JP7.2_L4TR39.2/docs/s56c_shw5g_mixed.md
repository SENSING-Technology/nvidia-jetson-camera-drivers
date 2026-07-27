## How to bring up S56Cx1 + SHW5Gx2 Camera Module

Connect the S56C to the CN7 port, and the SHW5G to the CN5 and CN4 ports.


 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x1101" --enable-camera-hal -s -Z -12
    ```

2. With on-screen EGL preview

    ```
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/s56c_shw5g_mixed.json -c S56C_1_SHW5G_2 -m "0x1101" --enable-camera-hal -s -Z -12 --egl-display
    ```
