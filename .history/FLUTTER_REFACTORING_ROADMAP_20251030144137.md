# OpenRing Flutter 重构路线图

## 项目概述

**目标**: 将现有 Android 原生应用（Java + XML）重构为 Flutter 跨平台应用，实现：
- ✅ 跨平台支持（Android/iOS/未来 Web）
- ✅ 统一在线/离线测量流程
- ✅ 现代化 UI/UX
- ✅ 保留现有 AAR 库能力（通过 Platform Channel）

**现有功能清单**:
- 蓝牙设备扫描与连接
- 实时测量（在线模式，手机持续连接）
- 离线采集（戒指断连后自主记录，事后下载）
- 生理信号处理（HR/RR 计算）
- 实时波形绘制（12 通道：PPG×3, ACC×3, Gyro×3, Temp×3）
- 文件管理（列表、下载、回放）
- 设备时间同步与校准

---

## 技术栈选择

### Flutter 生态
- **Flutter SDK**: 3.24.x (Dart 3.5.x)
- **状态管理**: Riverpod 2.5+ (推荐) 或 Bloc 8.x
- **路由**: go_router 14.x
- **本地存储**: shared_preferences + sqflite
- **序列化**: freezed + json_serializable

### 核心插件
| 功能 | 插件 | 备注 |
|------|------|------|
| 权限管理 | permission_handler | BLE/定位/存储权限 |
| 文件系统 | path_provider | 获取本地路径 |
| 实时绘图 | fl_chart 或 CustomPainter | 高频波形需自绘 |
| 后台任务 | workmanager (Android) | 定时下载提醒 |
| 通知 | flutter_local_notifications | 离线采集完成提醒 |

### 原生桥接（阶段一保留）
- **BLE 通信**: 通过 Platform Channel 调用现有 `BLEService.java` 和 `ChipletRing1.0.81.aar`
- **EventChannel**: 用于高频数据流（波形、HR/RR）
- **MethodChannel**: 用于命令下发（连接、启动测量、文件操作）

### 算法迁移（阶段二）
- 将 `VitalSignsProcessor.java` 迁移到 Dart
- 使用 `Isolate` 处理高频计算
- 保持与原生算法结果一致（误差阈值测试）

---

## 架构设计

### 分层架构

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer (Flutter Widgets)               │
│  ├─ pages/                                          │
│  │   ├─ dashboard_page.dart                         │
│  │   ├─ measurement_page.dart (统一在线/离线)       │
│  │   ├─ history_page.dart                           │
│  │   └─ settings_page.dart                          │
│  └─ widgets/                                        │
│      ├─ waveform_chart.dart                         │
│      ├─ vital_signs_card.dart                       │
│      └─ offline_status_card.dart                    │
└─────────────────────────────────────────────────────┘
                       ↕ Riverpod Providers
┌─────────────────────────────────────────────────────┐
│  Business Logic Layer                               │
│  ├─ providers/                                      │
│  │   ├─ measurement_session_provider.dart          │
│  │   ├─ device_connection_provider.dart            │
│  │   └─ file_manager_provider.dart                 │
│  ├─ services/                                       │
│  │   ├─ sensor_data_source.dart (抽象接口)         │
│  │   ├─ live_ble_source.dart                       │
│  │   ├─ offline_recording_source.dart              │
│  │   └─ local_file_source.dart                     │
│  └─ processors/                                     │
│      └─ vital_signs_processor.dart (Dart 版算法)   │
└─────────────────────────────────────────────────────┘
                       ↕ Platform Channel
┌─────────────────────────────────────────────────────┐
│  Native Layer (Android/iOS)                         │
│  ├─ android/app/src/main/kotlin/                   │
│  │   ├─ RingMethodChannel.kt                       │
│  │   ├─ RingEventChannel.kt                        │
│  │   └─ BLEService.java (保留现有)                 │
│  └─ ios/ (暂时空实现)                               │
└─────────────────────────────────────────────────────┘
```

### 数据源抽象（统一在线/离线）

```dart
/// 统一的传感器数据源接口
abstract class SensorDataSource {
  /// 数据流（统一输出）
  Stream<SampleBatch> get dataStream;
  
  /// 状态流
  Stream<SourceState> get stateStream;
  
  /// 启动数据采集
  Future<void> start(SourceConfig config);
  
  /// 停止采集
  Future<void> stop();
  
  /// 数据源类型
  SourceType get type;
}

/// 三种实现
class LiveBleDataSource implements SensorDataSource {
  // 通过 Platform Channel 实时获取 BLE 数据
}

class OfflineRecordingDataSource implements SensorDataSource {
  // 启动戒指录制 → 断连 → 定时下载 → 回放
}

class LocalFileDataSource implements SensorDataSource {
  // 本地文件解析与回放
}
```

---

## 详细任务里程碑

### 🏁 阶段 0: 准备工作（3 天）

#### 任务 0.1: 初始化 Flutter 项目
- [ ] 创建 Flutter 项目 `flutter create openring_flutter`
- [ ] 配置 `pubspec.yaml` 依赖
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    flutter_riverpod: ^2.5.1
    go_router: ^14.2.0
    freezed_annotation: ^2.4.1
    json_annotation: ^4.9.0
    permission_handler: ^11.3.1
    path_provider: ^2.1.3
    fl_chart: ^0.68.0
    shared_preferences: ^2.2.3
    intl: ^0.19.0
  
  dev_dependencies:
    build_runner: ^2.4.9
    freezed: ^2.5.2
    json_serializable: ^6.8.0
    flutter_lints: ^4.0.0
  ```
