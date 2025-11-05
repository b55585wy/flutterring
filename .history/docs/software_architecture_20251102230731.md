---
title: OpenRing 软件架构设计文档
created: 2025-11-02
status: draft
---

# 1. 概述

OpenRing 面向可穿戴戒指设备，目标是在保持现有 Flutter UI 风格的同时，重构 APP 与原生 BLE 模块之间的技术架构，解决事件流不稳定、模块职责不清、排查困难等问题。本设计文档用于作为未来开发与维护的唯一事实来源。

## 1.1 范围

- Flutter 客户端（UI、状态管理、业务逻辑）
- Android 原生层（BLEService、MainActivity、平台通道）
- 设备交互：扫描、连接、测量、离线数据、设置
- 日志、监控、测试与交付流程

不包含：云端服务、iOS 端、硬件固件实现。

## 1.2 目标

1. 建立清晰的分层结构，严格区分 UI、业务逻辑、领域模型与基础设施。
2. 统一 BLE 事件流，实现可广播、可复用的数据通道。
3. 明确主要业务流程与状态机，减少隐含依赖。
4. 提供详尽的架构图、数据流图、时序图、状态图，方便跨团队沟通。
5. 制定开发规范与交付里程碑，支持持续迭代。

## 1.3 当前痛点

- 多页面重复订阅 EventChannel，导致原生 `eventSink` 被覆盖，事件丢失。
- 控制器、状态、平台调用混杂在 UI 中，职责不清。
- 日志零散，缺乏统一格式与 Trace ID。
- 无配置化、模块化文档，团队成员难以快速上手。


# 2. 架构设计

## 2.1 分层架构概览

```text
+---------------------------+-------------------------------+
|          Presentation      |  Flutter UI Widgets           |
|---------------------------+-------------------------------|
|      ViewModel / UseCase   |  Riverpod StateNotifier /    |
|                            |  Controllers                  |
|---------------------------+-------------------------------|
|           Domain           |  Models, Value Objects,      |
|                            |  Business Rules               |
|---------------------------+-------------------------------|
|        Infrastructure      |  RingPlatform (Flutter)      |
|                            |  BLEService, MainActivity    |
|                            |  Persistence, Logging         |
+-----------------------------------------------------------+
```

- **Presentation**：纯 UI 层。通过 Riverpod Provider 获取 ViewModel 状态，不直接调用平台方法。
- **ViewModel/UseCase**：封装业务流程。例如 `BleScanController`、`DeviceConnectionController`、`MeasurementController`、`SettingsController`。
- **Domain**：领域模型、事件、状态机，使用 Freezed 定义不可变数据。
- **Infrastructure**：平台通道、原生 BLE 服务、持久化（SharedPreferences / DB）、网络、日志等。

## 2.2 模块划分

| 模块 | 职责 | 主要接口 |
|------|------|---------|
| `ble_scan` | 触发扫描、过滤设备、缓存结果、暴露 `Stream<List<BleDevice>>` | `startScan()`, `stopScan()`, `scannedDevicesProvider` |
| `device_connection` | 连接状态管理、重连策略、电量/信息同步、事件通知 | `connect(address)`, `disconnect()`, `connectionStateProvider` |
| `measurement` | 在线测量控制、样本处理、信号质量判定 | `startLiveMeasurement(duration)`, `stop()`, `measurementStateProvider` |
| `data_sync` | 离线录制文件列表、下载删除、时间同步 | `fetchFileList()`, `downloadFile(name)`, `syncTime()` |
| `settings` | 权限管理、用户偏好、设备历史 | `requestPermissions()`, `getConnectedDevice()`, `settingsProvider` |

ViewModel 与模块间通过 `ServiceLocator` 或 `Provider` 注入依赖。

## 2.3 技术栈与库

- **UI**：Flutter 3.x，Material 3，自适配现有 UI。
- **状态管理**：Riverpod 2/3 + StateNotifier + AsyncValue。
- **数据模型**：Freezed + json_serializable。
- **原生层**：Kotlin + Android BLE API + ForegroundService + LocalBroadcastManager。
- **持久化**：SharedPreferences（轻量）、后续可接入 Hive/Drift。
- **日志**：Flutter `logger` 包；原生使用 `Timber`；统一格式 `[module][level] message`，增加 traceId。
- **构建**：Flutter build flavors（dev/qa/prod）、GitHub Actions、dart analyze、lint。
- **测试**：单元测试（ViewModel/Domain）、集成测试（平台通道 mock）、原生单元测试（Robolectric/Instrumented）。


# 3. 核心流程设计

## 3.1 BLE 事件流（数据流图）

```text
[BLE Adapter]
   ↓  (deviceFound)
[MainActivity.sendEvent]
   ↓
[EventChannel -> receiveBroadcastStream]
   ↓ (RingPlatform._cachedEventStream)
[Application Controllers] --broadcast--> [UI Providers]
```

- `RingPlatform.eventStream` 实现为单例广播流：
  ```dart
  static final _cachedEventStream =
      _eventChannel.receiveBroadcastStream().map(_mapEvent).asBroadcastStream();
  ```
- 每个 Controller 通过 `ref.listen` 或 `StreamProvider` 订阅，无需担心事件冲突。

## 3.2 扫描流程时序图

```text
User -> DashboardPage -> BleScanController.startScan()
    -> PermissionService.request()
    -> RingPlatform.scanDevices()
    -> MainActivity.scanDevices()
    -> BLEService.startLeScan()
    -> sendEvent(deviceFound)
    -> RingPlatform.eventStream
    -> BleScanController.onDeviceFound()
    -> update scannedDevicesProvider
    -> Dashboard UI rebuild
```

