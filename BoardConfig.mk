#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a60q

TARGET_USE_DYNAMIC_PARTITIONS := false

include device/samsung/sm6150-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := a60q

# Board
# Verified from TGY A6060ZHU3CXE1 stock boot/recovery image header.
BOARD_NAME := RILRL28A003

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

# Partitions
# Verified from TGY A6060ZHU3CXE1 A60Q_CHN_HK.pit.
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE := 629145600
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 72744960
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 5830082560
BOARD_VENDORIMAGE_PARTITION_SIZE := 1090519040

# Recovery
# Verified from the existing A60 TWRP tree.
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/vendor/etc/fstab.qcom
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# Inherit from the proprietary version
include vendor/samsung/a60q/BoardConfigVendor.mk
