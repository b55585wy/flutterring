# OpenRing Flutter 重构路线图 - 更新版

> **更新时间**: 2024-10-31  
> **当前状态**: 阶段 1.1 部分完成（扫描+连接），准备开始阶段 1.2

---

## ✅ 已完成的工作

### 阶段 0: 准备工作（已完成 ✓）

#### ✅ 任务 0.1: Flutter 项目初始化
- [x] 创建 Flutter 项目 `openring_flutter`
- [x] 配置 `pubspec.yaml` 依赖
  - flutter_riverpod: ^2.6.1
  - fl_chart: ^0.68.0
  - intl: ^0.19.0
  - logger: ^2.2.0
- [x] 配置 Android Manifest 权限
- [x] 配置 Android AAR 集成
  - 复制 `Chiplet1.0.81.aar` 到 `android/app/libs/`
  - 更新 `build.gradle` 配置
- [x] 解决 Gradle/Java 版本兼容性问题
  - Gradle 8.7
  - JDK 21
  - Kotlin 1.9.20
  - Android Gradle Plugin 8.3.2
  - minSdk 26 (AAR 要求)
  - NDK 25.1.8937393

#### ✅ 任务 0.2: 精致 UI 框架搭建
- [x] 创建主应用入口 (`main.dart`)
- [x] 创建底部导航栏 (`HomePage`)
- [x] 创建 4 个主要页面
  - [x] **DashboardPage**: 仪表盘（连接状态、设备信息、快捷操作）
  - [x] **MeasurementPage**: 测量页面（数据源选择、波形、指标、控制）
  - [x] **HistoryPage**: 历史记录（本周概览、所有记录列表）
  - [x] **SettingsPage**: 设置页面（设备管理、数据管理、应用设置）
- [x] 实现精致现代化 Material Design 3 UI
  - 卡片式布局
  - 圆角设计
  - 动画效果（心跳动画、进度条）
  - 实时波形图（CustomPainter）
  - 生理指标卡片（HR/RR/信号质量）
- [x] 应用成功运行在模拟器上

#### ✅ 任务 0.3: Platform Channel 框架搭建
- [x] 创建 Dart 侧 Platform 接口 (`ring_platform.dart`)
  - MethodChannel: `com.tsinghua.openring/ble_method`
  - EventChannel: `com.tsinghua.openring/ble_event`
- [x] 创建 Android 侧 MainActivity.kt（用户自行实现）
  - MethodChannel 处理器
  - EventChannel 流处理器
- [x] 集成 BLE 扫描和连接功能到 DashboardPage
  - 扫描按钮
  - 设备列表展示
  - 连接状态显示

---

## 🚀 下一阶段计划

### 阶段 1: Platform Channel 完善与 BLE 集成（预计 3-4 天）

#### 📋 任务 1.1: 完善 MainActivity.kt BLE 功能实现

**目标**: 将用户编写的 MainActivity.kt 与 AAR 库集成，实现真实 BLE 功能。

**子任务**:
1. **验证 MainActivity.kt 基本功能** ✅ **已完成**
   - [x] 测试扫描功能（scanDevices） ✅
   - [x] 测试连接功能（connectDevice） ✅
   - [x] 测试断连功能（disconnect） ✅
   - [x] 验证 EventChannel 事件流通（deviceFound, connectionStateChanged） ✅
   - [x] 使用 LogicalApi 过滤设备（仅显示 OpenRing 智能戒指） ✅
   - [x] 注册 BLEService 到 AndroidManifest.xml ✅
   - [x] 添加连接日志（便于调试） ✅

2. **集成 AAR 库的核心方法** 🚧 **下一步**
   - [ ] 实现 `startLiveMeasurement(duration)` - 启动在线测量
   - [ ] 实现 `stopMeasurement()` - 停止测量
   - [ ] 实现 `getDeviceInfo()` - 获取设备版本、电量
   - [ ] 实现 `getBatteryLevel()` - 获取电量
   - [ ] 实现 `updateDeviceTime()` - 同步时间
   - [ ] 实现 `calibrateTime()` - 校准时间

