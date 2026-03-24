# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A_ORIN_GMSL

ifdef SG10A_ORIN_GMSL
	ifdef ST60_ISX031_G2D
		dtbo-y += tegra234-camera-isx031-9295d-gmsl2x4-overlay.dtbo
	else ifdef S36X2_SHF3LX6
		dtbo-y += tegra234-camera-s36x2-shf3lx6-overlay.dtbo
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
