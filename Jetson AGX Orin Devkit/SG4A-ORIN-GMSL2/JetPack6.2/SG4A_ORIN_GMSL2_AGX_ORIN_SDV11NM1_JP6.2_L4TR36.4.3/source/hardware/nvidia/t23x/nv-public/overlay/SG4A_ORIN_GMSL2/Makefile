# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG4A_ORIN_GMSL2

ifdef SGX_YUV_GMSL2
dtbo-y += tegra234-camera-yuv-gmsl2x16-overlay.dtbo
dtbo-y += tegra234-camera-yuv-gmsl2x4-overlay.dtbo
else ifdef SDV11NM1
dtbo-y += tegra234-camera-sdv11nm1-overlay.dtbo
endif

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