3. **实现实时数据流** 🚧 **下一步**
   - [ ] 实现 `onCharacteristicChanged` 回调解析
   - [ ] 将原始 BLE 数据转换为 `SampleBatch` 事件
   - [ ] 发送到 EventChannel
   - [ ] Dart 侧接收并解析数据

**验收标准**:
- ✅ 可以成功扫描并连接戒指（已完成）
- ⏳ 启动测量后，Dart 侧可接收到实时数据流（下一步）
- ⏳ 数据格式正确（包含 PPG×3, ACC×3, Gyro×3, Temp×3）（下一步）

**预计时间**: 1-2 天  
**实际进度**: 已完成 30%（扫描+连接）

---

#### 📋 任务 1.2: 数据模型与事件系统 ✅ **已完成**

**目标**: 定义完整的 Freezed 数据模型，实现类型安全的事件系统。

**文件创建**:
1. **`lib/models/ble_event.dart`** - BLE 事件模型 ✅
   - 已创建 9 种事件类型（deviceFound, scanCompleted, connectionStateChanged, sampleBatch, vitalSignsUpdate, fileListReceived, fileDownloadProgress, fileDownloadCompleted, recordingStateChanged, rssiUpdated, batteryLevelUpdated, error）

2. **`lib/models/sample.dart`** - 传感器样本模型 ✅
   - 已创建 `Sample` 模型（12 个传感器字段）
   - 已创建 `VitalSigns` 模型（HR/RR/信号质量）
   - 已创建 `SignalQuality` 枚举（5 级）

3. **`lib/models/device_info.dart`** - 设备信息模型 ✅
   - 已创建 `DeviceInfo` 模型
   - 已创建 `DeviceConnectionConfig` 模型

**子任务**:
- [x] 创建所有 Freezed 模型 ✅
- [x] 运行 `flutter pub run build_runner build` ✅
- [x] 更新 `ring_platform.dart` 使用新模型 ✅
- [x] 更新 MainActivity.kt 序列化逻辑 ✅

**验收标准**:
- ✅ 所有模型正确生成 `.freezed.dart` 和 `.g.dart` ✅
- ✅ EventChannel 事件可正确反序列化 ✅
- ✅ 类型安全（无运行时类型错误） ✅

**预计时间**: 0.5 天  
**实际完成**: ✅ 已完成

---

#### 📋 任务 1.3: 测量页面实时数据集成

**目标**: 将 Platform Channel 数据流连接到测量页面，实现真实波形显示。

**子任务**:
1. **创建 Riverpod Provider**
   ```dart
   // lib/providers/ble_data_provider.dart
   final bleEventStreamProvider = StreamProvider<BleEvent>((ref) {
     return RingPlatform.eventStream;
   });
   
   final currentSamplesProvider = StateProvider<List<Sample>>((ref) => []);
   
   final heartRateProvider = StateProvider<int?>((ref) => null);
   final respiratoryRateProvider = StateProvider<int?>((ref) => null);
   final signalQualityProvider = StateProvider<double>((ref) => 0.0);
   ```

2. **更新 MeasurementPage**
   - [ ] 监听 `bleEventStreamProvider`
   - [ ] 接收 `SampleBatch` 事件
   - [ ] 更新 `_ppgGreenData`, `_ppgRedData`, `_ppgIrData`
   - [ ] 触发波形重绘

3. **实现开始/停止逻辑**
   - [ ] "开始测量" 按钮调用 `RingPlatform.startLiveMeasurement(60)`
   - [ ] "停止" 按钮调用 `RingPlatform.stopMeasurement()`
   - [ ] 根据连接状态启用/禁用按钮

**验收标准**:
- ✅ 点击"开始测量"后，波形开始实时滚动
- ✅ 波形流畅（>= 25 FPS）
- ✅ 数据与原生 App 一致
- ✅ 停止测量正常工作

