#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a60q

include device/samsung/sm6150-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := a60q

# Board
# TODO: Verify board name from A60 stock boot image / kernel dtb.
# Do not copy A70's SRPRL06C005 blindly.
# BOARD_NAME :=

# Kernel
TARGET_KERNEL_CONFIG := a60q_defconfig

# Fingerprint
# A60 uses a rear-mounted fingerprint sensor. Override A70/common UDFPS defaults.
TARGET_SURFACEFLINGER_UDFPS_LIB :=
TARGET_USES_FOD_ZPOS := false
TARGET_SEC_FP_REQUEST_FORCE_CALIBRATE := false
TARGET_SEC_FP_REQUEST_TOUCH_EVENT := false

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
# Verified from the existing A60 TWRP tree.
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# Inherit from the proprietary version
include vendor/samsung/a60q/BoardConfigVendor.mk
