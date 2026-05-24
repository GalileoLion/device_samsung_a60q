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

# TODO: Replace with verified A60 stock build properties.
# Example values must come from the target firmware, not from A70.
PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceProduct=a60q \
    SystemName=a60q

PRODUCT_GMS_CLIENTID_BASE := android-samsung