**预计时间**: 1 天

---

#### 📋 任务 1.4: Dashboard 页面集成设备信息 ✅ **部分完成**

**目标**: 在 Dashboard 显示真实设备信息（电量、版本、连接时间）。

**子任务**:
- [x] 调用 `RingPlatform.getDeviceInfo()` 获取设备信息 ✅
- [x] 调用 `RingPlatform.getBatteryLevel()` 获取电量 ✅
- [x] 更新 Dashboard UI 显示真实数据 ✅
- [x] 实现设备扫描功能 ✅
- [x] 实现设备连接功能 ✅
- [x] 显示连接状态 ✅
- [ ] 添加"同步时间"按钮（调用 `updateDeviceTime()`） ⏳
- [ ] 添加"校准时间"按钮（调用 `calibrateTime()`） ⏳

**验收标准**:
- ✅ Dashboard 显示真实设备名称 ✅
- ✅ 电量显示正确（带图标和百分比） ✅
- ⏳ 设备版本显示正确（需要实现 getDeviceInfo）
- ⏳ 时间同步功能正常（后续实现）

**预计时间**: 0.5 天  
**实际进度**: 已完成 70%（扫描+连接+基础信息显示）

---

### 阶段 2: 算法集成与生理指标计算（预计 2-3 天）

#### 📋 任务 2.1: 集成或迁移 VitalSignsProcessor

**方案 A: 保持原生算法（快速方案）**
- [ ] 在 MainActivity.kt 中调用现有 Java 的 `VitalSignsProcessor`
- [ ] 计算 HR/RR 后通过 EventChannel 发送 `VitalSignsUpdate` 事件
- [ ] Dart 侧直接显示结果

**方案 B: 迁移到 Dart（长期方案）**
- [ ] 创建 `lib/processors/vital_signs_processor.dart`
- [ ] 迁移滤波算法（带通滤波、低通滤波）
- [ ] 迁移峰值检测算法
- [ ] 迁移 HR/RR 计算逻辑
- [ ] 使用 Isolate 处理（避免阻塞 UI）
- [ ] 对比测试（Dart 版 vs Java 版，误差 < 5%）

**推荐**: 先使用方案 A 快速实现，后续优化时采用方案 B。

**验收标准**:
- ✅ 测量页面实时显示 HR/RR
- ✅ 信号质量指示器正常工作
- ✅ 数值合理（HR: 40-200 BPM, RR: 8-40 RPM）

**预计时间**: 方案 A: 0.5 天 | 方案 B: 2 天

---

#### 📋 任务 2.2: 信号质量评估与 UI 反馈

**目标**: 实现信号质量实时评估，并在 UI 上提供视觉反馈。

**子任务**:
- [ ] 实现信号质量算法（基于 PPG 幅值、波动、噪声）
- [ ] 定义 5 级质量等级（优秀/良好/一般/差/无信号）
- [ ] 更新 `_SignalQualityIndicator` 组件
- [ ] 根据质量显示不同颜色（绿/橙/红）
- [ ] 质量差时显示提示（"请调整佩戴位置"）

**验收标准**:
- ✅ 信号质量指示器实时更新
- ✅ 质量差时显示友好提示
- ✅ 视觉效果清晰直观

**预计时间**: 0.5 天

---

### 阶段 3: 离线录制功能实现（预计 4-5 天）

#### 📋 任务 3.1: Platform Channel 离线录制方法

**目标**: 在 MainActivity.kt 中实现离线录制相关方法。

**子任务**:
1. **启动离线录制**
   - [ ] 实现 `startOfflineRecording(totalDuration, segmentDuration, samplingMode, autoDisconnect)`
   - [ ] 调用 AAR 库发送录制命令到戒指
   - [ ] 发送 `RecordingStarted` 事件

2. **停止离线录制**
   - [ ] 实现 `stopOfflineRecording()`
   - [ ] 发送停止命令

