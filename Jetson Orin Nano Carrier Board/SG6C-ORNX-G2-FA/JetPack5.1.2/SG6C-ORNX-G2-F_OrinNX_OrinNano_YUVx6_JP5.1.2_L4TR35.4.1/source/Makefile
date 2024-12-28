## ==============编绎环境配置说明 ================##
## CROSS_COMPILE_AARCH64:
## 		交叉编译器路径配置
## TEGRA_SDK_PATH:
##		SDK路径
## KERNEL_SRC_DIR:
##		打包好的驱动源码会放到此路径下，使用时会指定到 "${KERNEL_SRC_DIR}/kernel/kernel-5.10"
## TEGRA_KERNEL_OUT:
##		编绎内核输出路径
## PASS_WORD:
##		虚拟机密码
MAKE = make
CROSS_COMPILE_AARCH64=/home/tw/work/nvidia/tool/bin/aarch64-buildroot-linux-gnu-
TEGRA_SDK_PATH=/home/tw/work/lu/nvidia/jetson_r3541
KERNEL_SRC_DIR=$(TEGRA_SDK_PATH)/nvidia-jetson-kernel_src-linux-35.4.1-jetpack-5.1.2
TEGRA_KERNEL_OUT=$(TEGRA_SDK_PATH)/kernel_out
PASS_WORD=1

## ==============不同板卡版本配置说明 ================##
## RELEASE_DIR:
##		打包好的驱动包会释放到此路径下， 需要将文件extlinux，SG_MIPI_CAM.sh， SG8A_ORIN_GMSLX1.sh，SG8A_ORIN_GMSLX8.sh， readme.pdf放到此路径下
## RELEASE_SRC:
##		打包好的驱动源码包释会放到此路径下
## BOARD_ID:
##		和驱动源码文件夹名称对应,可以使用载板或者转接板型号
##		比如BOARD_ID=SG8A_ORIN_GMSLX8, 和驱动源码文件夹名称SG8A_ORIN_GMSLX8对应
## HW_VERSION:
##		和设备树文件夹名称对应,和BOARD_ID结合使用用于区分不同硬件版本的设备树
##		比如HW_VERSION=_V1, 和设备树文件夹名称SG8A_ORIN_GMSLX8_V1对应
## DTB_FILE: 
##     当前平台使用的设备树名称
## CAM_DTB_CONFIG_PATH:
##     CAM_DTB_CONFIG_PATH/sensing_config.h设备树配置选择相机
## SENSOR_ID：
##     相机名称，在设备树中与驱动源文件名称必须一致
## REMOTE_USER_NAME:
##     远程设备端用户名   
## REMOTE_PASSWORD:   远程设备端密码
##     远程设备端密码
## REMOTE_DEVICE:    
##     远程设备端访问地址
## REMOTE_BOARD_FILE_DIR:
##     推送文件在远程设备端存放目录
RELEASE_SRC=$(KERNEL_SRC_DIR)/package
RELEASE_DIR=$(KERNEL_SRC_DIR)/package


####for jetson-orin-nano-devkit SG6C-ORNX-G2-F####
BOARD_ID=SG6C_ORIN_GMSL2_M
HW_VERSION=
DTB_FILE=tegra234-p3767-0000-p3768-0000-a0
CAM_DTB_CONFIG_PATH=${KERNEL_SRC_DIR}/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb
SENSOR_ID=SGX_YUV_GMSL2
REMOTE_USER_NAME=nvidia
REMOTE_PASSWORD=nvidia
REMOTE_DEVICE=$(REMOTE_USER_NAME)@192.168.120.39
REMOTE_BOARD_FILE_DIR=/home/$(REMOTE_USER_NAME)

## ==============编绎命令说明================##
#单独编绎内核 
image:
	echo $(PASS_WORD) | sudo -S $(MAKE) -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10" ARCH=arm64 LOCALVERSION="-tegra"   \
	CROSS_COMPILE=$(CROSS_COMPILE_AARCH64) O=${TEGRA_KERNEL_OUT} -j8 --output-sync=target tegra_defconfig

	echo $(PASS_WORD) | sudo -S $(MAKE) -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10/" ARCH=arm64 LOCALVERSION="-tegra"  \
	CROSS_COMPILE=$(CROSS_COMPILE_AARCH64) O=${TEGRA_KERNEL_OUT} -j8 --output-sync=target Image

#单独编绎设备树
dts:
# #fix dts config file
# 	sed -ri '6{s/.*/#define ${BOARD_ID}${HW_VERSION}/g}' ${CAM_DTB_CONFIG_PATH}/sensing_config.h
# 	sed -ri '8{s/.*/#define ${SENSOR_ID}/g}' ${CAM_DTB_CONFIG_PATH}/sensing_config.h
# #replace '-' to '_'
# 	sed -ri '8{s/-/_/g}' ${CAM_DTB_CONFIG_PATH}/sensing_config.h
# #replace Cap 
# 	sed -ri '8{s/[a-z]/\u&/7g}' ${CAM_DTB_CONFIG_PATH}/sensing_config.h

	echo $(PASS_WORD)| sudo -S $(MAKE) -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10" ARCH=arm64 LOCALVERSION="-tegra" \
	CROSS_COMPILE=$(CROSS_COMPILE_AARCH64)  O=${TEGRA_KERNEL_OUT} \
	-j8 --output-sync=target dtbs

