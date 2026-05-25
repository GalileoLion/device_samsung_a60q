#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from a60q device
$(call inherit-product, device/samsung/a60q/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_a60q
PRODUCT_DEVICE := a60q
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A6060
PRODUCT_MANUFACTURER := samsung

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=samsung/a60qzh/a60q:11/RP1A.200720.012/A6060ZHU3CXE1:user/release-keys \
    DeviceProduct=a60qzh \
    PRIVATE_BUILD_DESC="a60qzh-user 11 RP1A.200720.012 A6060ZHU3CXE1 release-keys" \
    SystemName=a60qzh

PRODUCT_GMS_CLIENTID_BASE := android-samsung
