进度：A√选择 `lineage-22.2` 基线 -> B√建立 A60 设备树骨架 -> C√对照 TWRP 冲突点 -> D√上传设备树分支 -> E√提取 TGY stock 固件信息 -> F√完善 fstab/分区/BoardConfig -> G√抽取 vendor blobs -> H√上传完整依赖仓库 -> I 内核真适配 -> J 构建 boot/recovery -> K 首次启动与日志修复

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
- 已完成 TGY vendor 镜像对 A60 单设备 proprietary list 的第一轮存在性校验：当前 50 个 A60 单设备路径全部存在。
- 已搭建轻量 Lineage workspace：`lineage_workspace/`，没有同步完整 Lineage 源码。
- 已拉取必要小仓库到轻量 workspace：`device/samsung/sm6150-common` 和 `tools/extract-utils`。
- 已把 TGY 固件解包为 extract-utils 可读取的 source 目录：`firmware/TGY_A6060ZHU3CXE1_extracted`。
- 已将 A60 抽取脚本升级到 `lineage-22.2` 使用的 Python extract-utils 风格，并保留 shell wrapper。
- 已用 TGY source 成功抽取 A60 单设备 vendor：`vendor/samsung/a60q`，50 个 blobs。
- 已用本地 A60 化 common 清单成功抽取 `vendor/samsung/sm6150-common`，782 个 blobs。
- 已生成 `patches/sm6150-common-a60q-proprietary-files.patch`，记录 A60 需要落到 common 仓库的 proprietary list 调整。
- 已将当前设备树和所需依赖仓库上传到 GitHub，并核验远端 `lineage-22.2` 分支存在。
- 已在 kernel 仓库中加入初始 `a60q_defconfig`；当前只是从 A70 defconfig 机械派生，尚未完成 A60 dtsi/dtbo 差异适配。

当前还没有开始完整 Lineage 源码环境内的 `lunch` / `mka bootimage` / `mka recoveryimage` 构建验证。

下一步重点：

- 继续做 A60 kernel 真适配：从 stock kernel/dtbo/TWRP prebuilt 反查 panel、touch、fingerprint、camera、battery/charger 差异。
- 决定 A60 与 common 同名音频 XML 的覆盖策略。
- 在准备好内核差异后，再进入完整 Lineage 源码环境执行 `lunch` / `mka bootimage` / `mka recoveryimage`。
- TGY 主线完成后，再回头做 CHC/TGY 差异复核。

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

## 云端仓库状态

当前已上传并核验的 `lineage-22.2` 仓库：

| 仓库 | 用途 | 已核验提交 |
| --- | --- | --- |
| `GalileoLion/device_samsung_a60q` | A60 设备树 | `74c1416d62e5ec05503dcc9f63e42803ad35b2bb` |
| `GalileoLion/android_device_samsung_sm6150-common` | A60 化 SM6150 common device tree | `19552849da5ce4282156083add020577c73f5955` |
| `GalileoLion/android_kernel_samsung_sm6150` | 初始 SM6150 kernel，含 `a60q_defconfig` | `2c66b7e4838fd5ed6760540da24666eec7e16726` |
| `GalileoLion/proprietary_vendor_samsung_a60q` | A60 单设备 vendor blobs | `b1120added02146f2dd4e70d695c7c6d57136546` |
| `GalileoLion/proprietary_vendor_samsung_sm6150-common` | A60 化 SM6150 common vendor blobs | `9317c3805edac47e95ff34b4a9260dbac6343b60` |

当前 `lineage.dependencies` 已声明：

```text
device/samsung/sm6150-common
kernel/samsung/sm6150
vendor/samsung/a60q
vendor/samsung/sm6150-common
```

注意：

- kernel 仓库为单提交导入版本，用于保证云端依赖完整；后续如果需要保留 A70 上游历史，可以另行重建带完整历史的分支。
- 当前云端依赖已经足够让源码树按仓库名拉取完整设备树/依赖文件，但还没有经过完整 Lineage 构建验证。

## 基础来源

主要参考这些上游仓库：

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

- 先以 TGY `A6060ZHU3CXE1` 作为当前主提取源，把 TGY 路线做完。
- CHC `A6060ZCS3CWE1` 已准备好，但暂时只作为后续复核来源，不阻塞当前工作。
- 暂缓 PIT、boot image、recovery image、dtbo、vendor image、stock fstab 和 vendor blobs 的 CHC/TGY 系统性 diff。
- TGY 完成后，再回头用 CHC 验证区域差异、底层镜像差异和 blob 是否需要替换。
- 三星 M40 最新 Android 11 固件仍作为第二对照源，用于同硬件近亲对照。

使用原则：

- 分区、fstab、boot header、dtbo、panel、touch、fingerprint、camera、audio 以实际镜像 diff 为准。
- CSC、RIL、modem、区域 feature 不从 M40 直接继承。
- M40 只能作为同平台/近似硬件参考，不能替代 A60 的设备身份、RIL、CSC 或 modem 相关配置。

当前阶段补充原则：

- TGY 未做完前，不再被 CHC 对比打断。
- 任何进入 `proprietary-files.txt` 的路径，先以 TGY 镜像存在性为最低验证标准。
- TGY 中不存在、但 common 清单要求的文件，必须明确记录，不静默沿用 A70 假设。

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

## 文件提取情况

### 固件包存放状态

当前固件包和设备树工作区位于三星固件分区：

```text
/run/media/kelon/三星固件/SM-A6060
```

TGY 固件目录：

```text
/run/media/kelon/三星固件/SM-A6060/TGY/A6060ZHU3CXE1
```

已存在文件：

- `AP_A6060ZHU3CXE1_CL22624812_QB80341403_REV00_user_low_ship_MULTI_CERT_meta_OS11.tar.md5`
- `BL_A6060ZHU3CXE1_CL22624812_QB80341403_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `CP_A6060ZHU3CXE1_CP26490412_CL22624812_QB80341403_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `CSC_OMC_TGY_A6060TGY3CXE1_CL22624812_QB80341403_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `HOME_CSC_OMC_TGY_A6060TGY3CXE1_CL22624812_QB80341403_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `FirmwareInfo.txt`

CHC 固件目录：

```text
/run/media/kelon/三星固件/SM-A6060/CHC/SM-A6060_3_20230526181531_j550velxsy_fac
```

已存在文件：

- `AP_A6060ZCS3CWE1_CL22624782_QB65535723_REV00_user_low_ship_MULTI_CERT_meta_OS11.tar.md5`
- `BL_A6060ZCS3CWE1_CL22624782_QB65535723_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `CP_A6060ZCS3CWE1_CP24263126_CL22624782_QB65535723_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `CSC_OMC_CHC_A6060CHC3CWE1_CL22624782_QB65535723_REV00_user_low_ship_MULTI_CERT.tar.md5`
- `HOME_CSC_OMC_CHC_A6060CHC3CWE1_CL22624782_QB65535723_REV00_user_low_ship_MULTI_CERT.tar.md5`

CHC 原始包：

```text
/run/media/kelon/三星固件/SM-A6060/CHC/SM-A6060_3_20230526181531_j550velxsy_fac.zip
/run/media/kelon/三星固件/SM-A6060/CHC/SM-A6060_3_20230526181531_j550velxsy_fac.zip.enc4
```

已验证：

- CHC `.zip` 通过 `unzip -t`。
- CHC 解压出的五个 `.tar.md5` 均通过 `tar -tf` 可读性检查。

### TGY 已提取内容

本地分析目录：

```text
firmware_analysis/TGY_A6060ZHU3CXE1
```

已提取镜像：

| 文件 | 状态 |
| --- | --- |
| `A60Q_CHN_HK.pit` | 已提取 |
| `boot.img` | 已提取 |
| `recovery.img` | 已提取 |
| `dtbo.img` | 已提取 |
| `vbmeta.img` | 已提取 |
| `vendor.img.ext4` | 已提取，Android sparse image |
| `vendor.raw.img` | 已由 `simg2img` 转换 |

已解包 boot/recovery：

| 目录 | 内容 |
| --- | --- |
| `unpacked_boot/` | `kernel`、空 `ramdisk` |
| `unpacked_recovery/` | `kernel`、`ramdisk`、`recovery_dtbo` |

已从 TGY vendor raw image 导出文本配置：

| 文件 | 用途 |
| --- | --- |
| `vendor_text/fstab.qcom` | 确认挂载点、文件系统、VOLD 节点 |
| `vendor_text/build.prop` | 确认 vendor fingerprint、产品名、RIL、LCD density |
| `vendor_text/default.prop` | 确认 VNDK、SIM 数、minui pixel format |
| `vendor_text/fingerprint.rc` | 确认 Samsung 指纹 HAL 启动方式 |
| `vendor_text/usb.rc` | 确认 USB HAL 和 type-c sysfs 权限 |
| `vendor_text/manifest.xml` | 确认 AOSP/Samsung HAL 声明 |

已从 TGY vendor raw image 额外导出音频/性能配置用于和 common 对比：

- `vendor_text/audio/mixer_paths_idp.xml`
- `vendor_text/audio/SoundBoosterParam.txt`
- `vendor_text/audio/audio_platform_info.xml`
- `vendor_text/audio/audio_platform_info_diff.xml`
- `vendor_text/audio/audio_platform_info_intcodec.xml`
- `vendor_text/audio/audio_platform_info_qrd.xml`
- `vendor_text/audio/audio_policy_configuration.xml`
- `vendor_text/audio/audio_policy_configuration_base.xml`
- `vendor_text/audio/media_profiles_vendor.xml`
- `vendor_text/audio/powerhint.xml`
- `vendor_text/audio/thermal-engine.conf`

