# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t264/nv-public/overlay/SG16A_AGTH_G3Y_A1

ifdef SG16A_AGTH_G3Y_A1

ifdef SG8_IMX715C_G3A
dtbo-y += tegra264-camera-imx715x16-overlay.dtbo
endif
ifdef SG12_IMX577C_G3A
dtbo-y += tegra264-camera-imx577x16-overlay.dtbo
endif
ifdef SG17_IMX735C_G3A
dtbo-y += tegra264-camera-imx735x16-overlay.dtbo
endif
ifdef SGCAM_GMSL2
dtbo-y += tegra264-camera-yuv-gmsl2x16-overlay.dtbo
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