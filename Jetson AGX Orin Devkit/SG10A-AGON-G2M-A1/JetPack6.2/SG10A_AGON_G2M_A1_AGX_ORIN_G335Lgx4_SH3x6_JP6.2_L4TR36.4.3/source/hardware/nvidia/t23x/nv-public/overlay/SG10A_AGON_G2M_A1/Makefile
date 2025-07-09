# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A_AGON_G2M_A1

dtbo-y += tegra234-camera-g2xx-sh3x6-overlay.dtbo

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)