- [ ] 配置 Android 权限 (`android/app/src/main/AndroidManifest.xml`)
  ```xml
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
  ```
- [ ] 配置 Android 原生集成（复制 `ChipletRing1.0.81.aar` 到 `android/app/libs/`）
- [ ] 更新 `android/app/build.gradle`
  ```gradle
  repositories {
      flatDir { dirs 'libs' }
  }
  dependencies {
      implementation(name: 'ChipletRing1.0.81', ext: 'aar')
  }
  ```

**验收标准**: 
- `flutter run` 成功启动空白应用
- Android 权限正确配置

---

### 🏗️ 阶段 1: 原生桥接（5 天）

#### 任务 1.1: Platform Channel 基础架构
**文件**: `lib/platform/ring_platform_interface.dart`

```dart
/// Platform Channel 抽象接口
abstract class RingPlatformInterface {
  static const MethodChannel _methodChannel = MethodChannel('ring/method');
  static const EventChannel _eventChannel = EventChannel('ring/events');
  
  // 设备管理
  Future<void> scanDevices();
  Future<void> connectDevice(String macAddress);
  Future<void> disconnect();
  Future<DeviceInfo?> getConnectedDevice();
  
  // 测量控制
  Future<void> startLiveMeasurement(int duration);
  Future<void> stopMeasurement();
  Future<void> startOfflineRecording(int totalDuration, int segmentDuration);
  
  // 文件操作
  Future<List<RingFile>> getFileList();
  Future<void> downloadFile(String fileName);
  Future<void> deleteFile(String fileName);
  
  // 事件流
  Stream<BleEvent> get eventStream;
}
```

**原生侧**: `android/app/src/main/kotlin/com/tsinghua/openring/RingMethodChannel.kt`

```kotlin
class RingMethodChannel(private val context: Context) : MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "ring/method"
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scanDevices" -> handleScanDevices(result)
            "connectDevice" -> {
                val macAddress = call.argument<String>("macAddress")
                handleConnectDevice(macAddress, result)
            }
            "startLiveMeasurement" -> {
                val duration = call.argument<Int>("duration") ?: 60
                handleStartLiveMeasurement(duration, result)
            }
            "getFileList" -> handleGetFileList(result)
            // ... 其他方法
            else -> result.notImplemented()
        }
    }
    
    private fun handleConnectDevice(macAddress: String?, result: Result) {
        // 调用现有 BLEService.java 与 LmAPI
        // ...
    }
}
```

**任务清单**:
- [ ] 创建 `RingPlatformInterface` Dart 接口
- [ ] 实现 `RingMethodChannel.kt` (Android)
- [ ] 创建 `RingEventChannel.kt` 用于数据流
- [ ] 测试连接/断开/扫描基础功能

**验收标准**:
- Flutter 侧可调用 `connectDevice()` 成功连接戒指
- EventChannel 可接收 BLE 数据事件

---

#### 任务 1.2: 事件流与数据模型

**文件**: `lib/models/ble_event.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_event.freezed.dart';
part 'ble_event.g.dart';

@freezed
class BleEvent with _$BleEvent {
  // 连接状态变化
  const factory BleEvent.connectionStateChanged({
    required ConnectionState state,
    String? deviceName,
    String? macAddress,
  }) = ConnectionStateChanged;
  
  // 实时数据
  const factory BleEvent.sampleBatch({
    required List<Sample> samples,
    required int timestamp,
  }) = SampleBatchEvent;
  
  // 生理指标更新
  const factory BleEvent.vitalSignsUpdate({
    int? heartRate,
    int? respiratoryRate,
    required SignalQuality quality,
  }) = VitalSignsUpdateEvent;
  
  // 文件列表响应
  const factory BleEvent.fileListReceived({
    required List<RingFile> files,
  }) = FileListReceivedEvent;
  
  // 错误
  const factory BleEvent.error({
    required String message,
    String? code,
  }) = BleErrorEvent;
  
  factory BleEvent.fromJson(Map<String, dynamic> json) => 
      _$BleEventFromJson(json);
}

@freezed
class Sample with _$Sample {
  const factory Sample({
    required int timestamp,
    required int green,
    required int red,
    required int ir,
    required int accX,
    required int accY,
    required int accZ,
    required int gyroX,
    required int gyroY,
    required int gyroZ,
    required int temp0,
    required int temp1,
    required int temp2,
  }) = _Sample;
  
  factory Sample.fromJson(Map<String, dynamic> json) => 
      _$SampleFromJson(json);
}
```

**任务清单**:
- [ ] 定义所有 Freezed 数据模型
- [ ] 运行 `flutter pub run build_runner build`
- [ ] 在 `RingEventChannel.kt` 中序列化事件为 JSON
- [ ] 测试 EventChannel 数据流通

