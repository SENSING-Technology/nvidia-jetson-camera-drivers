#### Jetpack version

* Jetpack 6.0 DP

#### Supported SENSING Camera Modules

* SG2-IMX390C-5200-GMSL2-Hxxx
  * support max 8 cameras to light up at the same time
* SG2-AR0233-5300-GMSL2-Hxxx
  * support max 8 cameras to light up at the same time
* SG2-OX03CC-5200-GMSL2F-Hxxx
  * support max 8 cameras to light up at the same time
* SG3-ISX031C-GMSL2-Hxxx
  * support max 8 cameras to light up at the same time
* SG3-ISX031C-GMSL2F-Hxxx
  * support max 8 cameras to light up at the same time
* SG4-IMX490C-5300-GMSL2-Hxxx
  * support max 8 cameras to light up at the same time
* SG8-AR0820C-5300-GMSL2-Hxxx
  * support max 7 cameras to light up at the same time
* SG8-OX08BC-5300-GMSL2-Hxxx
  * support max 7 cameras to light up at the same time

#### Quick Bring Up

Download Software Package

* Download the latest Jetson Linux release package and sample file system for your Jetson developer kit from [https://developer.nvidia.com/linux-tegra](https://developer.nvidia.com/linux-tegra)
* Enter the following commands to untar the files and assemble the rootfs:

  ```
  tar xf Jetson_Linux_version_aarch64.tbz2
  sudo tar xpf Tegra_Linux_Sample-Root-Filesystem_version_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
  cd Linux_for_Tegra/
  sudo ./apply_binaries.sh
  sudo ./tools/l4t_flash_prerequisites.sh
  ```
* Locate and download the Jetson Linux source files for your release.Extract the file:`.tbz2`

  ```
  tar xf public\_sources.tbz2 -C install-path/Linux\_for\_Tegra/..
  ```
* Extract the kernel and the NVIDIA out-of-tree modules source files:

  ```
  tar xf public\_sources.tbz2 -C install-path/Linux\_for\_Tegra/..
  ```
* cd <install-path>/Linux\_for\_Tegra/source \$ tar xf kernel\_src.tbz2 \$ tar xf kernel\_oot\_modules\_src.tbz2 \$ tar xf nvidia\_kernel\_display\_driver\_source.tbz2

  ```
  cd <install-path>/Linux_for_Tegra/source
  tar xf kernel_src.tbz2
  tar xf kernel_oot_modules_src.tbz2
  tar xf nvidia_kernel_display_driver_source.tbz2
  ```

Building the Jetson Linux Kernel

* Copy the “source” folder from the sensing provided driver package to the <install-path>/Linux\_for\_Tegra/ directory

  ```
  cp SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_JP6.0DP_L4TR36.2.0/source/* <install-    path>/Linux_for_Tegra/source/ -r
  ```
* Configure environment variables (Environment variables are set based on actual situation)

  ```
  export CROSS_COMPILE=<toolchain-path>/bin/aarch64-buildroot-linux-gnu-
  export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
  export INSTALL_MOD_PATH=<install-path>/Linux_for_Tegra/rootfs/
  ```
* Building the Jetson Linux Kernel，NVIDIA Out-of-Tree Modules，DTBs

  ```Bash
  $ cd <install-path>/Linux_for_Tegra/source
  $ make -C kernel                                  #build kernel
  $ make modules                                    #build modules
  $ make dtbs                                         #build dtbs
  ```
* Run the following commands to install:

  ```Bash
  #install kernel
  $ sudo -E make install -C kernel
  #install modules            
  $ sudo -E make modules_install 

  $ cp kernel/kernel-jammy-src/arch/arm64/boot/Image <install-path>/Linux_for_Tegra/kernel/Image
  $ cp nvidia-oot/device-tree/platform/generic-dts/dtbs/* <install-path>/Linux_for_Tegra/kernel/dtb/
  ```

Flash firmware

* Copy the p3737-0000-p3701-0000.conf file in the driver package to install-
  path/Linux_for_Tegra/

  ```
  cp SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_GMSL1_JP6.0DP_L4TR36.2.0/p3737-0000-p3701-0000.conf <install-path>/Linux_for_Tegra/
  ```
* After the device enters the recovery mode, flash the firmware:

  ```
  cd <install-path>/Linux_for_Tegra/

  # for nano/nx
  sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_external.xml -p \
    "-c    bootloader/generic/cfg/flash_t234_qspi.xml" \
    --showlogs --network usb0 jetson-orin-nano-devkit internal

  #for agx orin
  sudo ./flash.sh jetson-agx-orin-devkit internal
  ```

Light up the camera

* Preparatory work:Install the argus\_camera.

  ```
  sudo apt-get update

  sudo apt-get install nvidia-l4t-jetson-multimedia-api
  cd /usr/src/jetson_multimedia_api/argus/

  sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev

  sudo mkdir build && cd build

  # build and install

  sudo cmake ..
  sudo make -j8
  sudo make install
  ```
* Transfer the driver package provided by sensing to the Orin nano device.

  ```
  SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_GMSL1_JP6.0DP_L4TR36.2.0
  cd SG8A_ORIN_GMSL2-F_V2_AGX_Orin_YUV_GMSL1_JP6.0DP_L4TR36.2.0
  ```
* Install camera driver

  ```
  sudo insmod ./ko/max9295.ko
  sudo insmod ./ko/max9296.ko
  sudo insmod ./ko/sgx-yuv-gmsl1.ko
  ```
* Bring up the camera

  ```
  gst-launch-1.0 v4l2src device=/dev/video0  ! xvimagesink -ev
  ```
