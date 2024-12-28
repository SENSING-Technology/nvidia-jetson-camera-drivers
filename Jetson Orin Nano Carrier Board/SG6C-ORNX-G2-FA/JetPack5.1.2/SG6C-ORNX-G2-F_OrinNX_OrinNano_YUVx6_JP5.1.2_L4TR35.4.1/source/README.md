鸣飞伟业， 基于我们做的最新载板SG6C，硬件负责人姜晓叀

编绎安装请查看Makefile, 加入打包更新脚本给客户更新
注意修改Makefile里的：
CROSS_COMPILE_AARCH64=/home/ethan/work/nvidia/gcc-9.3/bin/aarch64-buildroot-linux-gnu-
TEGRA_SDK_PATH=/home/ethan/work/nvidia/JetPack-5.1.2_L4T-35.4.1/Linux_for_Tegra

打包更新脚本：
```
#!/bin/bash
<<COMMENT
#
# 2022-05-30 AGX Orin V1.0
#
COMMENT

red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

#update
green_print "update Image&dtb!"
sudo cp $PWD/boot/Image /boot/Image
sudo cp $PWD/dtb/sgx-yuv-gmsl2/tegra234-p3767-0000-p3768-0000-a0.dtb  /boot/dtb/kernel_tegra234-p3767-0000-p3768-0000-a0.dtb

green_print "update module!"
sudo cp $PWD/ko/fzcam.ko /lib/modules/5.10.120-tegra/kernel/drivers/media/i2c/
sudo chmod 777 /etc/modules
sudo echo fzcam >> /etc/modules
sudo depmod -a


green_print "update complete, please reboot the system!"
```