- 扫描超时 15s 自动 `stopScan()` 并发送 `scanCompleted`。
- 去重逻辑在 Controller 层维护缓存，而不是直接操作 UI 层状态。

## 3.3 连接流程状态图

```
Disconnected → Connecting → Connected → Disconnecting
   ↑                ↓             ↓
   └───────────────┴─────────────┘
```

- **事件触发**：
  - `connect(address)` → `Connecting`
  - 原生成功回调 → `Connected`
  - 原生失败/超时 → `Disconnected` + 错误提示
  - 用户断开 → `Disconnecting` → `Disconnected`
- 状态变更通过 `DeviceConnectionState`（Freezed）表达，包含 `state`, `device`, `lastError`。

## 3.4 测量流程

1. Controller 检查连接状态；未连接则提示。
2. 调用 `RingPlatform.startLiveMeasurement(duration)`。
3. 原生解析数据包 → `sampleBatch` 事件。
4. Controller 聚合样本，更新实时波形和统计指标。
5. `vitalSignsUpdate` 用于更新 HR、RR、质量。
6. `scanCompleted` 或断连时，自动结束测量。

数据结构：

```dart
@freezed
class MeasurementState with _$MeasurementState {
  const factory MeasurementState({
    required bool isRecording,
    required List<int> ppgGreen,
    required int heartRate,
    required int respiratoryRate,
    required SignalQuality quality,
    String? error,
  }) = _MeasurementState;
}
```

## 3.5 设置与持久化

- `SettingsController` 负责：
  - 恢复上次连接设备（SharedPreferences: `last_device_address/name`）。
  - 请求与缓存权限状态。
  - 触发时间同步、固件信息获取（后续扩展）。


# 4. 原生层设计

## 4.1 MainActivity

- 维护单例 `eventSink`，禁止重复赋值。
- 结构：`scanDevices()`, `connectDevice()`, `disconnectDevice()`, `syncConnectionState()`, `emitConnectionEvent()`。
- 使用 `Handler` 将所有 BLE 回调切回主线程。
- 与 Flutter 通讯只通过 `RingPlatform` 定义的事件/方法，禁止直接访问 UI。

## 4.2 BLEService

- 负责具体 BLE GATT 交互、数据解析、广播。
- 通过 `LocalBroadcastManager` 向 `MainActivity` 发送状态码；建议未来改为 `Messenger` 或 `ForegroundService` 通道，以减少耦合。
- 需要补充：
  - 连接超时/重试策略
  - 后台运行 + 通知
  - 断线重连

## 4.3 安全与性能

- 权限：`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `ACCESS_FINE_LOCATION`；Android 13+ 需额外适配。
- 电量优化：扫描采用 15s 超时；测量时保持前台服务。
- 错误码与日志：所有 `result.error` 统一为 `code` + `message`。


# 5. 日志与监控

## 5.1 Flutter 日志规范

- 统一使用 `logger` 封装：`log.d('[BleScan] start scan')`。
- 提供 `LogTag` 枚举：`ble`, `connection`, `measurement`, `settings`, `ui`。
- 重要事件记录 traceId（例如 `scanId`）。

## 5.2 原生日志

- 使用 `Timber.tag("OpenRing")`。
- 和 Flutter 日志保持一致的前缀。
- 将 `sendEvent` 成功/失败记录为 `debug`/`error`。

## 5.3 监控建议

- 集成 Firebase Crashlytics。
- 关键指标：连接成功率、测量成功率、扫描时长、异常次数。


# 6. 测试策略

| 类型 | 目标 | 工具 |
|------|------|------|
| 单元测试 | ViewModel、Controller、Domain | `flutter test`, Mockito |
| 集成测试 | 平台通道模拟、UI 行为 | `integration_test`, `flutter_driver` 替代 |
| 原生单测 | BLEService 逻辑 | Robolectric、Junit |
| 手动测试 | 真机扫描、连接、测量 | QA checklist |


# 7. DevOps 流程

1. **Git Flow**：`main` + `develop` + feature branches；提交遵循 Conventional Commits。
2. **CI**：GitHub Actions 运行 `flutter analyze`, `flutter test`, `build apk`。
3. **版本管理**：语义化版本；`pubspec.yaml` 与 Android `versionCode` 同步。
4. **发布**：QA/灰度/正式三阶段；使用 Firebase App Distribution 或内部渠道。


# 8. 里程碑计划

## M1 架构基线

- 建立各层目录结构：`lib/presentation`, `lib/application`, `lib/domain`, `lib/infrastructure`。
- 改造 `RingPlatform.eventStream` 广播单例。
- 初步拆分 Controller，重构扫描流程。
- 输出 API 参考与编码规范文档。

## M2 BLE 核心重构

- 实现 `BleScanController`、`DeviceConnectionController`。
- 统一连接状态管理，提供重连策略。
- UI 通过 Provider 获取状态；移除直接平台调用。
- 增加单元测试覆盖。

## M3 测量与数据持久化

- 完成 `MeasurementController`、实时波形数据结构。
- 保存测量样本/摘要到本地 DB。
- 离线文件列表/下载流程搬迁。

## M4 运维与质量

- 集成日志封装、Crashlytics、性能分析。
- 搭建 GitHub Actions CI/CD。
- 制定 QA 测试用例和验收标准。

## M5 文档与交接

- 完成所有模块的 API 文档、序列图、部署指南。
- 编写常见问题、调试手册（含 BLE 排查）。
- 准备最终演示与培训资料。


# 9. 后续工作

- 根据本设计将现有代码迁移至新结构。
- 每完成一个里程碑进行回归测试与文档同步更新。
- 针对尚未确定的功能（如云同步）预留扩展接口。

> 如需查看原生事件流或 Flutter 状态更新，可参考 `docs/debugging.md`（待补充）中的排查步骤。


