# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG10A-ORIN-GMSL

# //dtbo-y += tegra234-camera-yuv-gmsl1x8-overlay.dtbo

ifdef SG10A_ORIN_GMSL
ifdef SGX_G2XX_SH3
	dtbo-y += tegra234-camera-g2xx-sh3x6-overlay.dtbo  # sensing add
else ifdef SGX_G2XX
	dtbo-y += tegra234-camera-g2xx-overlay.dtbo  # sensing add
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

