# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A_AGON_G2M_A1

ifdef SG10A_AGON_G2M_A1
	ifdef ST60_ISX031_G2D
		dtbo-y += tegra234-camera-isx031-9295d-gmsl2x4-overlay.dtbo  # sensing add
	else ifdef SHW3H_SHF3L
		dtbo-y += tegra234-camera-shw3h-shf3lx10-overlay.dtbo  # sensing add
	else ifdef SHW5G
		dtbo-y += tegra234-camera-shw5g-gmsl2x10-overlay.dtbo  # sensing add
	else ifdef SDV11NM1
		dtbo-y += tegra234-camera-sdv11nm1x4-overlay.dtbo  # sensing add
	else ifdef S56
		dtbo-y += tegra234-camera-s56-gmsl2-overlay.dtbo  # sensing add
	else ifdef S56_SHW5G
		dtbo-y += tegra234-camera-s56x2-shw5gx6-overlay.dtbo  # sensing add
		dtbo-y += tegra234-camera-s56-gmsl2x4-overlay.dtbo
		dtbo-y += tegra234-camera-shw5g-gmsl2x10-overlay.dtbo
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