**验收标准**:
- Flutter 侧可接收并解析 `SampleBatch` 事件
- 数据模型正确反序列化

---

### 📊 阶段 2: 数据源抽象层（4 天）

#### 任务 2.1: 数据源接口与实现

**文件**: `lib/services/sensor_data_source.dart`

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ble_event.dart';

enum SourceType { liveBle, offlineRecording, localFile }

enum SourceState {
  idle,
  preparing,
  streaming,
  paused,
  stopped,
  error,
}

class SourceConfig {
  final int? duration;
  final String? filePath;
  final String? fileName;
  final bool autoDisconnect;
  final double playbackSpeed;
  
  const SourceConfig({
    this.duration,
    this.filePath,
    this.fileName,
    this.autoDisconnect = false,
    this.playbackSpeed = 1.0,
  });
}

/// 统一数据源接口
abstract class SensorDataSource {
  SourceType get type;
  Stream<List<Sample>> get sampleStream;
  Stream<SourceState> get stateStream;
  
  Future<void> start(SourceConfig config);
  Future<void> stop();
  Future<void> dispose();
}
```

**实现 1: 在线 BLE 数据源**

**文件**: `lib/services/live_ble_source.dart`

```dart
import 'dart:async';
import 'sensor_data_source.dart';
import '../platform/ring_platform_interface.dart';
import '../models/ble_event.dart';

class LiveBleDataSource implements SensorDataSource {
  final RingPlatformInterface _platform;
  
  final _sampleController = StreamController<List<Sample>>.broadcast();
  final _stateController = StreamController<SourceState>.broadcast();
  
  StreamSubscription? _eventSubscription;
  
  LiveBleDataSource(this._platform);
  
  @override
  SourceType get type => SourceType.liveBle;
  
  @override
  Stream<List<Sample>> get sampleStream => _sampleController.stream;
  
  @override
  Stream<SourceState> get stateStream => _stateController.stream;
  
  @override
  Future<void> start(SourceConfig config) async {
    _stateController.add(SourceState.preparing);
    
    // 订阅事件流
    _eventSubscription = _platform.eventStream.listen((event) {
      event.when(
        sampleBatch: (samples, timestamp) {
          _sampleController.add(samples);
        },
        connectionStateChanged: (state, deviceName, macAddress) {
          if (state == ConnectionState.connected) {
            _stateController.add(SourceState.streaming);
          }
        },
        error: (message, code) {
          _stateController.add(SourceState.error);
        },
        vitalSignsUpdate: (_, __, ___) {},
        fileListReceived: (_) {},
      );
    });
    
    // 启动在线测量
    await _platform.startLiveMeasurement(config.duration ?? 60);
  }
  
  @override
  Future<void> stop() async {
    await _platform.stopMeasurement();
    _stateController.add(SourceState.stopped);
  }
  
  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _sampleController.close();
    await _stateController.close();
  }
}
```

**任务清单**:
- [ ] 实现 `SensorDataSource` 接口
- [ ] 实现 `LiveBleDataSource`
- [ ] 创建 Riverpod Provider
  ```dart
  final liveDataSourceProvider = Provider<SensorDataSource>((ref) {
    final platform = ref.watch(ringPlatformProvider);
    return LiveBleDataSource(platform);
  });
  ```

**验收标准**:
- `LiveBleDataSource` 可成功启动并接收数据流
- 状态转换正确（preparing → streaming → stopped）

---

#### 任务 2.2: 离线录制数据源（核心）

**文件**: `lib/services/offline_recording_source.dart`

```dart
import 'dart:async';
import 'sensor_data_source.dart';
import '../platform/ring_platform_interface.dart';

enum RecordingPhase {
  idle,
  scheduling,      // 发送启动命令
  recording,       // 戒指采集中（可断连）
  waitingDownload, // 采集完成，等待下载
  downloading,     // 下载中
  readyForPlayback,// 已下载，准备回放
  playingBack,     // 回放中
}

class OfflineRecordingDataSource implements SensorDataSource {
  final RingPlatformInterface _platform;
  
  RecordingPhase _phase = RecordingPhase.idle;
  DateTime? _estimatedEndTime;
  Timer? _autoDownloadTimer;
  
  final _sampleController = StreamController<List<Sample>>.broadcast();
  final _stateController = StreamController<SourceState>.broadcast();
  final _phaseController = StreamController<RecordingPhase>.broadcast();
  
  Stream<RecordingPhase> get phaseStream => _phaseController.stream;
  
  @override
  SourceType get type => SourceType.offlineRecording;
  
  @override
  Stream<List<Sample>> get sampleStream => _sampleController.stream;
  
  @override
  Stream<SourceState> get stateStream => _stateController.stream;
  
  @override
  Future<void> start(SourceConfig config) async {
    _phase = RecordingPhase.scheduling;
    _phaseController.add(_phase);
    _stateController.add(SourceState.preparing);
    
    // 1. 发送离线录制命令到戒指
    await _platform.startOfflineRecording(
      config.duration ?? 300,
      config.segmentDuration ?? 60,
    );
    
    // 2. 戒指确认后，进入 RECORDING 状态
    _phase = RecordingPhase.recording;
    _phaseController.add(_phase);
    _stateController.add(SourceState.streaming);
    
    // 3. 记录预计完成时间
    _estimatedEndTime = DateTime.now().add(
      Duration(seconds: config.duration ?? 300)
    );
    
    // 4. 可选：自动断连以省电
    if (config.autoDisconnect) {
      await Future.delayed(Duration(seconds: 2));
      await _platform.disconnect();
    }
    
    // 5. 设置自动下载定时器
    _scheduleAutoDownload(config.duration ?? 300);
  }
  