### CHC 已提取内容

本地分析目录：

```text
firmware_analysis/CHC_A6060ZCS3CWE1
```

当前只完成了第一步提取：

| 文件 | 状态 |
| --- | --- |
| `boot.img` | 已提取 |
| `unpacked_boot/kernel` | 已解包 |
| `unpacked_boot/ramdisk` | 已解包，大小为 0 |

已确认 CHC boot image：

- boot image header version：`1`。
- page size：`4096`。
- product name / `BOARD_NAME`：`RILRL28A003`。
- cmdline 与 TGY 基本一致。
- os patch level：`2023-03`。
- kernel 与 TGY 不同，大小和 hash 均不同。

CHC 仍未提取：

- `A60Q_CHN_OPEN.pit`
- `recovery.img`
- `dtbo.img`
- `vbmeta.img`
- `vendor.img.ext4`
- `vendor.raw.img`
- CHC vendor text configs

### 当前 proprietary-files.txt 状态

当前 `proprietary-files.txt` 是初始 A60 单设备 blobs 清单，来源依据为 TGY `vendor.img`。

已纳入类别：

- Samsung camera provider。
- A60 camera sensor module / tuning。
- 后置 Egis/Samsung 指纹 HAL。
- A60 专用音频路径和扬声器调校：
  - `vendor/etc/mixer_paths_idp.xml`
  - `vendor/etc/SoundBoosterParam.txt`
- 设备调校固件：
  - `vendor/firmware/CAMERA_ICP.elf`
  - `vendor/firmware/Tfa9xxx.cnt`
  - `vendor/firmware/dax_param.bin`

已验证：当前清单中的路径均存在于 TGY `vendor.raw.img`。

尚未完成：

- 还没有完成 A60 kernel 的真实硬件差异适配；当前 `a60q_defconfig` 只是初始占位。
- 还没有决定同名但与 common 有差异的音频 XML 是否需要设备侧覆盖。
- 还没有开始 `bootimage` / `recoveryimage` 构建验证。

### 轻量 Lineage workspace

为避免同步完整 Lineage 源码，当前只在本仓库下建立了轻量 workspace：

```text
lineage_workspace/
```

该目录已由 `.gitignore` 排除，不提交到设备树仓库。

当前包含：

- `device/samsung/a60q`：指向当前设备树的符号链接。
- `device/samsung/sm6150-common`：从 `a70q-lineage/android_device_samsung_sm6150-common` 的 `lineage-22.2` 分支浅克隆。
- `tools/extract-utils`：从 LineageOS `android_tools_extract-utils` 的 `lineage-22.2` 分支浅克隆。
- `prebuilts/`：只放了 `extract-utils` 本次需要的 `patchelf` / `llvm-objdump` / `llvm-strip` 本机工具符号链接，不是完整 Lineage prebuilts。
- `vendor/samsung/a60q`：已从 TGY source 成功生成，50 个 blobs。
- `vendor/samsung/sm6150-common`：已在本地 A60 化 common 清单后成功生成，782 个 blobs。
- `/tmp/a60q_kernel_import`：kernel 单提交导入仓库，已推送到 `GalileoLion/android_kernel_samsung_sm6150`。

TGY source 目录：

```text
firmware/TGY_A6060ZHU3CXE1_extracted
```

该目录也已由 `.gitignore` 排除，不提交到设备树仓库。

当前 source 内容：

- `vendor/`：从 TGY `vendor.raw.img` 完整导出。
- `product/`：从 TGY `product.img` 导出。
- `system/`、`system_ext/`、`bin/`、`lib64/`：按 common 清单需要导出的 system 侧文件。

已验证命令：

```bash
PYTHONPATH=/home/kelon/MakeFun/a6060_device_tree/lineage_workspace/tools/extract-utils \
python3 ./extract-files.py /home/kelon/MakeFun/a6060_device_tree/firmware/TGY_A6060ZHU3CXE1_extracted
```

执行位置：

```text
lineage_workspace/device/samsung/a60q
```

结果：

- A60 单设备 vendor 抽取成功。
- SM6150 common vendor 在套用 `patches/sm6150-common-a60q-proprietary-files.patch` 后抽取成功。
- A60 单设备 vendor、SM6150 common vendor、SM6150 common device 和 kernel 均已上传到 GitHub。

### TGY proprietary list 覆盖检查

已用 TGY `vendor.raw.img` 对当前清单做存在性检查。

A60 单设备清单：

- `proprietary-files.txt` 当前共有 50 个有效路径。
- 50 个路径全部存在于 TGY `vendor.raw.img`。
- 当前没有 A60 单设备清单缺失项。

