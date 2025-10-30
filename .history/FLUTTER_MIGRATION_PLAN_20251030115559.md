## 目标

- **目的**: 将现有 Android 原生应用（Java/Kotlin + XML）重构为 Flutter 跨平台应用，在保证 BLE 功能、实时绘图、通知、离线文件与设置管理等能力的前提下，获得更快的 UI 迭代与多端可移植性。
- **范围**: 迁移 UI、业务逻辑与大部分数据层；保留/封装现有关键原生能力（如现有 `.aar` 库与 BLE 栈）通过 Platform Channel 暂存，并逐步替换为纯 Dart 方案（若可行）。

## 现状梳理（主要模块）

- 原生页面与视图
  - `activity_main.xml` → 主界面（底部导航、设备列表/连接、绘图区、状态区）
  - `activity_ring_settings.xml` → 设置界面（设备参数、采样配置）
  - 自定义视图：`PlotView.java`
- 原生逻辑/服务
  - `utils/BLEService.java` → 扫描、连接、订阅、数据收发
  - `utils/VitalSignsProcessor.java` → 生理信号处理（滤波/特征/HR/SpO2/呼吸）
  - `utils/NotificationHandler.java` → 系统通知与前台服务
- 适配器/列表
  - `RingAdapter.java` → 设备/记录列表适配
- 原生依赖
  - `app/libs/ChipletRing1.0.81.aar`（专有库）

## 目标架构（Flutter）

- UI 层: Flutter Widgets（Material 3）
  - 路由与导航：`go_router`
  - 状态管理：`Riverpod`（或 `Bloc`，二选一，本文以 Riverpod 为主）
  - 主题与暗色模式：`ThemeData` + 自定义 `ColorScheme`
- 业务与数据层
  - 数据源：Platform Channel（Android 原生 BLE 与 AAR）→ Repository → ViewModel(Notifier)
  - 算法迁移：将 `VitalSignsProcessor` 迁移到 Dart；若性能瓶颈，使用 Isolate 或 `dart:ffi`/Native layer
- 原生桥接
  - Android：`MethodChannel`/`EventChannel` 封装 `BLEService` 和 `.aar` 能力
  - iOS（后续）：对齐接口但可延迟实现
- 实时绘图
  - Flutter 图表：`fl_chart` 或自绘 `CustomPainter`（高频率更新建议自绘 + downsampling）
- 本地存储
  - 偏好：`shared_preferences`
  - 文件：`path_provider` + 本地 CSV/二进制
  - 序列化：`json_serializable`
- 后台与通知
  - 后台任务：`workmanager`（Android）
  - 前台服务/通知：原生层保留，由 Channel 控制开关

## 技术选型（建议）

- Flutter SDK: 3.24.x（Dart 3.x）
- 主要依赖（pubspec）
  - 路由：`go_router`
  - 状态：`flutter_riverpod`
  - BLE：阶段一用原生桥接；阶段二可评估 `flutter_blue_plus`
  - 权限：`permission_handler`
  - 绘图：`fl_chart`（或自绘）
  - 存储：`shared_preferences`、`path_provider`
  - 后台：`workmanager`
  - 序列化与工具：`freezed`、`json_serializable`、`build_runner`

## 功能映射与页面结构

- 页面映射
  - `MainPage`（原 `MainActivity`）
    - 底部导航：设备/实时/记录/设置
    - 设备页：扫描、连接、状态（原 `RingAdapter` 逻辑 → Flutter ListView + 状态）
    - 实时页：绘图（原 `PlotView` → `CustomPainter`/`fl_chart`）
    - 记录页：本地文件列表、导出
  - `SettingsPage`（原 `RingSettingsActivity`）
    - 设备参数/采样率/功耗策略
- 数据流
  - 原生 Event → `EventChannel`（如心率、SpO2、波形）→ Repository → Riverpod Provider → UI
  - 设置与命令：Flutter → `MethodChannel` → 原生（连接、订阅、参数下发）

## 平台桥接设计（Android）

- Channel 约定
  - `MethodChannel("ring/native")`
    - `requestPermissions()`、`scan(start|stop)`、`connect(deviceId)`、`disconnect()`
    - `startStream(types)`、`stopStream()`、`setSettings(map)`、`getBattery()`
  - `EventChannel("ring/events")`
    - 事件：`connection`、`scanResult`、`telemetry`（波形/HR/SpO2/Resp）
