# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG8A_ORIN_GMSLX8

ifdef SG12_IMX577_G3A
	dtbo-y += tegra234-camera-imx577-gmsl3x8-overlay.dtbo
else ifdef SG8_IMX715_G3A
	dtbo-y += tegra234-camera-imx715-gmsl3x8-overlay.dtbo
else ifdef SG8_IMX678_G3A
	dtbo-y += tegra234-camera-imx678-gmsl3x8-overlay.dtbo
else ifdef SG8_IMX678_G2A
	dtbo-y += tegra234-camera-imx678-gmsl2x8-overlay.dtbo
else ifdef SG20_IMX283_G3A
	dtbo-y += tegra234-camera-imx283-gmsl3x8-overlay.dtbo
else ifdef SG8_IMX585_G3A
	dtbo-y += tegra234-camera-imx585-gmsl3x8-overlay.dtbo
else ifdef SG8_AR2020_G3A
	dtbo-y += tegra234-camera-ar2020-gmsl3x8-overlay.dtbo
else ifdef SGX_YUV_G2A
	dtbo-y += tegra234-camera-yuv-gmsl2x8-overlay.dtbo
else ifdef SG2_AR0234_9295D_GMSL2
	dtbo-y += tegra234-camera-ar0234-9295d-gmsl2x4-overlay.dtbo
else ifdef SG5_OX05B_9295D_GMSL2
	dtbo-y += tegra234-camera-ox05b-9295d-gmsl2x4-overlay.dtbo
endif

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