#单独编绎module
mod: 
	echo $(PASS_WORD) | sudo -S $(MAKE) -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10" ARCH=arm64 LOCALVERSION="-tegra" \
	CROSS_COMPILE=$(CROSS_COMPILE_AARCH64) O=${TEGRA_KERNEL_OUT} \
	-j8 --output-sync=target modules_prepare

	echo $(PASS_WORD) | sudo -S $(MAKE) ${BOARD_ID}=1 -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10" ARCH=arm64 LOCALVERSION="-tegra" \
	CROSS_COMPILE=$(CROSS_COMPILE_AARCH64) O=${TEGRA_KERNEL_OUT} -j8 --output-sync=target modules
	# echo $(PASS_WORD) | sudo -S $(MAKE) -C "${KERNEL_SRC_DIR}/kernel/kernel-5.10" ARCH=arm64 LOCALVERSION="-tegra"   \
	# CROSS_COMPILE="${CROSS_COMPILE_AARCH64}" O=${TEGRA_KERNEL_OUT} -j8 --output-sync=target \
	# modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(MODULES_INSTALL_DIR)

#释放打包驱动包
release:
	@if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION) ]; then mkdir -p $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION) ; fi ;
	@if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot ]; then mkdir $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot ; fi ;
	@if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/ko ]; then mkdir $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/ko ; fi ;
	@if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb ]; then mkdir $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb ; fi ;
	@if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb/$(SENSOR_ID) ]; then mkdir $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb/$(SENSOR_ID) ; fi ;

	cp ${TEGRA_KERNEL_OUT}/arch/arm64/boot/Image  $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot
	cp ${TEGRA_KERNEL_OUT}/arch/arm64/boot/dts/nvidia/$(DTB_FILE).dtb $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb/$(SENSOR_ID)/
	cp ${TEGRA_KERNEL_OUT}/arch/arm64/boot/dts/nvidia/tegra234-p3767-0003-p3768-0000-a0.dtb $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb/$(SENSOR_ID)/

	cp ${TEGRA_KERNEL_OUT}/drivers/media/i2c/$(BOARD_ID)/*.ko $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/ko -rf
	cp ${TEGRA_KERNEL_OUT}/drivers/net/usb/r8152.ko $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/ko -rf
	cp ${TEGRA_KERNEL_OUT}/drivers/pps/clients/pps-gpio.ko $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/ko -rf

	# @if [ ! -d $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot/extlinux ]; then cp $(RELEASE_DIR)/extlinux $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot -rf; fi ;
	# @if [ ! -f $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/readme.pdf ]; then cp $(RELEASE_DIR)/readme.pdf $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION); fi ;
	# @if [ ! -f $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/$(BOARD_ID).sh ]; then cp $(RELEASE_DIR)/$(BOARD_ID).sh $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION)/quick_bring_up.sh; fi;
	
# 推送驱动包文件到设备
	scp -r $(RELEASE_DIR)/$(BOARD_ID)$(HW_VERSION) $(REMOTE_DEVICE):$(REMOTE_BOARD_FILE_DIR)

#释放打包sg6c载板驱动源码
pack_sg6c:
#creat dir
	@if [ ! -d $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/$(BOARD_ID)$(HW_VERSION) ]; then mkdir -p $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/$(BOARD_ID)$(HW_VERSION) ; fi ;
	@if [ ! -d $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID) ]; then mkdir -p $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID) ; fi ;
	@if [ ! -d $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/kernel-5.10/arch/arm64/configs ]; then mkdir -p $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/kernel-5.10/arch/arm64/configs ; fi ;
#dtb copy
	cp ${CAM_DTB_CONFIG_PATH}/../$(DTB_FILE).dts $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/
	cp ${CAM_DTB_CONFIG_PATH}/tegra234-p3768-0000-a0.dtsi $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/
	cp ${CAM_DTB_CONFIG_PATH}/sensing_config.h $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/
	cp ${CAM_DTB_CONFIG_PATH}/$(BOARD_ID)$(HW_VERSION)/tegra234-p3768-sg6c-ornx-g2-f-module.dtsi $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/$(BOARD_ID)$(HW_VERSION)/
	cp ${CAM_DTB_CONFIG_PATH}/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID).dtsi $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb//$(BOARD_ID)$(HW_VERSION)/
#source copy	
	cp ${KERNEL_SRC_DIR}/kernel/kernel-5.10/arch/arm64/configs/tegra_defconfig $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/kernel-5.10/arch/arm64/configs/
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/Makefile  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/Makefile  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/max9295.c  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/max9295.h  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/max9296.c  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/max9296.h  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/$(SENSOR_ID).c  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)
	cp ${KERNEL_SRC_DIR}/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)/$(SENSOR_ID)-tbls.h  $(RELEASE_SRC)/source/$(BOARD_ID)$(HW_VERSION)/$(SENSOR_ID)/kernel/nvidia/drivers/media/i2c/$(BOARD_ID)

remote_updata:
	ssh $(REMOTE_DEVICE) "echo $(REMOTE_PASSWORD) | sudo -S cp $(REMOTE_BOARD_FILE_DIR)/$(BOARD_ID)$(HW_VERSION)/dtb/$(SENSOR_ID)/$(DTB_FILE).dtb  /boot/dtb/kernel_$(DTB_FILE).dtb"
	ssh $(REMOTE_DEVICE) "echo $(REMOTE_PASSWORD) | sudo -S cp $(REMOTE_BOARD_FILE_DIR)/$(BOARD_ID)$(HW_VERSION)/boot/Image  /boot/Image"
	ssh $(REMOTE_DEVICE) "sync"
	sleep 2
	ssh $(REMOTE_DEVICE) "echo $(REMOTE_PASSWORD) | sudo -S reboot"

all: image dts mod

PHONY := __all
__all:
