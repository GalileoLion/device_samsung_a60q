进度：A√选择 `lineage-22.2` 基线 -> B√建立 A60 设备树骨架 -> C√对照 TWRP 冲突点 -> D√上传 `lineage-22.2` 分支 -> E√提取 TGY stock 固件信息 -> F√完善 fstab/分区/BoardConfig -> G√准备初始 vendor blobs -> H 构建 boot/recovery -> I 首次启动与日志修复

# 三星 Galaxy A60 设备树开发计划

## 目标

为三星 Galaxy A60（`a60q`，SM-A6060）制作可用于 LineageOS 的设备树。

基本思路是：在技术上确实相同的地方复用成熟的三星 A70（`a70q`）/ SM6150 生态；凡是 A60 自身硬件相关的配置，都必须从 A60 官方固件、已有 A60 TWRP 树、内核、dtb/dtbo 或真机 dump 中确认后再写入。

## 当前状态

当前设备树已经推进到初始 bring-up 阶段：

- 已建立 `device/samsung/a60q` 的 LineageOS 设备树骨架。
- 已切到 `lineage-22.2` 作为起始分支方向。
- 已确认不以 TWRP 树作为 ROM 设备树主基础，只把它作为参数来源之一。
- 已从 TGY `A6060ZHU3CXE1` 固件提取并核实 boot/recovery/dtbo/vbmeta/PIT/vendor。
- 已写入 A60 的 `BOARD_NAME := RILRL28A003`。
- 已按 A60 PIT 覆盖 boot/recovery/dtbo/system/vendor/cache 分区大小。
- 已明确 `TARGET_USE_DYNAMIC_PARTITIONS := false`。
- 已创建 A60 专用 `rootdir/vendor/etc/fstab.qcom`，并同时用于 recovery fstab 和 vendor 镜像复制。
- 已修正 common 继承为 `device/samsung/sm6150-common/sm6150.mk`。
- 已写入 TGY stock 构建指纹和 `PRIVATE_BUILD_DESC`。
- 已建立初始 `proprietary-files.txt`，包含已从 A60 vendor 镜像核实存在的相机、后置指纹、音频路径和设备固件 blobs。
- 已把本工作区移动到 `/run/media/kelon/三星固件/SM-A6060/a6060_device_tree`，和固件包放在同一分区下。

当前还没有开始完整 Lineage 源码环境内的 `lunch` / `mka bootimage` / `mka recoveryimage` 构建验证。

下一步重点：

- 继续对比 CHC `A6060ZCS3CWE1` 与 TGY `A6060ZHU3CXE1` 的 PIT、boot、recovery、dtbo、vendor 差异。
- 根据 CHC/TGY 对比结果决定最终 blob 主来源。
- 在完整 Lineage 源码树中抽取 vendor blobs，验证 `vendor/samsung/a60q` 生成结果。
- 准备 `a60q_defconfig` / 内核差异对照，然后开始 `bootimage` 和 `recoveryimage` 构建。

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

## A60 固件来源策略

三星官方更新文档显示，`SM-A6060` 港版 TGY 和国行 CHC 的末期固件版本、补丁级别和更新性质不同：

- TGY 官方更新页：`https://doc.samsungmobile.com/SM-A6060/TGY/doc.html`
  - 最新记录为 `A6060ZHU3CXE1`
  - 发布时间为 2024-06-03
  - 安全补丁级别仍为 2023-05-01
  - 更新内容是整体稳定性优化，不是新的安全补丁
  - 上一个 TGY `A6060ZHS3CWE1` 才是 2023-05-01 安全补丁更新

- CHC 官方更新页：`https://doc.samsungmobile.com/SM-A6060/CHC/doc.html`
  - 最新记录为 `A6060ZCS3CWE1`
  - 发布时间为 2023-06-05
  - 安全补丁级别为 2023-03-01

因此不能只因为 TGY 的版本号从 `W` 到 `X` 就默认它更适合作为设备树主来源。`CXE1` 更像 One UI 维护更新，是否影响 boot/dtbo/vendor 需要通过固件镜像 diff 确认。

当前方向调整为：

- 不预设唯一主提取源。
- 同时准备 A60 TGY 最新固件和 A60 CHC 最新固件。
- 先比较两者的 PIT、boot image、recovery image、dtbo、vendor image、stock fstab 和 vendor blobs。
- 如果 TGY `CXE1` 相比 TGY `CWE1` / CHC `CWE1` 只改上层或区域内容，而底层硬件相关镜像无实质变化，则不因版本号优先使用 TGY。
- 如果目标真机是国行硬件/国行销售版本，并且 CHC 与 TGY 的底层镜像存在差异，则以 CHC 作为设备树主依据。
- 如果 CHC 与 TGY 的底层硬件相关部分一致，而 TGY vendor blobs 更新或更通用，则可以用 TGY 作为 blobs 主来源，同时保留 CHC 对照记录。
- 三星 M40 最新 Android 11 固件作为第二对照源，用于同硬件近亲对照。

使用原则：

- 分区、fstab、boot header、dtbo、panel、touch、fingerprint、camera、audio 以实际镜像 diff 为准。
- CSC、RIL、modem、区域 feature 不从 M40 直接继承。
- M40 只能作为同平台/近似硬件参考，不能替代 A60 的设备身份、RIL、CSC 或 modem 相关配置。

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

### TGY 固件已确认信息

当前已从港版 TGY `A6060ZHU3CXE1` 固件提取并分析：

- `boot.img`
- `recovery.img`
- `dtbo.img`
- `vbmeta.img`
- `A60Q_CHN_HK.pit`
- `vendor.img.ext4`

分析产物暂存在本地：

```text
firmware_analysis/TGY_A6060ZHU3CXE1
```

注意：这些是本地分析文件和大镜像，不应提交到设备树仓库。

固件包和设备树工作区当前都保存在三星固件分区下；分析产物位于本地 `firmware_analysis/`，并通过 `.gitignore` 排除，不提交到设备树仓库。

从 `boot.img` / `recovery.img` 已确认：

- boot image header version：`1`
- page size：`4096`
- kernel offset：`0x00008000`
- ramdisk offset：`0x02000000`
- tags offset：`0x01e00000`
- cmdline 与当前 SM6150 common 基本一致
- product name / `BOARD_NAME`：`RILRL28A003`
- boot security patch：`2023-05`
- stock boot 无 ramdisk
- recovery image 带 recovery dtbo

从 `A60Q_CHN_HK.pit` 已确认的关键分区尺寸：

| 分区 | 大小 |
| --- | ---: |
| `boot` | `67108864` |
| `recovery` | `72744960` |
| `dtbo` | `8388608` |
| `system` | `5830082560` |
| `vendor` | `1090519040` |
| `product` | `536870912` |
| `cache` | `629145600` |
| `hidden` | `10485760` |
| `omr` | `20971520` |
| `persist` | `33554432` |
| `efs` | `20971520` |
| `sec_efs` | `20971520` |
| `apnhlos` | `100663296` |
| `modem` | `92274688` |
| `dsp` | `37748736` |

当前已在 A60 `BoardConfig.mk` 覆盖：

- `BOARD_BOOTIMAGE_PARTITION_SIZE`
- `BOARD_CACHEIMAGE_PARTITION_SIZE`
- `BOARD_DTBOIMG_PARTITION_SIZE`
- `BOARD_RECOVERYIMAGE_PARTITION_SIZE`
- `BOARD_SYSTEMIMAGE_PARTITION_SIZE`
- `BOARD_VENDORIMAGE_PARTITION_SIZE`

仍需继续确认 `product` 在 Lineage 当前 common 组织下是否继续放进 `system/product`，还是要按 stock 独立 `product` 分区处理。

从 `vendor` 中导出的 stock `fstab.qcom` 已确认：

- `/data` 是 `ext4`，不是 A70 动态分区 fstab 里的 `f2fs`。
- `persist` 挂载到 `/mnt/vendor/persist`。
- `efs` 挂载到 `/mnt/vendor/efs`。
- `sec_efs` 挂载到 `/efs`。
- `apnhlos` 挂载到 `/vendor/firmware_mnt`。
- `modem` 挂载到 `/vendor/firmware-modem`。
- `dsp` 挂载到 `/vendor/dsp`。
- 存在 `cache`、`carrier` 挂载项。
- 外置 SD 节点为 `/devices/platform/soc/8804000.sdhci/mmc_host*`。
- USB 存储节点为 `/devices/platform/soc/a600000.ssusb/a600000.dwc3/xhci-hcd.0.auto*`。

当前已创建 A60 专用 recovery fstab：

```text
rootdir/vendor/etc/fstab.qcom
```

并在 `BoardConfig.mk` 中覆盖：

```make
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/vendor/etc/fstab.qcom
```

并在 `device.mk` 中复制到 vendor 镜像：

```make
$(DEVICE_PATH)/rootdir/vendor/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom
```

这个 fstab 以 SM6150 common recovery fstab 的结构为基础，保留 recovery 构建需要的 `boot`、`recovery`、`system`、`vendor`、`vbmeta`、`metadata/omr` 入口，同时把 `/data`、`cache`、`efs`、`sec_efs`、firmware 挂载和 VOLD 节点按 A60 stock vendor fstab 修正。

从 `vendor/build.prop` 已确认：

- `ro.product.board=sm6150`
- `ro.board.platform=sm6150`
- `ro.vendor.build.fingerprint=samsung/a60qzh/a60q:11/RP1A.200720.012/A6060ZHU3CXE1:user/release-keys`
- `ro.product.vendor.device=a60q`
- `ro.product.vendor.model=SM-A6060`
- `ro.product.vendor.name=a60qzh`
- `ro.vendor.build.security_patch=2023-05-01`
- `persist.vendor.radio.multisim.config=dsds`
- `vendor.sec.rild.libpath=/vendor/lib64/libsec-ril.so`
- `vendor.sec.rild.libpath2=/vendor/lib64/libsec-ril-dsds.so`
- `ro.sf.lcd_density=420`

当前已在 `lineage_a60q.mk` 写入 TGY 固件确认的构建指纹覆盖：

- `BuildFingerprint=samsung/a60qzh/a60q:11/RP1A.200720.012/A6060ZHU3CXE1:user/release-keys`
- `PRIVATE_BUILD_DESC="a60qzh-user 11 RP1A.200720.012 A6060ZHU3CXE1 release-keys"`
- `DeviceProduct=a60qzh`
- `SystemName=a60qzh`

当前已修正 `device.mk` 的 common 继承目标：

```make
$(call inherit-product, device/samsung/sm6150-common/sm6150.mk)
```

原因是 A70/SM6150 common 仓库中的主产品 makefile 名称是 `sm6150.mk`，不是 `common.mk`。

从 `vendor/default.prop` 已确认：

- `ro.vndk.version=30`
- `ro.vendor.multisim.simslotcount=2`
- `ro.minui.pixel_format=RGBX_8888`

从 vendor init / VINTF 已确认：

- A60 stock 存在 Samsung 指纹 HAL：`vendor.samsung.hardware.biometrics.fingerprint@3.0-service`
- 指纹服务 class 是 `late_start`，与需要等待 `/data` 的注释一致。
- A60 stock 存在 USB HAL：`android.hardware.usb@1.1-service.wahoo`
- VINTF 同时声明 AOSP `android.hardware.biometrics.fingerprint@2.1` 和 Samsung `vendor.samsung.hardware.biometrics.fingerprint@3.0`。

### Vendor blobs 清单进展

已开始准备 A60 单设备 `proprietary-files.txt`。

当前只放入已经从 TGY `vendor.img` 核实、并且不适合直接沿用 A70 common 的设备专有项：

- Samsung camera provider 服务
- A60 相机 sensor module / tuning 文件：
  - `gc5035`
  - `s5k3p8sp`
  - `s5k4ha`
  - `s5kgd1`
- A60 后置 Egis/Samsung 指纹 HAL
- A60 相机 / 扬声器相关固件：
  - `CAMERA_ICP.elf`
  - `Tfa9xxx.cnt`
  - `dax_param.bin`

已验证 `proprietary-files.txt` 中当前每个路径都存在于 TGY `vendor.img`。

已对 A60 stock 音频配置与 SM6150 common rootdir 做初步比对：

- common rootdir 缺少 `mixer_paths_idp.xml`，已加入 A60 专有清单。
- common rootdir 缺少 `SoundBoosterParam.txt`，已加入 A60 专有清单。
- `audio_platform_info.xml` 与 common 一致。
- `audio_platform_info_qrd.xml` 与 common 一致。
- `media_profiles_vendor.xml` 与 common 一致。
- `audio_platform_info_diff.xml` 与 common 有差异。
- `audio_platform_info_intcodec.xml` 与 common 有差异。
- `audio_policy_configuration.xml` 与 common 有差异。
- `audio_policy_configuration_base.xml` 与 common 有差异。
- `thermal-engine.conf` 在 common rootdir 中不存在，但 common proprietary list 已包含同名文件，不能直接在 A60 单设备清单里重复加入。

下一步需要决定：对这些同名但有差异的音频配置，是继续暂用 common，还是在 common/设备树层面做 A60 条件化覆盖，避免 duplicate rule。

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
