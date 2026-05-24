# 三星 Galaxy A60 设备树开发计划

## 目标

为三星 Galaxy A60（`a60q`，SM-A6060）制作可用于 LineageOS 的设备树。

基本思路是：在技术上确实相同的地方复用成熟的三星 A70（`a70q`）/ SM6150 生态；凡是 A60 自身硬件相关的配置，都必须从 A60 官方固件、已有 A60 TWRP 树、内核、dtb/dtbo 或真机 dump 中确认后再写入。

## 基本原则

- 不猜硬件接口，修改前先查现有树、官方固件、内核源码或设备 dump。
- 能复用 SM6150 common 的地方优先复用。
- A60 专有内容放在 `device/samsung/a60q`。
- 不盲目复制 A70 的设备专有值。
- 每一阶段都要通过构建验证，后续再通过 boot log / dmesg / logcat 验证。

## 起始分支

初始使用 `lineage-22.2`。

原因：

- `a70q-lineage` 里的 device/common/kernel 当前默认或活跃分支是 `lineage-22.2`。
- `android_device_samsung_a70q`、`android_device_samsung_sm6150-common`、`android_kernel_samsung_sm6150` 都有匹配的 `lineage-22.2` 分支。
- 这个分支能拿到最新维护过的树结构。

注意：

- 第一阶段目标不是“最新 Android 完整可用”。
- 第一阶段目标是能被 lunch 识别、能编译、能产出 boot/recovery，并开始基础启动验证。
- 如果 A60 stock vendor blobs 和 `lineage-22.2` 兼容性成为硬阻塞，再对比 `lineage-21`，决定是否临时降到 LineageOS 21。

## 基础仓库

主要使用这些仓库：

- `a70q-lineage/android_device_samsung_a70q`
  - 用作 A60 单设备树的结构模板。
  - 只复制组织方式，不复制 A70 硬件参数。

- `a70q-lineage/android_device_samsung_sm6150-common`
  - 直接作为 common device tree 使用。
  - 这是 A70 生态里最有价值的部分。

- `a70q-lineage/android_kernel_samsung_sm6150`
  - 作为初始内核源码。
  - 需要在核对 A60 stock kernel / dtb / dtbo 差异后添加或派生 `a60q_defconfig`。

- `a70q-lineage/proprietary_vendor_samsung_sm6150-common`
  - 作为 common blobs 和抽取结构参考。
  - 能从 A60 stock 固件抽取的，优先使用 A60 stock blobs。

- `a70q-lineage/proprietary_vendor_samsung_a70q`
  - 只作为单设备 vendor 布局参考。
  - 不直接复用 A70 设备专有 blobs。

不作为主基础的仓库：

- `android_device_samsung_sm7150-common`
- `proprietary_vendor_samsung_sm7150-common`
- `android_device_samsung_r1q`
- `proprietary_vendor_samsung_r1q`

这些不是 A60 的主平台基础。

## 本地 A60 TWRP 树的作用

已有 TWRP 树：

- `GalileoLion/device_samsung_a60q`
- 分支：`twrp-9.0`

它只作为参考，不作为完整 ROM 设备树的主基础。

可参考的信息：

- `DEVICE_PATH := device/samsung/a60q`
- `TARGET_OTA_ASSERT_DEVICE := a60q`
- `TARGET_BOOTLOADER_BOARD_NAME := sm6150`
- kernel cmdline 线索
- boot image header version
- kernel pagesize
- ramdisk/tags offsets
- prebuilt `Image.gz-dtb` / `dtbo.img` 线索
- backlight 路径
- recovery pixel format
- TWRP recovery 相关硬件记录

它不足以直接作为完整 ROM 设备树：

- `device.mk` 基本是空的。
- 没有完整 Lineage 需要的 package 列表、vendor 继承、overlay、HAL 配置、SELinux 组织。

### TWRP 树对照结论

继续 Lineage bring-up 前已经对照过 TWRP 树。以下是相关差异和潜在冲突点。

当前 Lineage 骨架故意不导入这些 TWRP-only 配置：

