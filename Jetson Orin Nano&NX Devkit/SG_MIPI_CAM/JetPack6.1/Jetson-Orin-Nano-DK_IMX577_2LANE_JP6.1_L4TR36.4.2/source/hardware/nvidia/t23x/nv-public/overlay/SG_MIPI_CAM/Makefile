# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

DTC_FLAGS += -@

old-dtb := $(dtb-y)
old-dtbo := $(dtbo-y)
dtb-y :=
dtbo-y :=
makefile-path := t23x/nv-public/overlay/SG_MIPI_CAM

ifdef SG12_MIPI_IMX577
	dtbo-y += tegra234-camera-imx577-mipi-overlay.dtbo
else ifdef SG3_MIPI_ISX031
	dtbo-y += tegra234-camera-isx031-mipi-overlay.dtbo
else ifdef SG8_MIPI_IMX678
	dtbo-y += tegra234-camera-imx678-mipi-overlay.dtbo
else ifdef SG20_MIPI_IMX283
	dtbo-y += tegra234-camera-imx283-mipi-overlay.dtbo	
else ifdef SG2_MIPI_IMX662
	dtbo-y += tegra234-camera-imx662-mipi-overlay.dtbo	
endif

ifneq ($(dtb-y),)
dtb-y := $(addprefix $(makefile-path)/,$(dtb-y))
endif
ifneq ($(dtbo-y),)
dtbo-y := $(addprefix $(makefile-path)/,$(dtbo-y))
endif

dtb-y += $(old-dtb)
dtbo-y += $(old-dtbo)