3. **文件管理**
   - [ ] 实现 `getFileList()` - 获取戒指文件列表
   - [ ] 实现 `downloadFile(fileName)` - 下载文件到本地
   - [ ] 实现 `deleteFile(fileName)` - 删除戒指文件
   - [ ] 实现 `formatFileSystem()` - 格式化戒指存储

4. **事件通知**
   - [ ] 录制进度事件（`RecordingProgress`）
   - [ ] 录制完成事件（`RecordingCompleted`）
   - [ ] 文件下载进度事件（`FileDownloadProgress`）
   - [ ] 文件下载完成事件（`FileDownloadCompleted`）

**验收标准**:
- ✅ 可启动离线录制（戒指 LED 闪烁确认）
- ✅ 可获取文件列表
- ✅ 可下载文件到本地
- ✅ 事件正常触发

**预计时间**: 1-2 天

---

#### 📋 任务 3.2: 数据源抽象层实现

**目标**: 实现统一的数据源接口，支持在线/离线/本地文件三种模式。

**文件创建**:
1. **`lib/services/sensor_data_source.dart`** - 抽象接口
2. **`lib/services/live_ble_source.dart`** - 在线 BLE 数据源
3. **`lib/services/offline_recording_source.dart`** - 离线录制数据源
4. **`lib/services/local_file_source.dart`** - 本地文件数据源

**核心逻辑 - OfflineRecordingSource**:
```dart
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
  @override
  Future<void> start(SourceConfig config) async {
    // 1. 发送录制命令
    await _platform.startOfflineRecording(...);
    _phase = RecordingPhase.recording;
    
    // 2. 可选：自动断连省电
    if (config.autoDisconnect) {
      await Future.delayed(Duration(seconds: 2));
      await _platform.disconnect();
    }
    
    // 3. 设置自动下载定时器
    _scheduleAutoDownload(config.duration);
  }
  
  void _scheduleAutoDownload(int duration) {
    _timer = Timer(Duration(seconds: duration + 10), () async {
      _phase = RecordingPhase.waitingDownload;
      
      // 4. 重连戒指
      await _platform.connectDevice(savedMacAddress);
      
      // 5. 获取文件列表
      final files = await _platform.getFileList();
      
      // 6. 找到最新文件
      final latestFile = _findLatestFile(files);
      
      // 7. 下载文件
      await _platform.downloadFile(latestFile.fileName);
      
      // 8. 开始回放
      _phase = RecordingPhase.playingBack;
      await _playbackFile(latestFile.localPath);
    });
  }
  
  Future<void> _playbackFile(String filePath) async {
    final samples = await _parseFile(filePath);
    
    // 按时间戳模拟实时流
    for (var batch in _batchSamples(samples, 25)) {
      _sampleController.add(batch);
      await Future.delayed(Duration(milliseconds: 40)); // 25Hz
    }
  }
}
```

**子任务**:
- [ ] 实现 `SensorDataSource` 接口
- [ ] 实现 `LiveBleDataSource`（已基本完成）
- [ ] 实现 `OfflineRecordingDataSource`（核心）
- [ ] 实现 `LocalFileDataSource`（文件解析与回放）
- [ ] 实现文件解析逻辑（参考原 Java 代码格式）

**验收标准**:
- ✅ 可启动离线录制并断连
- ✅ 定时器触发自动下载
- ✅ 文件下载成功
- ✅ 回放正常，数据与原生一致

**预计时间**: 2-3 天

---

#### 📋 任务 3.3: 测量页面集成离线模式

**目标**: 在测量页面添加数据源选择器，支持切换在线/离线模式。

**子任务**:
1. **数据源选择器**
   - [ ] 更新 `_DataSourceSelector` 组件
   - [ ] 支持选择：实时测量（在线）、戒指录制（离线）、本地文件回放
   - [ ] 切换时更新 `currentDataSourceProvider`

2. **离线状态卡片**
   - [ ] 更新 `_OfflineStatusCard` 组件
   - [ ] 显示当前录制阶段（8 种状态）
   - [ ] 显示进度条（录制进度、下载进度）
   - [ ] 显示剩余时间
   - [ ] 添加"断开连接（省电）"按钮
   - [ ] 添加"立即下载"按钮

