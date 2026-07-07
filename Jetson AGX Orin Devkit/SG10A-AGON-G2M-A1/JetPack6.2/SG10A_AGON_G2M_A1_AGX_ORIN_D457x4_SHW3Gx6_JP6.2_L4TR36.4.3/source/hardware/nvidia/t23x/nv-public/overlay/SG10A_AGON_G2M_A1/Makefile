# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A_AGON_G2M_A1

ifdef SG10A_AGON_G2M_A1
ifdef SGX_D4XX_SH3
dtbo-y += tegra234-camera-d4xx-sh3x6-overlay.dtbo
else ifdef SGX_D4XX_SHW3G
dtbo-y += tegra234-camera-d4xx-shw3gx6-overlay.dtbo
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