SM6150 common 清单历史检查：

- common `proprietary-files.txt` 当前共有 772 个有效路径。
- 其中 755 个 `vendor/` 路径存在于 TGY `vendor.raw.img`。
- 其中 4 个 `vendor/` 路径在 TGY `vendor.raw.img` 中缺失。
- 其中 13 个非 `vendor/` 路径已经从 TGY `system.img` / `product.img` 确认完毕。
- 13 个非 `vendor/` 路径全部存在于 TGY `system.img`。
- TGY `product.img` 没有提供这些 common 非 `vendor/` 路径。

TGY vendor 中缺失的 common vendor 项：

```text
vendor/lib/lib_SamsungRec_07002.so
vendor/etc/plmn_delta.bin
vendor/etc/plmn_delta_attaio.bin
vendor/etc/plmn_delta_usagsm.bin
```

已观察到 TGY vendor 中存在相近但不同的文件：

```text
vendor/lib/lib_SamsungRec_07001.so
vendor/etc/plmn_delta_hktw.bin
```

这些差异不能直接猜测替换规则，后续需要确认 common 是否应该条件化，或 A60 是否需要单设备覆盖/排除。

已从 TGY `system.img` 确认存在的 common 非 vendor 项：

```text
system_ext/etc/permissions/audiosphere.xml
system_ext/framework/audiosphere.jar
system_ext/lib/fm_helium.so
system_ext/lib/libfm-hci.so
system_ext/lib/vendor.qti.hardware.fm@1.0.so
system_ext/lib64/fm_helium.so
system_ext/lib64/libfm-hci.so
system_ext/lib64/vendor.qti.hardware.fm@1.0.so
bin/lpm
lib64/libmaet.so
lib64/libsxqk_skia.so
system_ext/lib/vendor.qti.hardware.qdutils_disp@1.0.so
system_ext/lib64/vendor.qti.hardware.qdutils_disp@1.0.so
```

当前 common 抽取验证结论：

- A60 单设备 `proprietary-files.txt` 当前没有缺失项，已成功生成 `vendor/samsung/a60q`。
- 当前 `lineage-22.2` 的 `sm6150-common` 原始清单不能直接用于 A60 TGY。
- 原始 common 清单缺失项实际包括 A70 前摄、A70 光/距离传感器和部分区域 plmn 文件，不只是早期旧报告记录的 4 个。
- 本地验证通过的处理方式已经记录为 `patches/sm6150-common-a60q-proprietary-files.patch`：
  - `vendor/lib/lib_SamsungRec_07002.so` 替换为 TGY 存在的 `vendor/lib/lib_SamsungRec_07001.so`。
  - 删除 TGY 不存在的 `plmn_delta.bin`、`plmn_delta_attaio.bin`、`plmn_delta_usagsm.bin`，保留 `plmn_delta_hktw.bin` 和 locale plmn 文件。
  - 删除 A70 前摄 `s5kgd1_front` 相关条目；A60 相机 sensor/tuning 已在 A60 单设备清单中处理。
  - 删除 TGY 不存在的 `talos_stk3x3x_0.json` 和 `talos_tcs3407_0.json`。
- 套用上述补丁后，SM6150 common vendor 已从 TGY source 成功生成。
- 临时转换出的 `system.img` / `product.img` 大镜像已经清理，不保留在仓库工作区。

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

当前云端源码：

```text
kernel/samsung/sm6150
```

已创建：

```text
arch/arm64/configs/a60q_defconfig
```

当前状态：

- `a60q_defconfig` 已存在于 `GalileoLion/android_kernel_samsung_sm6150` 的 `lineage-22.2` 分支。
- 该 defconfig 目前从 `a70q_defconfig` 机械派生，只用于让设备树依赖可解析。
- kernel 仓库为单提交导入版本，后续如需保留 A70 上游历史，可以重建带历史分支。

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

继续按 TGY 路线推进：

- 对比 A60 stock kernel/dtbo、TWRP prebuilt 和当前 kernel tree，补 A60 panel/touch/fingerprint/camera/battery/charger 相关 dtsi/defconfig 差异。
- 处理 A60 stock 与 common 同名音频 XML 差异，决定是否做设备侧覆盖。
- 在完整 Lineage 源码树中拉取当前五个 `GalileoLion/*` 仓库后，执行 `lunch lineage_a60q-userdebug`。
- 首轮构建目标仍然是 `mka bootimage` 和 `mka recoveryimage`，暂不直接追求整包。
- TGY 构建路径跑通后，再回头用 CHC 固件做底层差异复核。

每个设备专有值都需要和以下来源交叉核对：

- 已有 A60 TWRP 树
- A60 stock 固件
- A60 boot/recovery image
- A60 vendor image
- A60 PIT / partition table
