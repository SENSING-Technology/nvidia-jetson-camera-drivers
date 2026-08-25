## How to bring up S56Cx1 + SHW5Gx2 Camera Module

Connect the SHW5G to CAM2 and CAM3, and the SHF3L to CAM4 and CAM5.

 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    sudo nvsipl_camera -t query/sg8a_agth_g2a/shw5g_shf3l_mixed.json -c SHF3L_2_SHW5G_2 -m "0x0011 0x1100" --enable-camera-hal -s -Z --mixed-yuv-output
    ```

2. With on-screen EGL preview

    ```
    sudo nvsipl_camera -t query/sg8a_agth_g2a/shw5g_shf3l_mixed.json -c SHF3L_2_SHW5G_2 -m "0x0011 0x1100" --enable-camera-hal -s -Z --mixed-yuv-output --egl-display

    ```
