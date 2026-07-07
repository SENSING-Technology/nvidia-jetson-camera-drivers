# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t264/nv-public/overlay/SG8A_AGTH_G2Y_A1

ifdef SG8A_AGTH_G2Y_A1
ifdef SGX_YUV_GMSL2
dtbo-y += tegra264-camera-yuv-gmsl2x8-overlay.dtbo
else ifdef SHW3G
dtbo-y += tegra264-camera-shw3gx8-overlay.dtbo
else ifdef SHW5G
dtbo-y += tegra264-camera-shw5gx8-overlay.dtbo
else ifdef SG8_OX08DC_G2G
dtbo-y += tegra264-camera-ox08dx8-overlay.dtbo
else ifdef ASTRA_S36
dtbo-y += tegra264-camera-s36x4-overlay.dtbo
else ifdef SDV11NM1
dtbo-y += tegra264-camera-sdv11nm1x4-overlay.dtbo
else ifdef ASTRA_S56
dtbo-y += tegra264-camera-s56x4-overlay.dtbo
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