3. **配置对话框**
   - [ ] 创建录制配置对话框（总时长、分段时长、采样模式、自动断连）
   - [ ] 点击"开始测量"时根据数据源显示不同配置

**验收标准**:
- ✅ 可选择不同数据源
- ✅ 离线模式状态卡片正确显示
- ✅ 录制配置正常工作
- ✅ 断连后仍可显示状态

**预计时间**: 1 天

---

### 阶段 4: 文件管理与历史记录（预计 2-3 天）

#### 📋 任务 4.1: 文件管理功能

**目标**: 实现完整的文件管理功能（列表、下载、删除、回放）。

**子任务**:
- [ ] 创建文件列表页面（可在 Settings 或新建独立页面）
- [ ] 显示戒指文件列表（文件名、大小、日期）
- [ ] 实现下载功能（进度条显示）
- [ ] 实现删除功能（确认对话框）
- [ ] 实现回放功能（选择文件后跳转到测量页面）
- [ ] 实现格式化存储功能

**验收标准**:
- ✅ 可查看戒指文件列表
- ✅ 可下载文件到本地
- ✅ 可删除戒指文件
- ✅ 可回放本地文件

**预计时间**: 1-1.5 天

---

#### 📋 任务 4.2: 历史记录与数据持久化

**目标**: 保存测量记录到本地数据库，实现历史记录查看。

**子任务**:
1. **数据库设计**
   - [ ] 使用 `sqflite` 创建本地数据库
   - [ ] 设计表结构（MeasurementRecord 表）
   ```sql
   CREATE TABLE measurement_records (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     start_time INTEGER NOT NULL,
     end_time INTEGER,
     duration INTEGER,
     source_type TEXT NOT NULL,  -- 'live', 'offline', 'local_file'
     avg_heart_rate INTEGER,
     max_heart_rate INTEGER,
     min_heart_rate INTEGER,
     avg_respiratory_rate INTEGER,
     file_path TEXT,
     note TEXT
   );
   ```

2. **记录保存**
   - [ ] 测量结束时保存记录
   - [ ] 保存统计指标（HR/RR 平均值、最大最小值）
   - [ ] 关联文件路径（如果是离线/本地文件）

3. **历史页面完善**
   - [ ] 从数据库加载历史记录
   - [ ] 显示详细统计
   - [ ] 支持删除记录
   - [ ] 支持重新回放（点击记录跳转测量页面）

**验收标准**:
- ✅ 测量记录正确保存
- ✅ 历史页面显示真实数据
- ✅ 可查看详细统计
- ✅ 可重新回放历史记录

**预计时间**: 1-1.5 天

---

### 阶段 5: 后台任务与通知（预计 1-2 天）

#### 📋 任务 5.1: 后台任务与通知

**目标**: 实现离线录制完成后的后台下载与通知提醒。

**子任务**:
1. **本地通知**
   - [ ] 集成 `flutter_local_notifications`
   - [ ] 录制完成时发送通知（"离线采集已完成，可以下载了"）
   - [ ] 点击通知打开 App 并跳转到测量页面

2. **后台任务（可选）**
   - [ ] 集成 `workmanager`
   - [ ] 定时检查是否有待下载文件
   - [ ] 后台自动下载（需权限）

3. **状态持久化**
   - [ ] 使用 `shared_preferences` 保存离线录制状态
   - [ ] App 被杀后重启，恢复录制状态
   - [ ] 显示"有未完成的录制"提示

**验收标准**:
- ✅ 录制完成后收到通知
- ✅ 点击通知正确跳转
- ✅ App 重启后状态恢复

**预计时间**: 1-2 天

---

### 阶段 6: 性能优化与测试（预计 3-4 天）

#### 📋 任务 6.1: 性能优化