  void _scheduleAutoDownload(int duration) {
    _autoDownloadTimer = Timer(
      Duration(seconds: duration + 10),
      () async {
        _phase = RecordingPhase.waitingDownload;
        _phaseController.add(_phase);
        
        // 显示通知：采集完成，可下载
        // await _showDownloadNotification();
        
        // 尝试自动下载
        await _attemptAutoDownload();
      },
    );
  }
  
  Future<void> _attemptAutoDownload() async {
    _phase = RecordingPhase.downloading;
    _phaseController.add(_phase);
    
    try {
      // 重连戒指
      await _platform.connectDevice(/* 保存的 MAC */);
      
      // 获取文件列表
      final files = await _platform.getFileList();
      
      // 找到最新文件（根据时间戳）
      final latestFile = _findLatestFile(files, _estimatedEndTime!);
      
      if (latestFile != null) {
        // 下载文件
        await _platform.downloadFile(latestFile.fileName);
        
        _phase = RecordingPhase.readyForPlayback;
        _phaseController.add(_phase);
        
        // 自动开始回放
        await _startPlayback(latestFile.localPath);
      }
    } catch (e) {
      _stateController.add(SourceState.error);
    }
  }
  
  Future<void> _startPlayback(String filePath) async {
    _phase = RecordingPhase.playingBack;
    _phaseController.add(_phase);
    
    // 解析文件并按时间戳回放
    final samples = await _parseFile(filePath);
    
    // 模拟实时流
    for (var batch in _batchSamples(samples, batchSize: 25)) {
      _sampleController.add(batch);
      await Future.delayed(Duration(milliseconds: 40)); // 25Hz
    }
    
    _phase = RecordingPhase.idle;
    _phaseController.add(_phase);
  }
  
  @override
  Future<void> stop() async {
    _autoDownloadTimer?.cancel();
    
    if (_phase == RecordingPhase.recording) {
      await _platform.stopMeasurement();
    }
    
    _phase = RecordingPhase.idle;
    _phaseController.add(_phase);
    _stateController.add(SourceState.stopped);
  }
  
  @override
  Future<void> dispose() async {
    await _sampleController.close();
    await _stateController.close();
    await _phaseController.close();
    _autoDownloadTimer?.cancel();
  }
  
  RingFile? _findLatestFile(List<RingFile> files, DateTime targetTime) {
    // 实现：找到时间戳最接近 targetTime 的文件
    return null;
  }
  
  Future<List<Sample>> _parseFile(String filePath) async {
    // 实现：解析戒指文件格式
    return [];
  }
  
  Iterable<List<Sample>> _batchSamples(List<Sample> samples, {required int batchSize}) sync* {
    for (var i = 0; i < samples.length; i += batchSize) {
      yield samples.sublist(i, (i + batchSize).clamp(0, samples.length));
    }
  }
}
```

**任务清单**:
- [ ] 实现 8 状态状态机
- [ ] 实现自动下载定时器
- [ ] 实现文件解析逻辑（需参考现有格式）
- [ ] 实现回放控制（暂停/快进）

**验收标准**:
- 可启动离线录制并断连
- 定时器触发后自动下载文件
- 文件回放正常，数据与原生一致

---

### 🎨 阶段 3: UI 实现（6 天）

#### 任务 3.1: 主界面与路由

**文件**: `lib/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/measurement_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/measurement',
      builder: (context, state) => const MeasurementPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
```

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OpenRingApp(),
    ),
  );
}

class OpenRingApp extends StatelessWidget {
  const OpenRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenRing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      routerConfig: appRouter,
    );
  }
}
```

**任务清单**:
- [ ] 创建主应用入口
- [ ] 配置 go_router
- [ ] 创建底部导航栏（Dashboard/测量/历史/设置）

---

#### 任务 3.2: 统一测量页（核心页面）

**文件**: `lib/pages/measurement_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/measurement_session_provider.dart';
import '../widgets/data_source_selector.dart';
import '../widgets/waveform_chart.dart';
import '../widgets/vital_signs_card.dart';
import '../widgets/offline_status_card.dart';

class MeasurementPage extends ConsumerWidget {
  const MeasurementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(measurementSessionProvider);
    final isActive = session.isActive;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('测量'),
      ),
      body: Column(
        children: [
          // 数据源选择器
          const DataSourceSelector(),
          
          const SizedBox(height: 16),
          
          // 离线状态卡片（仅离线模式显示）
          if (session.sourceType == SourceType.offlineRecording)
            const OfflineStatusCard(),
          
          const SizedBox(height: 16),
          
          // 生理指标卡片
          const VitalSignsCard(),
          
          const SizedBox(height: 16),
          
          // 波形图表
          Expanded(
            child: const WaveformChart(),
          ),
          
          const SizedBox(height: 16),
          
          // 开始/停止按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isActive ? null : () => ref
                    .read(measurementSessionProvider.notifier)
                    .start(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始测量'),
              ),
              ElevatedButton.icon(
                onPressed: isActive ? () => ref
                    .read(measurementSessionProvider.notifier)
                    .stop() : null,
                icon: const Icon(Icons.stop),
                label: const Text('停止'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**任务清单**:
- [ ] 实现测量页布局
- [ ] 创建数据源选择器（下拉或分段控件）
- [ ] 创建生理指标卡片（HR/RR/质量）
- [ ] 创建波形图表组件

---

#### 任务 3.3: 波形图表组件（高频绘制）

**文件**: `lib/widgets/waveform_chart.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/measurement_session_provider.dart';
import '../models/ble_event.dart';

