# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG8A_AGON_G2Y_A1

ifdef SG8A_AGON_G2Y_A1
ifdef SGCAM_GMSL2
	dtbo-y += sgcam/tegra234-camera-sgcam-yuv-gmsl2x8-overlay.dtbo
	dtbo-y += sgcam/tegra234-camera-sgcam-shw3gx8-overlay.dtbo
	dtbo-y += sgcam/tegra234-camera-sgcam-sdv11nm1x4-overlay.dtbo
else ifdef SGX_YUV_GMSL2
	dtbo-y += tegra234-camera-yuv-gmsl2x8-overlay.dtbo
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