**优化目标**:
| 指标 | 目标 | 优化方案 |
|------|------|----------|
| 帧率 | >= 60 FPS | 降采样、批量绘制、使用 RepaintBoundary |
| 内存 | < 100 MB | 限制缓冲区大小、及时释放资源 |
| 启动时间 | < 2 秒 | 延迟加载、减少初始化 |
| BLE 延迟 | < 50 ms | 优化 Channel 通信、减少序列化开销 |

**子任务**:
- [ ] 使用 Flutter DevTools 分析性能瓶颈
- [ ] 优化波形绘制（降采样、仅绘制可见区域）
- [ ] 使用 Isolate 处理算法计算
- [ ] 减少不必要的 Widget 重建（使用 `const`、`ValueListenableBuilder`）
- [ ] 优化内存占用（限制样本缓冲区大小）

**验收标准**:
- ✅ 波形绘制 >= 60 FPS
- ✅ 内存占用 < 100 MB
- ✅ 启动时间 < 2 秒

**预计时间**: 1-2 天

---

#### 📋 任务 6.2: 测试与 Bug 修复

**测试场景**:
1. **功能测试**
   - [ ] 在线测量完整流程
   - [ ] 离线录制完整流程（启动→断连→下载→回放）
   - [ ] 本地文件回放
   - [ ] 文件管理（列表/下载/删除）
   - [ ] 历史记录查看

2. **异常场景测试**
   - [ ] 测量中途断连（在线模式）
   - [ ] 重连失败（离线模式）
   - [ ] 文件下载失败
   - [ ] App 被杀后恢复状态
   - [ ] 戒指电量耗尽

3. **兼容性测试**
   - [ ] 测试至少 3 款不同品牌 Android 手机
   - [ ] 测试不同 Android 版本（8.0, 10.0, 12.0, 14.0）

**验收标准**:
- ✅ 所有核心功能正常
- ✅ 异常场景有友好提示
- ✅ 无崩溃、无内存泄漏

**预计时间**: 1-2 天

---

### 阶段 7: 打包与发布（预计 1 天）

#### 📋 任务 7.1: 打包 APK

**子任务**:
- [ ] 配置签名密钥
- [ ] 优化 ProGuard 规则
- [ ] 生成 Release APK
  ```bash
  flutter build apk --release
  ```
- [ ] 测试 Release 版本

**验收标准**:
- ✅ APK 大小 < 50 MB
- ✅ Release 版本功能正常
- ✅ 无混淆导致的崩溃

**预计时间**: 0.5 天

---

## 🔮 后续优化阶段（V2.0）

> **说明**: 这些任务在第一版完成后进行，按优先级逐步实施

### 阶段 8: 算法迁移到 Dart（预计 5-7 天）

**目标**: 将 Java 版 VitalSignsProcessor 迁移到 Dart，实现跨平台支持

#### 📋 任务 8.1: Dart 算法实现

**子任务**:
1. **创建 Dart 版处理器**
   - [ ] 创建 `lib/processors/vital_signs_processor_dart.dart`
   - [ ] 实现带通滤波算法（Butterworth 或 IIR）
   - [ ] 实现峰值检测算法
   - [ ] 实现心率计算逻辑
   - [ ] 实现呼吸率计算逻辑

2. **Isolate 集成**
   - [ ] 创建独立 Isolate 处理算法（避免阻塞 UI）
   - [ ] 实现主线程与 Isolate 通信
   - [ ] 优化内存占用

3. **对比测试**
   - [ ] 使用相同测试数据对比 Java 版和 Dart 版
   - [ ] 确保误差 < 5%
   - [ ] 性能测试（CPU 占用、延迟）

**验收标准**:
- ✅ Dart 版算法与 Java 版结果一致（误差 < 5%）
- ✅ 性能可接受（CPU < 15%，延迟 < 100ms）
- ✅ 无 UI 卡顿

**预计时间**: 3-4 天

---

#### 📋 任务 8.2: 算法切换与配置

**目标**: 允许用户或开发者在 Java 和 Dart 算法间切换

