# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG8A_ORIN_GMSLX8_V2

//dtbo-y += tegra234-camera-yuv-gmsl1x8-overlay.dtbo

ifdef SG8A_ORIN_GMSLX8_V2
ifdef SG8_IMX728C_GMSL3
	dtbo-y += tegra234-camera-imx728-gmsl3x8-overlay.dtbo
	#dtbo-y += tegra234-camera-yuv-gmsl2x4-imx728-gmsl3x4-overlay.dtbo
else ifdef SG17_IMX735C_GMSL3
	dtbo-y += tegra234-camera-imx735-gmsl3x8-overlay.dtbo
else ifdef SG8_AR0823C_GMSL2
	dtbo-y += tegra234-camera-ar0823-gmsl2x8-overlay.dtbo
else ifdef SG8_OX08BC_GMSL2
	dtbo-y += tegra234-camera-ox08b-gmsl2x8-overlay.dtbo
else ifdef SG2_AR0233C_GMSL2
	dtbo-y += tegra234-camera-ar0233-gmsl2x8-overlay.dtbo
else ifdef SG2_IMX390C_GMSL2
	dtbo-y += tegra234-camera-imx390-gmsl2x8-overlay.dtbo
else ifdef SG2_IMX662C_GMSL2
	dtbo-y += tegra234-camera-imx662-gmsl2x8-overlay.dtbo
else ifdef SG2_OX03CC_GMSL2
	dtbo-y += tegra234-camera-ox03c-gmsl2x8-overlay.dtbo
else ifdef SG8_AR0820C_GMSL2
	dtbo-y += tegra234-camera-ar0820-gmsl2x8-overlay.dtbo
else ifdef SG8_IMX728C_GMSL2
	dtbo-y += tegra234-camera-imx728-gmsl2x8-overlay.dtbo
else ifdef SG8_S5K1H1SB_GMSL2
	dtbo-y += tegra234-camera-s5k1h1sb-gmsl2x8-overlay.dtbo
else ifdef SG8_OX08DC_GMSL2
	dtbo-y += tegra234-camera-ox08d-gmsl2x8-overlay.dtbo
else ifdef (SGX_YUV_GMSL3)
	dtbo-y += tegra234-camera-yuv-gmsl3x8-overlay.dtbo
	#dtbo-y += tegra234-camera-yuv-gmsl2x4-yuv-gmsl3x4-overlay.dtbo
endif
endif

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
