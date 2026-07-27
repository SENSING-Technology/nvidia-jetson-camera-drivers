## How to bring up S56Cx1 + SHF3Lx2 Camera Module

Connect the S56C to the CN7 port, and the SHF3L to the CN5 and CN4 ports.


 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/s56c_shf3l_mixed.json -c S56C_1_SHF3L_2 -m "0x1101" --enable-camera-hal -s -Z --mixed-yuv-output
    ```

2. With on-screen EGL preview

    ```
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/s56c_shf3l_mixed.json -c S56C_1_SHF3L_2 -m "0x1101" --enable-camera-hal -s -Z --mixed-yuv-output --egl-display
    ```