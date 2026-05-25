# Codex 工作区与对话摘要

本文记录本次 Codex 协作中已经确认的设备树开发状态、关键决策和下一步。

注意：这里是脱敏摘要，不是原始逐字聊天记录。原始对话中包含只允许在本次聊天中使用的敏感信息，因此不会写入仓库。

## 工作区位置

当前本地工作区：

```text
/run/media/kelon/三星固件/SM-A6060/a6060_device_tree
```

固件目录：

```text
/run/media/kelon/三星固件/SM-A6060/TGY/A6060ZHU3CXE1
/run/media/kelon/三星固件/SM-A6060/CHC/SM-A6060_3_20230526181531_j550velxsy_fac
```

本地分析产物目录：

```text
firmware_analysis/
```

该目录已被 `.gitignore` 排除，不提交大镜像和中间产物。

## 当前 Git 状态

目标仓库：

```text
https://github.com/GalileoLion/device_samsung_a60q
```

当前分支：

```text
lineage-22.2
```

最近已推送提交：

```text
f2c2986 Update A60 bring-up from stock firmware
```

## 关键决策

- 起始分支使用 `lineage-22.2`。
- 设备树主基础使用 A70/SM6150 生态，但 A60 专有值必须从 A60 固件、TWRP 树或真机信息确认。
- 已有 TWRP 树只作为参考，不作为完整 ROM 设备树主基础。
- A60 stock 是非动态分区路线，当前明确设置 `TARGET_USE_DYNAMIC_PARTITIONS := false`。
- TGY `A6060ZHU3CXE1` 先作为已分析固件来源；CHC `A6060ZCS3CWE1` 已准备好继续对照。
- TGY 的 `CXE1` 更新被视为 One UI 稳定性维护更新，不能只因版本号更新就自动优先。

## 已确认并落入设备树的内容

- `BOARD_NAME := RILRL28A003`，来自 TGY stock boot/recovery image header。
- boot image header version：`1`。
- page size：`4096`。
- kernel offset：`0x00008000`。
- ramdisk offset：`0x02000000`。
- tags offset：`0x01e00000`。
- stock cmdline 与 SM6150 common 基本一致。
- A60 recovery pixel format：`RGBX_8888`。
- A60 显示尺寸：`1080 x 2340`。
- 已覆盖 A70/common UDFPS 相关配置，避免屏下指纹逻辑泄漏到 A60。

## 分区与 fstab

已从 TGY `A60Q_CHN_HK.pit` 确认并覆盖关键分区尺寸：

| 分区 | 大小 |
| --- | ---: |
| `boot` | `67108864` |
| `recovery` | `72744960` |
| `dtbo` | `8388608` |
| `system` | `5830082560` |
| `vendor` | `1090519040` |
| `cache` | `629145600` |

已新增：

```text
rootdir/vendor/etc/fstab.qcom
```

并用于：

- `TARGET_RECOVERY_FSTAB`
- vendor 镜像中的 `$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom`

已确认 A60 stock fstab 中：

- `/data` 是 `ext4`。
- `efs` 挂载到 `/mnt/vendor/efs`。
- `sec_efs` 挂载到 `/efs`。
- `apnhlos` 挂载到 `/vendor/firmware_mnt`。
- `modem` 挂载到 `/vendor/firmware-modem`。
- `dsp` 挂载到 `/vendor/dsp`。

## Vendor blobs 进度

已建立初始 `proprietary-files.txt`，当前只包含已从 TGY vendor 镜像核实存在、且更偏 A60 专有的内容：

- Samsung camera provider。
- A60 camera sensor module / tuning：`gc5035`、`s5k3p8sp`、`s5k4ha`、`s5kgd1`。
- 后置 Egis/Samsung 指纹 HAL。
- `mixer_paths_idp.xml`。
- `SoundBoosterParam.txt`。
- `CAMERA_ICP.elf`、`Tfa9xxx.cnt`、`dax_param.bin`。

已用 `debugfs stat` 验证当前清单路径都存在于 TGY `vendor.img`。

## 固件状态

TGY：

- `A6060ZHU3CXE1` 已提取 boot/recovery/dtbo/vbmeta/PIT/vendor。
- vendor sparse image 已转换为 raw image 并导出部分文本配置。

CHC：

- `SM-A6060_3_20230526181531_j550velxsy_fac.zip.enc4` 已完整解密为 `.zip`。
- `.zip` 通过 `unzip -t`。
- 解压出的 AP/BL/CP/CSC/HOME_CSC `.tar.md5` 均通过 `tar -tf` 可读性检查。
- 已开始提取 CHC boot image，后续需要继续提取 recovery/dtbo/vbmeta/PIT/vendor 做差异对比。

## 尚未完成

- 还没有在完整 Lineage 源码树内运行 `lunch lineage_a60q-userdebug`。
- 还没有构建 `bootimage` / `recoveryimage`。
- 还没有生成并验证 `vendor/samsung/a60q`。
- 还没有完成 CHC/TGY 的底层镜像 diff。
- 还没有创建或验证 `a60q_defconfig`。
- 还没有做真机启动、`dmesg`、`logcat`、SELinux 修复。

## 下一步

1. 继续提取 CHC 的 recovery/dtbo/vbmeta/PIT/vendor。
2. 对比 CHC 与 TGY 的 PIT、boot header、dtbo、vendor fstab、vendor blobs。
3. 根据差异决定最终 vendor blob 主来源。
4. 在完整 Lineage 源码树中抽取 vendor blobs。
5. 准备内核 defconfig 与 dtbo 对照。
6. 开始 `mka bootimage` 和 `mka recoveryimage`。