**子任务**:
- [ ] 创建算法选择配置（开发者选项）
- [ ] 实现运行时切换逻辑
- [ ] 添加性能监控（对比两种算法）
- [ ] 文档化算法差异

**验收标准**:
- ✅ 可在设置中切换算法
- ✅ 切换无崩溃
- ✅ 性能对比数据清晰

**预计时间**: 1 天

---

#### 📋 任务 8.3: iOS 适配准备

**目标**: 为 iOS 平台准备算法基础

**子任务**:
- [ ] 验证 Dart 算法在 iOS 模拟器运行
- [ ] 创建 iOS Platform Channel（占位）
- [ ] 测试 iOS 真机性能

**验收标准**:
- ✅ iOS 可使用 Dart 算法计算 HR/RR
- ✅ 性能与 Android 相当

**预计时间**: 1-2 天

---

### 阶段 9: 后台任务与智能下载（预计 3-4 天）

**目标**: 实现离线录制完成后的自动下载与通知

#### 📋 任务 9.1: WorkManager 后台任务

**子任务**:
1. **集成 WorkManager**
   - [ ] 添加 `workmanager: ^0.5.2` 依赖
   - [ ] 配置 Android Manifest 权限
     ```xml
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
     <uses-permission android:name="android.permission.WAKE_LOCK" />
     ```
   - [ ] 创建后台任务处理器

2. **定时任务调度**
   - [ ] 录制启动时注册延时任务
   - [ ] 任务触发时自动连接戒指
   - [ ] 自动下载最新文件
   - [ ] 下载完成发送通知

3. **错误处理**
   - [ ] 连接失败重试机制（最多 3 次）
   - [ ] 重试间隔递增（1min → 5min → 15min）
   - [ ] 失败后降级为普通通知

**代码示例**:
```dart
// 注册后台任务
void scheduleAutoDownload(int durationMinutes) {
  Workmanager().registerOneOffTask(
    "download_${DateTime.now().millisecondsSinceEpoch}",
    "downloadOfflineData",
    initialDelay: Duration(minutes: durationMinutes + 2),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: true,
    ),
  );
}

// 后台任务执行
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. 连接戒指
      await RingPlatform.connectDevice(inputData['macAddress']);
      
      // 2. 获取文件列表
      final files = await RingPlatform.getFileList();
      final targetFile = _findLatestFile(files, inputData['timestamp']);
      
      // 3. 下载文件
      if (targetFile != null) {
        await RingPlatform.downloadFile(targetFile.fileName);
        await _showSuccessNotification();
        return true;
      }
    } catch (e) {
      await _showRetryNotification();
      return false;
    }
  });
}
```

**验收标准**:
- ✅ App 被杀后，后台任务仍能触发
- ✅ 自动下载成功率 > 90%
- ✅ 失败时有友好提示

**预计时间**: 2-3 天

---

#### 📋 任务 9.2: 智能下载策略

**目标**: 优化下载时机和策略

**子任务**:
- [ ] 检测设备是否在附近（RSSI 信号强度）
- [ ] WiFi 时优先下载（节省流量）
- [ ] 电量低时推迟下载
- [ ] 用户可自定义下载策略（立即/WiFi/手动）

**验收标准**:
- ✅ 下载策略可配置
- ✅ 省电模式下不会频繁唤醒
- ✅ 用户体验良好

**预计时间**: 1 天

---

### 阶段 10: iOS 平台支持（预计 2-3 周）

> **前提**: 阶段 8（Dart 算法）已完成

#### 📋 任务 10.1: iOS Platform Channel

**子任务**:
- [ ] 创建 iOS 端 MethodChannel 实现（Swift）
- [ ] 创建 iOS 端 EventChannel 实现
- [ ] 集成 iOS CoreBluetooth 框架
- [ ] 实现扫描/连接/断连逻辑

**预计时间**: 1 周

---

#### 📋 任务 10.2: iOS 功能适配