- `.aar` 集成（Android）
  - 位置：`android/app/libs/ChipletRing1.0.81.aar`
  - `android/app/build.gradle` 中加入：

```gradle
repositories { flatDir { dirs 'libs' } }
dependencies { implementation(name: 'ChipletRing1.0.81', ext: 'aar') }
```

- 原生层职责
  - 统一封装 BLE 与 `.aar` 能力并暴露稳定 API
  - 管理前台服务与通知；在 Android 14+ 适配 `POST_NOTIFICATIONS`、蓝牙/定位权限
  - 将高频数据通过 `EventChannel` 流式下发，必要时在原生层做节流/打包

## 算法迁移（`VitalSignsProcessor`）

- 阶段一：保持现状（原生处理 → 事件流）
  - 快速上线，降低迁移风险
- 阶段二：Dart 迁移
  - 将核心滤波、峰值检测、HR/SpO2/Resp 逻辑迁移到 Dart
  - 性能策略：
    - 高频计算移至 Isolate；UI 线程仅做渲染
    - 采用批处理（帧/窗口）与降采样可视化

## 工程结构（建议）

```text
lib/
  main.dart
  app/
    router.dart
    theme.dart
  features/
    device/
      data/ (repo, models)
      logic/ (providers, usecases)
      ui/ (pages, widgets)
    realtime/
      ...
    settings/
      ...
  common/
    widgets/
    utils/
platform/
  android/ (MethodChannel + AAR 封装)
```

## 迁移策略与里程碑

1. 准备（0.5 周）
   - 搭建 Flutter 工程、代码规范、CI（格式化/分析）
   - 创建 Platform Channel 骨架
2. 最小可用（1 周）
   - 设备扫描/连接（原生桥）
   - 实时数据事件通路（原生 → Flutter UI 简单绘制）
   - 设置/参数下发
3. 功能完善（1.5 周）
   - 完整实时绘图（性能优化、降采样）
   - 记录页（文件落盘/导出）
   - 通知与前台服务控制
4. 算法迁移与优化（1 周）
   - 将关键算法迁至 Dart + Isolate
   - 与原生结果对齐测试
5. 收尾与发布（0.5 周）
   - 真机稳定性测试、权限与机型兼容
   - 文档与交付

预计总计：~4.5 周（并行推进可缩短）

## 风险与对策

- Android 14+ 权限与后台限制：完善前台服务与通知策略
- 高频数据导致 UI 卡顿：数据节流、批量刷新、自绘 + Isolate
- `.aar` 版权/接口不透明：完善封装与异常兜底；记录接口契约
- iOS 适配：短期内先保证 Android；桥接接口预留一致签名

## 验收标准

- 扫描/连接/数据订阅全链路可用，断连重试可靠
- 实时绘图 60 FPS（或稳定 >= 30 FPS），无明显丢帧
- 算法 Dart 版结果与原生对齐（误差阈值可配）
- 权限与通知在 Android 12–14+ 全面通过
- 核心路径具备单元/集成测试；主要页面通过金标测试

## 实施清单（Checklist）

- 初始化 Flutter 工程与依赖
- 接入 `.aar` 并完成 MethodChannel/EventChannel
- 完成设备页、实时页、设置页 UI 骨架
- 打通扫描/连接/事件流与简单绘图
- 文件与偏好存储
- 前台服务/通知控制
- Dart 算法迁移 + 性能优化
- 测试、文档与发布

## Platform Channel API 草案

```dart
// Dart 侧（示意）
final method = const MethodChannel('ring/native');
final events = const EventChannel('ring/events');

Future<void> connect(String id) => method.invokeMethod('connect', {'id': id});
Stream<dynamic> telemetryStream() => events.receiveBroadcastStream();
```

```kotlin
// Android 侧（示意）
class RingChannelPlugin: FlutterPlugin, MethodCallHandler, StreamHandler {
  // setup channel, handle connect/scan/startStream/stopStream 等
}
```

## 后续（可选）

- 评估将 BLE 全量迁至 `flutter_blue_plus`，减少原生复杂度
- 增加多语言与无障碍支持
- 引入 crash 与性能监控（如 Sentry/Firebase）


