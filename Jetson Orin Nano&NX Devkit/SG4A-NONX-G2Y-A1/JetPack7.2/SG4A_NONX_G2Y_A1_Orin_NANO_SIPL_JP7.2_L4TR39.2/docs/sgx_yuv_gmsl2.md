## How to bring up SHW5G Camera Module

 1. Supported Camera Specifications

    | Camera Model | GMSL Rate | Resolution |
    | :--- | :---: | :---: |
    | `SG2-IMX390C-5200-G2A-Hxxx` | 6G | 1920x1080 |
    | `SG2-AR0233-5200-G2A-Hxxx` | 6G | 1920x1080 |
    | `SG3-ISX031C-GMSL2-Hxxx` | 6G | 1920x1536 |
    | `SG3-ISX031C-GMSL2F-Hxxx` | 6G | 1920x1536 |
    | `SG5-IMX490C-5300-GMSL2-Hxxx` | 6G | 2880x1860 |
    | `SG8S-AR0820C-5300-G2A-Hxxx` | 6G | 3840x2160 |
    | `SG8-OX08DC-5300-G2G-Hxxx` | 6G | 3840x2160 |
    | `SHF3L` | 6G | 1920x1536 |
    | `SHF3H` | 6G | 1920x1536 |


 2. Update the JSON configuration file

    Update the JSON configuration file based on the connected camera's model and specifications.

    **Target file:** `query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json`

    **Parameter Mapping:**
    * `SGX_YUV_GMSL2_2M`: 1920x1080 resolution, 6G mode
    * `SGX_YUV_GMSL2_3M`: 1920x1536 resolution, 6G mode
    * `SGX_YUV_GMSL2_3M_3G`: 1920x1536 resolution, 3G mode
    * `SGX_YUV_GMSL2_5M`: 2880x1860 resolution, 6G mode
    * `SGX_YUV_GMSL2_8M`: 3840x2160 resolution, 6G mode *(Note: Corrected from 2M)*

    Example configuration structure:

    ```
    "cameraConfigs": [
        {
            "name": "SGX_YUV_GMSL2_4CH",
            ...
            "cameraModules": [
                {
                    "name": "SGX_YUV_GMSL2_2M",
                    ...
                },
                {
                    "name": "SGX_YUV_GMSL2_2M",
                    ...
                },
                {
                    "name": "SGX_YUV_GMSL2_2M",
                    ...
                },
                {
                    "name": "SGX_YUV_GMSL2_2M",
                    ...
                }
            ]
            ...
        }
        ...
    ]
    ```

 3. Basic camera test

    Print Camera Output Frame Rate

    ```
    ## For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x0001" --enable-camera-hal -s -Z -012R

    ## For CN6 CAM1
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x0010" --enable-camera-hal -s -Z -012R

    ## For CN5 CAM2
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x0100" --enable-camera-hal -s -Z -012R

    ## For CN4 CAM3
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x1000" --enable-camera-hal -s -Z -012R
    ```

2. With on-screen EGL preview

    ```
    ## Example: For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x0001" --enable-camera-hal -s -Z -012R --egl-display
    ```

3. Show EEPROM data (Internal parameters)
    ```
    ## Example: For CN7 CAM0
    sudo nvsipl_camera -t query/sg4a_nonx_g2y_a1/sgx_yuv_gmsl2.json -c SGX_YUV_GMSL2_4CH -m "0x0001" --enable-camera-hal -s -Z -012R -e
    ```