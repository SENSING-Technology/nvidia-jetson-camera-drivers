#### Jetpack version

* Jetpack 6.0 DP

#### Supported SENSING Camera Modules

* SG12-IMX577C-MIPI-HXXX

  * support max 2 cameras to light up at the same time

#### Quick Bring Up

> Take the SG12-IMX577C-MIPI-HXXX camera as an example

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
  cp Jetson-Orin-Nano-DK_IMX577_JP6.0_L4TR36.2/source/* <install-    path>/Linux_for_Tegra/source/ -r
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

* Due to the block **SG6C\_ORNX\_G2\_F** no eeprom, need for Linux\_for\_Tegra/bootloader/generic/BCT/**tegra234-mb2-bct-misc-p3767-0000.dts** modified:

  ```Bash
  $ - cvb_eeprom_read size =<0x100> 
  $ + cvb_eeprom_read size =<0x0>
  ```
* After the device enters the recovery mode, flash the firmware:

  ```Bash
  $ cd <install-path>/Linux_for_Tegra/

  # for nano/nx
  $ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_external.xml -p \
    "-c    bootloader/generic/cfg/flash_t234_qspi.xml" \
    --showlogs --network usb0 jetson-orin-nano-devkit internal

  #for agx orin
  $ sudo ./flash.sh jetson-agx-orin-devkit internal
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
  /home/nvidia/Jetson-Orin-Nano-DK_IMX577_JP6.0_L4TR36.2
  cd Jetson-Orin-Nano-DK_IMX577_JP6.0_L4TR36.2
  ```
* Install camera driver

  ```
  sudo insmod ./ko/sg12-mipi-imx577.ko
  ```
* Bring up the camera

  ```
  argus_camera -d 1
  ```