- `ALLOW_MISSING_DEPENDENCIES := true`
- `TW_*` recovery UI 配置
- 防回滚伪造值：
  - `PLATFORM_SECURITY_PATCH := 2099-12-31`
  - `VENDOR_SECURITY_PATCH := 2099-12-31`
  - `PLATFORM_VERSION := 16.1.0`
- `vendor/omni` 产品继承

可以在确认后带入或参考的 TWRP 值：

- `TARGET_BOOTLOADER_BOARD_NAME := sm6150`
- `BOARD_KERNEL_CMDLINE`
- `BOARD_BOOTIMG_HEADER_VERSION := 1`
- `BOARD_KERNEL_BASE := 0x00000000`
- `BOARD_KERNEL_PAGESIZE := 4096`
- `BOARD_RAMDISK_OFFSET := 0x02000000`
- `BOARD_KERNEL_TAGS_OFFSET := 0x01e00000`
- `BOARD_FLASH_BLOCK_SIZE := 262144`
- `BOARD_INCLUDE_RECOVERY_DTBO := true`
- `TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888`
- `TW_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness`，可作为显示/backlight 线索

与当前 SM6150 common 方向存在差异，或必须从 stock 固件确认的点：

- TWRP 使用 `TARGET_KERNEL_SOURCE := kernel/samsung/a60q`；A70 Lineage common 期望 `kernel/samsung/sm6150`。
- TWRP 使用 prebuilt `Image.gz-dtb` 和 `dtbo.img`；完整 ROM bring-up 应优先从 `kernel/samsung/sm6150` 编译，但这些 prebuilt 可用于反查差异。
- TWRP 的 `recovery.fstab` 里 `/data` 是 `ext4`；A70 common 使用 `f2fs`。必须先确认 A60 stock fstab。
- TWRP 的 `recovery.fstab` 有 `product`、`preload/hidden`、`vbmeta_samsung`；A70 common fstab 不完全一致。必须确认 A60 PIT / stock fstab。
- TWRP 把 `/efs` 和 `/sec_efs` 都映射到 `sec_efs`；A70 common 分别挂载 `efs` 和 `sec_efs`。必须确认 A60 实际分区用途。
- TWRP 的可移动存储路径有部分来自 A70，不应在未检查 A60 设备节点前信任。
- TWRP recovery init 脚本对 recovery/decryption 有参考价值，但不能原样导入普通 vendor init。

## 初始实现方向

创建：

```text
device/samsung/a60q
```

结构参考：

```text
device/samsung/a70q
```

然后把 A70 身份和值替换为 A60：

- `a70q` -> `a60q`
- `A705` / `SM-A705` -> `A6060` / `SM-A6060`
- `lineage_a70q.mk` -> `lineage_a60q.mk`
- `PRODUCT_NAME := lineage_a60q`
- `PRODUCT_DEVICE := a60q`
- `TARGET_OTA_ASSERT_DEVICE := a60q`
- `DEVICE_PATH := device/samsung/a60q`
- vendor 路径改为 `vendor/samsung/a60q`

保留 common 继承：

```make
include device/samsung/sm6150-common/BoardConfigCommon.mk
$(call inherit-product, device/samsung/sm6150-common/common.mk)
```

当前已经创建了初始骨架，并且已经明确覆盖：

- A60 recovery pixel format：`TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888`
- A70/common UDFPS 相关配置，避免屏下指纹逻辑泄漏到 A60

## 构建顺序

先做设备树，不先单独编译内核。

原因：

- 设备树控制 boot image 参数、fstab、vendor 继承、HAL、产品身份、分区大小、recovery 配置和 SELinux。
- 单独内核编译成功，不代表能被 ROM 正确集成和启动。

第一批推荐构建目标：

```text
lunch lineage_a60q-userdebug
mka bootimage
mka recoveryimage
```

然后再推进到：

```text
mka vendorimage
mka bacon
```

具体取决于前面能走多远。

## 必须核实的 A60 专有值

这些必须从 A60 stock 固件、PIT、boot image、dtbo、vendor image 或真机 dump 中确认。

### 显示

A60：

- 1080 x 2340
- TFT/PLS
- 无屏下指纹

A70：

