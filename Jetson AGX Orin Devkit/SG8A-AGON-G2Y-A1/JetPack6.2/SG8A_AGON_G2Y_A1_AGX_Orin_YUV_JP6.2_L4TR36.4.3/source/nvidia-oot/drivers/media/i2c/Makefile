# SPDX-License-Identifier: GPL-2.0-only
# Copyright (c) 2023-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.

subdir-ccflags-y += -Werror

# obj-m += max9295.o
# obj-m += max9296.o
ifeq ($(findstring ack_src,$(NV_BUILD_KERNEL_OPTIONS)),)
# obj-m += max96712.o

ifdef CONFIG_MEDIA_SUPPORT
# obj-m += ar1335_common.o
# obj-m += lt6911uxc.o
# obj-m += nv_imx185.o
# obj-m += nv_imx219.o
# obj-m += nv_imx274.o
# obj-m += nv_imx318.o
# obj-m += nv_imx390.o
# obj-m += nv_imx477.o
# obj-m += nv_ov5693.o
# obj-m += nv_ar0234.o
# obj-m += nv_hawk_owl.o
# obj-m += max929x.o
endif

# obj-m += pca9570.o
# obj-m += virtual_i2c_mux.o
endif

# For SENSING
ifdef  SG_MIPI_CAM
	obj-y += SG_MIPI_CAM/
else ifdef SG8A_ORIN_GMSLX8
	obj-y += SG8A_ORIN_GMSLX8/
else ifdef SG6C_ORNX_G2_F
	obj-y += SG6C_ORNX_G2_F/
else ifdef SG4A_NONX_G2Y_A1
	obj-y += SG4A_NONX_G2Y_A1/
else ifdef SG4A_ORIN_GMSL2
	obj-y += SG4A_ORIN_GMSL2/
else ifdef SG12A_ORIN_GMSL2
	obj-y += SG12A_ORIN_GMSL2/
else ifdef SG8A_AGON_G2Y_B1
	obj-y += SG8A_AGON_G2Y_B1/
else ifdef SG10A_ORIN_GMSL
	obj-y += SG10A_ORIN_GMSL/
else ifdef SG2A_ORIN_G2_M4L_F
	obj-y += SG2A_ORIN_G2_M4L_F/
else ifdef SG12A_AGON_G2M_A1
	obj-y += SG12A_AGON_G2M_A1/
else ifdef SG10A_AGON_G2M_A1
	obj-y += SG10A_AGON_G2M_A1/	
else ifdef	SG8_AGX_ORIN_89712
	obj-y += SG8_AGX_ORIN_89712/	
endif