class WaveformChart extends ConsumerStatefulWidget {
  const WaveformChart({super.key});

  @override
  ConsumerState<WaveformChart> createState() => _WaveformChartState();
}

class _WaveformChartState extends ConsumerState<WaveformChart> {
  final List<double> _greenData = [];
  final List<double> _redData = [];
  final List<double> _irData = [];
  
  static const int _maxDataPoints = 500;
  
  @override
  Widget build(BuildContext context) {
    // 订阅样本流
    ref.listen(sampleStreamProvider, (previous, next) {
      next.whenData((samples) {
        setState(() {
          for (var sample in samples) {
            _greenData.add(sample.green.toDouble());
            _redData.add(sample.red.toDouble());
            _irData.add(sample.ir.toDouble());
            
            // 保持固定长度
            if (_greenData.length > _maxDataPoints) {
              _greenData.removeAt(0);
              _redData.removeAt(0);
              _irData.removeAt(0);
            }
          }
        });
      });
    });
    
    return Column(
      children: [
        // PPG Green 通道
        Expanded(
          child: CustomPaint(
            painter: WaveformPainter(
              data: _greenData,
              color: Colors.green,
              label: 'PPG Green',
            ),
            child: Container(),
          ),
        ),
        
        // PPG Red 通道
        Expanded(
          child: CustomPaint(
            painter: WaveformPainter(
              data: _redData,
              color: Colors.red,
              label: 'PPG Red',
            ),
            child: Container(),
          ),
        ),
        
        // PPG IR 通道
        Expanded(
          child: CustomPaint(
            painter: WaveformPainter(
              data: _irData,
              color: Colors.orange,
              label: 'PPG IR',
            ),
            child: Container(),
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final String label;
  
  WaveformPainter({
    required this.data,
    required this.color,
    required this.label,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // 归一化数据
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    
    if (range == 0) return;
    
    final path = Path();
    final xStep = size.width / (data.length - 1);
    
    for (var i = 0; i < data.length; i++) {
      final x = i * xStep;
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // 绘制标签
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(8, 8));
  }
  
  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}
```

**任务清单**:
- [ ] 实现 CustomPainter 高效绘制
- [ ] 添加降采样逻辑（避免绘制过多点）
- [ ] 添加滚动效果与缩放
- [ ] 支持 12 通道切换显示

**性能目标**:
- 60 FPS 绘制
- 内存占用 < 50 MB

---

#### 任务 3.4: 离线状态卡片

**文件**: `lib/widgets/offline_status_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_recording_provider.dart';

class OfflineStatusCard extends ConsumerWidget {
  const OfflineStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineRecordingStatusProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPhaseIcon(status.phase),
                  color: _getPhaseColor(status.phase),
                ),
                const SizedBox(width: 8),
                Text(
                  _getPhaseDescription(status.phase),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 进度条
            if (status.phase == RecordingPhase.recording ||
                status.phase == RecordingPhase.downloading)
              LinearProgressIndicator(
                value: status.progressPercent / 100,
              ),
            
            const SizedBox(height: 8),
            
            // 剩余时间
            if (status.remainingSeconds > 0)
              Text(
                '预计剩余 ${_formatDuration(status.remainingSeconds)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            
            const SizedBox(height: 12),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status.phase == RecordingPhase.recording)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(offlineRecordingProvider.notifier)
                        .disconnect(),
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('断开连接（省电）'),
                  ),
                
                if (status.phase == RecordingPhase.waitingDownload)
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(offlineRecordingProvider.notifier)
                        .downloadNow(),
                    icon: const Icon(Icons.download),
                    label: const Text('立即下载'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPhaseIcon(RecordingPhase phase) {
    switch (phase) {
      case RecordingPhase.recording:
        return Icons.fiber_manual_record;
      case RecordingPhase.waitingDownload:
        return Icons.check_circle;
      case RecordingPhase.downloading:
        return Icons.download;
      default:
        return Icons.info;
    }
  }
  
  Color _getPhaseColor(RecordingPhase phase) {
    switch (phase) {
      case RecordingPhase.recording:
        return Colors.red;
      case RecordingPhase.waitingDownload:
        return Colors.green;
      case RecordingPhase.downloading:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _getPhaseDescription(RecordingPhase phase) {
    switch (phase) {
      case RecordingPhase.scheduling:
        return '正在启动...';
      case RecordingPhase.recording:
        return '戒指正在采集数据';
      case RecordingPhase.waitingDownload:
        return '采集完成，可以下载了';
      case RecordingPhase.downloading:
        return '正在下载文件';
      case RecordingPhase.playingBack:
        return '正在回放数据';
      default:
        return '';
    }
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes 分 $secs 秒';
  }
}
```

**任务清单**:
- [ ] 实现状态卡片 UI
- [ ] 添加进度动画
- [ ] 集成断开连接按钮
- [ ] 集成立即下载按钮

---

### 🧮 阶段 4: 算法迁移（5 天）

#### 任务 4.1: Dart 版生理信号处理器

**文件**: `lib/processors/vital_signs_processor.dart`

```dart
import 'dart:async';
import 'dart:math';
import '../models/ble_event.dart';

enum SignalQuality {
  excellent,
  good,
  fair,
  poor,
  noSignal,
}

class VitalSignsProcessor {
  static const int _sampleRate = 25;
  static const int _hrWindowSize = _sampleRate * 8;  // 8 seconds
  static const int _rrWindowSize = _sampleRate * 30; // 30 seconds
  
  final _ppgGreenBuffer = <int>[];
  final _accXBuffer = <int>[];
  final _accYBuffer = <int>[];
  final _accZBuffer = <int>[];
  
  final _hrController = StreamController<int>.broadcast();
  final _rrController = StreamController<int>.broadcast();
  final _qualityController = StreamController<SignalQuality>.broadcast();
  
  Stream<int> get heartRateStream => _hrController.stream;
  Stream<int> get respiratoryRateStream => _rrController.stream;
  Stream<SignalQuality> get signalQualityStream => _qualityController.stream;
  
  /// 添加样本批次
  void processBatch(List<Sample> samples) {
    for (var sample in samples) {
      _ppgGreenBuffer.add(sample.green);
      _accXBuffer.add(sample.accX);
      _accYBuffer.add(sample.accY);
      _accZBuffer.add(sample.accZ);
      
      // 保持固定窗口大小
      if (_ppgGreenBuffer.length > _hrWindowSize) {
        _ppgGreenBuffer.removeAt(0);
      }
      if (_accXBuffer.length > _rrWindowSize) {
        _accXBuffer.removeAt(0);
        _accYBuffer.removeAt(0);
        _accZBuffer.removeAt(0);
      }
    }
    
    // 处理心率
    if (_ppgGreenBuffer.length >= _hrWindowSize) {
      _processHeartRate();
    }
    
    // 处理呼吸率
    if (_accXBuffer.length >= _rrWindowSize) {
      _processRespiratoryRate();
    }
    
    // 更新信号质量
    _updateSignalQuality();
  }
  
  void _processHeartRate() {
    // 带通滤波 (0.5-4Hz)
    final filtered = _applyBandpassFilter(_ppgGreenBuffer, 0.5, 4.0);
    
    // 峰值检测
    final peaks = _detectPeaks(filtered, 0.6);
    
    if (peaks.length >= 3) {
      // 计算峰间距中位数
      final intervals = <double>[];
      for (var i = 1; i < peaks.length; i++) {
        intervals.add((peaks[i] - peaks[i-1]) / _sampleRate);
      }
      intervals.sort();
      
      final medianInterval = intervals[intervals.length ~/ 2];
      final heartRate = (60.0 / medianInterval).round();
      
      // 验证合理范围 (40-200 BPM)
      if (heartRate >= 40 && heartRate <= 200) {
        _hrController.add(heartRate);
      }
    }
  }
  
  void _processRespiratoryRate() {
    // 计算加速度幅值
    final accMagnitude = <double>[];
    for (var i = 0; i < _accXBuffer.length; i++) {
      final x = _accXBuffer[i].toDouble();
      final y = _accYBuffer[i].toDouble();
      final z = _accZBuffer[i].toDouble();
      accMagnitude.add(sqrt(x*x + y*y + z*z));
    }
    
    // 低通滤波 (0.1-0.7Hz)
    final filtered = _applyBandpassFilter(
      accMagnitude.map((e) => e.toInt()).toList(),
      0.1,
      0.7,
    );
    
    // 峰值检测
    final peaks = _detectPeaks(filtered, 0.4);
    
    if (peaks.length >= 2) {
      final totalTime = _rrWindowSize / _sampleRate;
      final respiratoryRate = ((peaks.length - 1) * 60.0 / totalTime).round();
      
      // 验证合理范围 (8-40 RPM)
      if (respiratoryRate >= 8 && respiratoryRate <= 40) {
        _rrController.add(respiratoryRate);
      }
    }
  }
  
  List<double> _applyBandpassFilter(
    List<int> data,
    double lowFreq,
    double highFreq,
  ) {
    // 简单移动平均滤波（实际应使用 Butterworth 滤波器）
    final windowSize = max(1, _sampleRate ~/ 5);
    final filtered = <double>[];
    
    for (var i = 0; i < data.length; i++) {
      var sum = 0.0;
      var count = 0;
      
      final start = max(0, i - windowSize ~/ 2);
      final end = min(data.length, i + windowSize ~/ 2 + 1);
      
      for (var j = start; j < end; j++) {
        sum += data[j];
        count++;
      }
      
      filtered.add(sum / count);
    }
    
    return filtered;
  }
  
  List<int> _detectPeaks(List<double> data, double threshold) {
    final peaks = <int>[];
    
    if (data.length < 3) return peaks;
    
    // 计算动态阈值
    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final dynamicThreshold = minVal + (maxVal - minVal) * threshold;
    
    // 峰值检测
    for (var i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i-1] &&
          data[i] > data[i+1] &&
          data[i] > dynamicThreshold) {
        // 避免峰值过密
        if (peaks.isEmpty || i - peaks.last > _sampleRate ~/ 4) {
          peaks.add(i);
        }
      }
    }
    
    return peaks;
  }
  
  void _updateSignalQuality() {
    if (_ppgGreenBuffer.isEmpty) {
      _qualityController.add(SignalQuality.noSignal);
      return;
    }
    
    final minVal = _ppgGreenBuffer.reduce(min);
    final maxVal = _ppgGreenBuffer.reduce(max);
    final range = maxVal - minVal;
    final mean = _ppgGreenBuffer.reduce((a, b) => a + b) / _ppgGreenBuffer.length;
    
    SignalQuality quality;
    if (mean > 1000 && range > 2000) {
      quality = SignalQuality.excellent;
    } else if (mean > 1000 && range > 1500) {
      quality = SignalQuality.good;
    } else if (mean > 1000 && range > 1000) {
      quality = SignalQuality.fair;
    } else if (mean > 1000) {
      quality = SignalQuality.poor;
    } else {
      quality = SignalQuality.noSignal;
    }
    
    _qualityController.add(quality);
  }
  
  void reset() {
    _ppgGreenBuffer.clear();
    _accXBuffer.clear();
    _accYBuffer.clear();
    _accZBuffer.clear();
  }
  
  void dispose() {
    _hrController.close();
    _rrController.close();
    _qualityController.close();
  }
}
```

**任务清单**:
- [ ] 迁移滤波算法
- [ ] 迁移峰值检测算法
- [ ] 迁移心率/呼吸率计算
- [ ] 与原生算法对比测试（误差 < 5%）

**验收标准**:
- Dart 版算法与 Java 版结果一致
- 性能可接受（CPU < 10%）

---

### 🚀 阶段 5: 集成与测试（4 天）

#### 任务 5.1: 端到端集成测试

**测试场景**:
1. **在线模式测试**
   - [ ] 扫描并连接戒指
   - [ ] 启动在线测量 60 秒
   - [ ] 实时显示波形
   - [ ] 显示 HR/RR 指标
   - [ ] 停止测量

2. **离线模式测试**
   - [ ] 启动离线录制 300 秒
   - [ ] 断开连接
   - [ ] 等待 5 分钟
   - [ ] 自动重连并下载
   - [ ] 回放文件

3. **异常场景测试**
   - [ ] 测量中途断连（在线模式）
   - [ ] 重连失败（离线模式）
   - [ ] 文件下载失败
   - [ ] App 被杀后恢复状态

**任务清单**:
- [ ] 编写集成测试脚本
- [ ] 真机测试（多款 Android 手机）
- [ ] 修复发现的 Bug

---

#### 任务 5.2: 性能优化

**优化目标**:
| 指标 | 目标 | 当前 | 优化方案 |
|------|------|------|----------|
| 帧率 | >= 60 FPS | - | 降采样、批量绘制 |
| 内存 | < 100 MB | - | 限制缓冲区大小 |
| 启动时间 | < 2 秒 | - | 延迟加载 |
| BLE 延迟 | < 50 ms | - | 优化 Channel 通信 |

**任务清单**:
- [ ] 使用 Flutter DevTools 分析性能
- [ ] 优化波形绘制（减少重绘）
- [ ] 优化样本流处理（使用 Isolate）
- [ ] 减少不必要的 Widget 重建

---

### 📦 阶段 6: 打包与发布（2 天）

#### 任务 6.1: 生成 APK/AAB

**任务清单**:
- [ ] 配置签名密钥
  ```gradle
  // android/app/build.gradle
  signingConfigs {
      release {
          keyAlias keystoreProperties['keyAlias']
          keyPassword keystoreProperties['keyPassword']
          storeFile file(keystoreProperties['storeFile'])
          storePassword keystoreProperties['storePassword']
      }
  }
  ```
- [ ] 优化 ProGuard 规则
- [ ] 生成 Release APK
  ```bash
  flutter build apk --release
  ```
- [ ] 生成 AAB（Google Play）
  ```bash
  flutter build appbundle --release
  ```

**验收标准**:
- APK 大小 < 50 MB
- 真机测试无崩溃

---

## 📊 进度跟踪

### 总览

| 阶段 | 预计时间 | 任务数 | 完成率 |
|------|----------|--------|--------|
| 阶段 0: 准备 | 3 天 | 3 | 0% |
| 阶段 1: 原生桥接 | 5 天 | 6 | 0% |
| 阶段 2: 数据源抽象 | 4 天 | 4 | 0% |
| 阶段 3: UI 实现 | 6 天 | 8 | 0% |
| 阶段 4: 算法迁移 | 5 天 | 4 | 0% |
| 阶段 5: 集成测试 | 4 天 | 6 | 0% |
| 阶段 6: 打包发布 | 2 天 | 3 | 0% |
| **总计** | **29 天 (~6 周)** | **34** | **0%** |

### 关键路径

```
准备工作 (3天)
    ↓
原生桥接 (5天) ← 关键路径
    ↓
数据源抽象 (4天) ← 关键路径
    ↓
UI 实现 (6天) 与 算法迁移 (5天) 可并行
    ↓
集成测试 (4天)
    ↓
打包发布 (2天)
```

**最短完成时间**: 24 天（4.8 周，如果 UI 与算法并行）

---

## 🎯 验收标准

### 功能完整性
- [ ] 在线测量功能完整且稳定
- [ ] 离线录制支持断连与自动下载
- [ ] 波形实时绘制流畅（>= 30 FPS）
- [ ] HR/RR 计算准确（与原生误差 < 5%）
- [ ] 文件管理功能完整（列表/下载/删除）

### 用户体验
- [ ] UI 符合 Material Design 3 规范
- [ ] 暗色模式支持
- [ ] 错误提示友好且可操作
- [ ] 离线模式状态清晰可见

### 性能指标
- [ ] 启动时间 < 2 秒
- [ ] 内存占用 < 100 MB
- [ ] CPU 占用 < 20%（测量时）
- [ ] APK 大小 < 50 MB

### 兼容性
- [ ] Android 8.0+ 全面兼容
- [ ] 测试至少 3 款不同品牌手机
- [ ] 蓝牙 4.0/5.0 均可正常工作

---

## 🛠️ 开发工具与规范

### 代码规范
- **Dart**: 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **命名**: 小驼峰（变量/方法）、大驼峰（类/枚举）
- **格式化**: `flutter format .`
- **静态分析**: `flutter analyze`

### Git 提交规范
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试
- `docs`: 文档

**示例**:
```
feat(platform): implement BLE method channel

- Add RingMethodChannel.kt for Android
- Add RingPlatformInterface.dart for Flutter
- Support connect/disconnect/scan methods

Closes #12
```

### 分支策略
- `main`: 稳定版本
- `develop`: 开发分支
- `feature/*`: 功能分支
- `bugfix/*`: Bug 修复分支

---

## 📝 附录

### 依赖版本锁定

**pubspec.yaml**:
```yaml
name: openring_flutter
description: OpenRing Smart Ring Flutter App
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  permission_handler: ^11.3.1
  path_provider: ^2.1.3
  fl_chart: ^0.68.0
  shared_preferences: ^2.2.3
  sqflite: ^2.3.3
  intl: ^0.19.0
  flutter_local_notifications: ^17.1.2
  workmanager: ^0.5.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  flutter_lints: ^4.0.0
```

### 文件结构

```
openring_flutter/
├── lib/
│   ├── main.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── pages/
│   │   ├── dashboard_page.dart
│   │   ├── measurement_page.dart
│   │   ├── history_page.dart
│   │   └── settings_page.dart
│   ├── widgets/
│   │   ├── data_source_selector.dart
│   │   ├── waveform_chart.dart
│   │   ├── vital_signs_card.dart
│   │   └── offline_status_card.dart
│   ├── providers/
│   │   ├── measurement_session_provider.dart
│   │   ├── device_connection_provider.dart
│   │   └── offline_recording_provider.dart
│   ├── services/
│   │   ├── sensor_data_source.dart
│   │   ├── live_ble_source.dart
│   │   ├── offline_recording_source.dart
│   │   └── local_file_source.dart
│   ├── processors/
│   │   └── vital_signs_processor.dart
│   ├── platform/
│   │   └── ring_platform_interface.dart
│   └── models/
│       ├── ble_event.dart
│       ├── sample.dart
│       └── ring_file.dart
├── android/
│   └── app/
│       ├── src/main/kotlin/
│       │   └── com/tsinghua/openring/
│       │       ├── RingMethodChannel.kt
│       │       └── RingEventChannel.kt
│       └── libs/
│           └── ChipletRing1.0.81.aar
└── test/
    ├── unit/
    ├── integration/
    └── widget/
```

---

## 🚀 开始重构

### 第一步：创建 Flutter 项目

```bash
# 1. 创建项目
flutter create --org com.tsinghua openring_flutter

# 2. 进入项目目录
cd openring_flutter

# 3. 添加依赖
flutter pub add flutter_riverpod go_router freezed_annotation json_annotation \
  permission_handler path_provider fl_chart shared_preferences intl \
  flutter_local_notifications workmanager

flutter pub add --dev build_runner freezed json_serializable flutter_lints

# 4. 运行项目（验证环境）
flutter run
```

### 第二步：复制原生资源

```bash
# 复制 AAR 库
cp ../androidring/app/libs/ChipletRing1.0.81.aar android/app/libs/

# 复制 BLEService.java
cp ../androidring/app/src/main/java/com/tsinghua/openring/utils/BLEService.java \
   android/app/src/main/java/com/tsinghua/openring/
```

### 第三步：开始阶段 1

按照里程碑文档，从**阶段 1: 原生桥接**开始实施。

---

**准备好了吗？让我们开始重构！🚀**