- 1080 x 2400
- AMOLED
- 屏下指纹

A60 必要配置：

```make
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 2340
```

不要盲目保留 A70 的 display overlay、LiveDisplay 假设、panel 配置或 UDFPS 行为。

### 指纹

A60 使用后置指纹。

A70 使用屏下指纹。

必要处理：

- 移除或覆盖 A70 UDFPS 配置。
- 不保留 A70 的 `ro.vendor.fingerprint.sensor_location`。
- 从 A60 stock vendor 核实 fingerprint HAL / blobs。
- 检查 common Samsung fingerprint HAL 是否能配合 A60 blobs 支持 A60 指纹传感器。

需要重点检查这些 A70/common 配置：

```make
TARGET_SURFACEFLINGER_UDFPS_LIB
TARGET_USES_FOD_ZPOS
TARGET_SEC_FP_REQUEST_FORCE_CALIBRATE
TARGET_SEC_FP_REQUEST_TOUCH_EVENT
```

当前 A60 设备树已经在 `BoardConfig.mk` 中覆盖这些值。

### 相机

不要复用 A70 相机 sensor 值。

必须从 A60 stock vendor 核实：

- camera sensor libraries
- CHI override blobs
- camera module binary files
- camera IDs
- `SOONG_CONFIG_samsungCameraVars_extra_ids`
- `media_profiles`
- camera provider 行为

A70 common 当前引用了 ultrawide/depth 额外 ID，A60 必须独立确认。

### 音频

A70 音频配置只能作为参考。

必须从 A60 stock vendor 核实：

- `mixer_paths*.xml`
- ACDB 文件
- speaker / handset / headset 校准
- sound trigger 配置

### 分区和 fstab

必须从 A60 确认：

- PIT
- stock `fstab.qcom`
- boot/recovery image ramdisk
- vendor image

重点检查：

- `boot`
- `recovery`
- `dtbo`
- `system`
- `vendor`
- `product`
- `cache`
- `userdata`
- `metadata` / `omr`
- `efs`
- `sec_efs`
- `persist`
- `dsp`
- `modem`
- `apnhlos`
- `hidden` / `preload`
- `vbmeta_samsung`

不要盲目使用 A70 分区大小。

### 内核和 DTBO

初始源码：

```text
kernel/samsung/sm6150
```

需要创建或派生：

```text
arch/arm64/configs/a60q_defconfig
```

必须确认 A60 差异：

- panel driver / dtsi
- touch driver / dtsi
- fingerprint GPIO
- camera sensor dtsi
- battery / charger 配置
- dtbo 内容
- defconfig 选项

TWRP 里的 prebuilt `Image.gz-dtb` 和 `dtbo.img` 可用于对比。

## 第一阶段里程碑

1. 创建 `device/samsung/a60q` 初始骨架。
2. 替换产品身份和 lunch 配置。
3. 继承 `sm6150-common`。
4. 用已确认的值补充初始 `BoardConfig.mk`。
5. 准备 `vendor/samsung/a60q` 抽取布局。
6. 构建 `bootimage`。
7. 构建 `recoveryimage`。
8. 修复编译错误。
9. 正确抽取 A60 stock blobs。
10. 尝试第一次启动并收集日志。

## 已知风险点

- A70 UDFPS 假设泄漏到 A60。
- A70 2400px 显示假设泄漏到 A60 2340px 显示。
- 分区大小错误。
- A70 相机 blobs / sensor ID 不适用于 A60。
- A70 音频校准不适用于 A60。
- kernel dtsi / defconfig 不匹配。
- Android 11 stock vendor blobs 与 `lineage-22.2` 预期不匹配。
- 首次启动后的 SELinux 问题。

## 下一步

继续从 A60 stock 固件提取和确认：

- PIT / 分区表
- stock fstab
- `boot.img`
- `recovery.img`
- `dtbo.img`
- `vendor.img`
- kernel / dtb / dtbo 差异
- vendor blobs 清单

每个设备专有值都需要和以下来源交叉核对：

- 已有 A60 TWRP 树
- A60 stock 固件
- A60 boot/recovery image
- A60 vendor image
- A60 PIT / partition table