**子任务**:
- [ ] 实现在线测量
- [ ] 实现离线录制
- [ ] 实现文件管理
- [ ] iOS 权限配置（Info.plist）

**预计时间**: 1 周

---

#### 📋 任务 10.3: iOS 测试与优化

**子任务**:
- [ ] iPhone 真机测试（至少 3 款）
- [ ] 性能优化（内存、电量）
- [ ] UI 适配（刘海屏、动态岛）

**预计时间**: 3-5 天

---

## 📊 完整进度总览

### V1.0（基础版本）

| 阶段 | 预计时间 | 任务数 | 状态 |
|------|----------|--------|------|
| ✅ 阶段 0: 准备工作 | 3 天 | 3 | **已完成** |
| 🟡 阶段 1: Platform Channel 完善 | 3-4 天 | 4 | **进行中** |
| ⚪ 阶段 2: 算法集成（Java 版） | 2-3 天 | 2 | 待开始 |
| ⚪ 阶段 3: 离线录制 | 4-5 天 | 3 | 待开始 |
| ⚪ 阶段 4: 文件管理与历史 | 2-3 天 | 2 | 待开始 |
| ⚪ 阶段 5: 通知功能 | 1-2 天 | 1 | 待开始 |
| ⚪ 阶段 6: 性能优化与测试 | 3-4 天 | 2 | 待开始 |
| ⚪ 阶段 7: 打包发布 | 1 天 | 1 | 待开始 |
| **V1.0 小计** | **19-27 天 (~4-5 周)** | **18** | **进度 ~20%** |

### V2.0（后续优化）

| 阶段 | 预计时间 | 任务数 | 状态 |
|------|----------|--------|------|
| ⚪ 阶段 8: 算法迁移到 Dart | 5-7 天 | 3 | 计划中 |
| ⚪ 阶段 9: 后台任务与智能下载 | 3-4 天 | 2 | 计划中 |
| ⚪ 阶段 10: iOS 平台支持 | 2-3 周 | 3 | 计划中 |
| **V2.0 小计** | **3-4 周** | **8** | **待规划** |

### 总计

- **V1.0（Android 基础版）**: 19-27 天
- **V2.0（跨平台优化版）**: 额外 3-4 周
- **完整功能**: 约 2-2.5 个月

---

## 🎯 下一步行动（需用户确认）

### 立即执行（阶段 1）

**任务 1.1: 完善 MainActivity.kt**（优先级最高）
1. 验证现有扫描/连接功能
2. 实现 `startLiveMeasurement` 方法
3. 实现实时数据流解析
4. 发送 `SampleBatch` 事件到 Dart

**任务 1.2: 数据模型创建**
1. 创建 Freezed 模型（`ble_event.dart`, `sample.dart`, `device_info.dart`）
2. 运行 build_runner
3. 更新 Platform 接口

**任务 1.3: 测量页面数据集成**
1. 创建 Provider
2. 监听 EventStream
3. 更新波形显示

**预计完成时间**: 3-4 天

---

## ✅ 用户决策确认

1. **算法方案**（已确认）
   - ✅ **V1.0**: 使用 Java 算法（快速上线）
   - ✅ **V2.0**: 迁移到 Dart 算法（已添加到阶段 8）

2. **后台任务**（已确认）
   - ✅ **V1.0**: 仅通知功能（阶段 5）
   - ✅ **V2.0**: 完整后台任务（已添加到阶段 9）

3. **iOS 支持**（已确认）
   - ✅ **V1.0**: 仅 Android
   - ✅ **V2.0**: iOS 支持（已添加到阶段 10，前提是 Dart 算法完成）

---

## 📝 备注

- 本路线图基于当前已完成的 UI 框架和 Platform Channel 基础
- 时间估算假设每天有效工作时间 6-8 小时
- 实际开发中可能根据具体情况调整优先级
- 关键路径：阶段 1 → 阶段 3（离线录制是核心创新功能）

---

**准备好开始阶段 1 了吗？请回复 "ok" 确认，我将立即开始执行！** 🚀

