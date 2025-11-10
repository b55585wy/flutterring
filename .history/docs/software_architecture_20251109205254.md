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
- **Infrastructure**：平台通道、原生 BLE 服务、持久化（SharedPreferences / DB）、网络、日志等。

### 2.1.1 Flutter 目录映射（2025-11-03 更新）

```
lib/
├─ presentation/        # Flutter UI 层（dashboard, measurement, history, settings）
├─ application/         # 控制器 / UseCase（待补充）
├─ domain/
│   └─ models/          # Freezed 数据模型：BleEvent、DeviceInfo、Sample...
└─ infrastructure/
    └─ platform/        # 平台通道接口：RingPlatform
```

#### 当前控制器与接入范围

- `application/controllers/ble_scan_controller.dart` → 仪表盘扫描弹窗、连接入口已接入。
- `application/controllers/device_connection_controller.dart` → 仪表盘状态卡、设置页已接入。
- `application/controllers/measurement_controller.dart`、`settings_controller.dart` → 规划中，将在后续迭代驱动测量页和高级设置。

> M1 状态：仪表盘与设置页已经迁移到 Riverpod 架构，测量/历史页面仍使用旧逻辑，计划在后续里程碑推进。

### 2.1.2 M1 Scope 摘要（2025-11-03）

- 已完成：
  - Flutter 目录重构为 Presentation/Application/Domain/Infrastructure 四层。
  - `BleScanController`、`DeviceConnectionController` 实现并接入 Dashboard、Settings。
  - 仪表盘扫描弹窗、连接状态卡改用 Riverpod 状态；Settings 页重写为 `ConsumerWidget`。
  - 事件流广播单例化、自动化测试落地（事件流 + 控制器单测）。
- 待补充：
  - `MeasurementPage`、`HistoryPage` 迁移到新控制器。
  - 统一日志/调试输出来替换调试 `print`。
  - 真机 QA（扫描→连接→断开）已验证，仍需完善会议纪要与后续文档。

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

```
```