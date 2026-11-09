## How to bring up S36x1 + SHF3Lx2 Camera Module

Connect the S36 to the CAM0 port, and the SHF3L to the CAM2 and CAM3 ports.
Connect the S36 to the CAM4 port, and the SHF3L to the CAM6 and CAM7 ports.

 1. Basic camera test

    Print Camera Output Frame Rate

    ```
    sudo nvsipl_camera -t query/trd1_g2a/s36_shf3l_mixed.json -c S36_1_SHF3L_2 -m "0x0000 0x1101" --enable-camera-hal -s -Z -012R

    sudo nvsipl_camera -t query/trd1_g2a/s36_shf3l_mixed.json -c S36_1_SHF3L_2 -m "0x1101 0x0000" --enable-camera-hal -s -Z -012R
    ```

2. With on-screen EGL preview

    ```
    sudo nvsipl_camera -t query/trd1_g2a/s36_shf3l_mixed.json -c S36_1_SHF3L_2 -m "0x0000 0x1101" --enable-camera-hal -s -Z -012R --egl-display

    sudo nvsipl_camera -t query/trd1_g2a/s36_shf3l_mixed.json -c S36_1_SHF3L_2 -m "0x1101 0x0000" --enable-camera-hal -s -Z -012R --egl-display
    ```

