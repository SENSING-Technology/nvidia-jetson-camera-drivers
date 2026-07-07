# SPDX-License-Identifier: GPL-2.0-only
# Copyright (c) 2023-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.

subdir-ccflags-y += -Werror

obj-m += max9295.o
obj-m += max9296.o
subdir-ccflags-y += -DCONFIG_VIDEO_G2XX_SERDES
subdir-ccflags-y += -DCONFIG_TEGRA_CAMERA_PLATFORM
obj-m += g2xx.o
ifeq ($(findstring ack_src,$(NV_BUILD_KERNEL_OPTIONS)),)
obj-m += max96712.o

ifdef CONFIG_MEDIA_SUPPORT
obj-m += ar1335_common.o
obj-m += lt6911uxc.o
obj-m += nv_imx185.o
obj-m += nv_imx219.o
obj-m += nv_imx274.o
obj-m += nv_imx318.o
obj-m += nv_imx390.o
obj-m += nv_imx477.o
obj-m += nv_ov5693.o
obj-m += nv_ar0234.o
obj-m += nv_hawk_owl.o
endif

obj-m += pca9570.o
obj-m += virtual_i2c_mux.o
endif

ifdef SG10A_ORIN_GMSL
obj-y += SG10A_ORIN_GMSL/
else ifdef SG8A_ORIN_GMSL2
obj-y += SG8A_ORIN_GMSL2/
endif
