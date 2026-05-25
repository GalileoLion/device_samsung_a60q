#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a60q

# Local overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay

# Boot animation
TARGET_SCREEN_HEIGHT := 2340
TARGET_SCREEN_WIDTH := 1080

# Init scripts
PRODUCT_PACKAGES += \
    init.a60q.rc

# Fstab
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/vendor/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom

# Inherit from the common makefile
$(call inherit-product, device/samsung/sm6150-common/sm6150.mk)

# Inherit from the proprietary files makefile
$(call inherit-product, vendor/samsung/a60q/a60q-vendor.mk)
