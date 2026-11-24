# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A_AGON_G2M_A1

dtbo-y += sgcam/tegra234-camera-s36-gmsl2x5-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-s56-gmsl2x5-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-s56c-gmsl2x5-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-sgcamx10-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-shw3g-gmsl2x10-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-shw5g-gmsl2x10-overlay.dtbo
dtbo-y += sgcam/tegra234-camera-yuv-gmsl2x10-overlay.dtbo
ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
