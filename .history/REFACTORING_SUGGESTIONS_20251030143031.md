# Android Ring App 重构建议：消除在线/离线测试冗余

## 背景理解

- **在线测试（Online Mode）**：戒指通过蓝牙实时传输数据到手机，手机端实时处理与显示
- **离线测试（Offline Mode）**：戒指自主采集并存储数据（可断连），之后通过蓝牙回读到手机

### 戒指硬件能力（重要）
- ✅ 支持断连后持续采集 PPG 信号
- ✅ 内置存储（Flash）可保存多个测量会话
- ✅ 支持定时启动/停止采集（如"运动模式"：总时长 300 秒，每段 60 秒）
- ✅ 断连期间无需手机干预，戒指独立工作

### 当前问题
两种模式共用相同的 UI、数据处理（`VitalSignsProcessor`）、绘图（`PlotView`）、文件保存逻辑，但在代码中存在大量重复的控制流与状态标志。

### 用户场景差异

| 场景 | 在线模式 | 离线模式 |
|------|----------|----------|
| 手机依赖 | 必须保持连接 | 可断连（仅启动/下载时需要） |
| 实时反馈 | 有（HR/RR 实时显示） | 无（事后分析） |
| 电池消耗 | 手机高（持续蓝牙+处理） | 手机低（仅下载时连接） |
| 适用场景 | 短时测试、调试算法 | 长时运动、睡眠监测 |
| 数据完整性 | 依赖连接稳定性 | 高（存储在戒指端） |

---

## 核心问题分析

### 1. 重复的状态管理
```java
// MainActivity.java
private boolean isMeasuring = false;         // 在线测试状态
private boolean isOfflineRecording = false;  // 离线测试状态
private boolean isRecording = false;         // 录制状态
private boolean isExercising = false;        // 运动状态
```

这些布尔标志导致：
- 状态机复杂，容易出现不一致
- 同一个操作（如"开始测量"）需要判断当前模式
- 测试/录制/运动控制逻辑散布在多处

### 2. 重复的 UI 控件与回调
```java
// 在线测试按钮
private Button startMeasurementButton;
private Button stopMeasurementButton;

// 运动控制按钮（实际也是在线/离线模式的变体）
private Button startExerciseButton;
private Button stopExerciseButton;

// 文件下载（离线模式专用）
private Button downloadSelectedButton;
private Button downloadAllButton;
```

### 3. 数据处理路径重复
- **在线模式**：`BLEService` → `NotificationHandler` → `VitalSignsProcessor` → UI
- **离线模式**：戒指存储 → `downloadFile` → 解析 → `VitalSignsProcessor` → UI

两条路径最终都调用相同的 `VitalSignsProcessor` 和 `PlotView`，但中间处理分叉。

---

## 统一架构设计

### 方案一：数据源抽象（推荐，低侵入）

#### 1. 定义统一数据源接口

```java
/**
 * 统一的传感器数据源接口
 * 在线/离线/回放共用同一接口
 */
public interface SensorDataSource {
    
    enum SourceType { LIVE_BLE, OFFLINE_FILE, SIMULATED }
    
    /**
     * 启动数据流
     * @param config 启动配置（设备ID/文件路径/回放速率等）
     */
    void start(SourceConfig config, DataListener listener);
    
    /**
     * 停止数据流
     */
    void stop();
    
    /**
     * 暂停/恢复（仅回放模式支持）
     */
    void pause();
    void resume();
    
    /**
     * 获取当前状态
     */
    SourceState getState();
    
    /**
     * 获取数据源类型
     */
    SourceType getType();
    
    /**
     * 数据监听器
     */
    interface DataListener {
        void onSampleBatch(SampleBatch batch);  // 批量样本
        void onStateChanged(SourceState state);  // 状态变化
        void onError(Throwable error);
    }
    
    enum SourceState { IDLE, STARTING, STREAMING, PAUSED, STOPPED, ERROR }
}

/**
 * 统一的样本批次结构
 */
public class SampleBatch {
    public long timestampUs;         // 微秒时间戳
    public List<Sample> samples;     // 样本列表
    public SourceMetadata metadata;  // 元数据（采样率、通道映射等）
}

public class Sample {
    public long green, red, ir;      // PPG 通道
    public short accX, accY, accZ;   // 加速度
    public short gyroX, gyroY, gyroZ; // 陀螺仪
    public short temp0, temp1, temp2; // 温度
}
```

#### 2. 实现三种数据源

**在线 BLE 数据源**
```java
public class LiveBleDataSource implements SensorDataSource {
    private final BLEService bleService;
    private DataListener listener;
    
    @Override
    public void start(SourceConfig config, DataListener listener) {
        this.listener = listener;
        // 订阅 BLE 通知，适配现有 NotificationHandler
        NotificationHandler.setDataCallback(rawData -> {
            SampleBatch batch = parseBleData(rawData);
            listener.onSampleBatch(batch);
        });
        // 发送在线测试启动命令
        sendStartCommand(config.getMeasurementTime());
    }
    
    @Override
    public SourceType getType() { return SourceType.LIVE_BLE; }
}
```

**离线文件回放数据源**
```java
public class OfflineFileDataSource implements SensorDataSource {
    private final File sourceFile;
    private PlaybackThread playbackThread;
    
    @Override
    public void start(SourceConfig config, DataListener listener) {
        // 从戒指下载文件（复用现有 downloadFile 逻辑）
        downloadFileFromRing(config.getFileName(), downloadedFile -> {
            // 按时间戳重放文件内容
            playbackThread = new PlaybackThread(downloadedFile, listener, config.getPlaybackSpeed());
            playbackThread.start();
        });
    }
    
    @Override
    public void pause() { playbackThread.pause(); }
    @Override
    public void resume() { playbackThread.resume(); }
}
```

**本地文件回放数据源（用于调试/演示）**
```java
public class LocalFileDataSource implements SensorDataSource {
    // 从已下载的本地文件读取并回放
}
```

#### 3. 统一会话管理器

```java
/**
 * 测量会话管理器
 * 统一管理在线/离线测试的生命周期
 */
public class MeasurementSession {
    
    private SensorDataSource currentSource;
    private SessionState state = SessionState.IDLE;
    private VitalSignsProcessor processor;
    private FileRecorder recorder;  // 可选：录制到本地
    
    public enum SessionState { IDLE, PREPARING, RUNNING, PAUSED, STOPPED }
    
    /**
     * 开始测量会话
     */
    public void start(SensorDataSource source, SessionConfig config) {
        if (state != SessionState.IDLE) {
            throw new IllegalStateException("Session already active");
        }
        
        this.currentSource = source;
        this.state = SessionState.PREPARING;
        
        // 启动录制（可选）
        if (config.shouldRecord()) {
            recorder = new FileRecorder(config.getRecordPath());
        }
        
        // 启动数据源
        source.start(config.toSourceConfig(), new SensorDataSource.DataListener() {
            @Override
            public void onSampleBatch(SampleBatch batch) {
                // 统一处理：录制 + 实时分析
                if (recorder != null) {
                    recorder.write(batch);
                }
                processor.processBatch(batch);
            }
            
            @Override
            public void onStateChanged(SourceState sourceState) {
                updateSessionState(sourceState);
            }
            
            @Override
            public void onError(Throwable error) {
                handleError(error);
            }
        });
        
        state = SessionState.RUNNING;
    }
    
    public void stop() {
        if (currentSource != null) {
            currentSource.stop();
        }
        if (recorder != null) {
            recorder.close();
        }
        state = SessionState.STOPPED;
    }
    
    public boolean isActive() { return state == SessionState.RUNNING; }
    public SensorDataSource.SourceType getSourceType() { 
        return currentSource != null ? currentSource.getType() : null; 
    }
}
```

#### 4. 简化 MainActivity

```java
public class MainActivity extends AppCompatActivity {
    
    private MeasurementSession session;
    
    // ===== 统一后的控件（不再区分在线/离线）=====
    private Button startButton;
    private Button stopButton;
    private Spinner dataSourc<Spinner;  // 在线/离线/本地文件选择
    
    private void startMeasurement() {
        // 根据用户选择创建数据源
        SensorDataSource source;
        String selection = dataSourceSpinner.getSelectedItem().toString();
        
        switch (selection) {
            case "实时测量（在线）":
                source = new LiveBleDataSource(bleService);
                break;
            case "戒指录制回读（离线）":
                // 弹出文件选择对话框
                source = new OfflineFileDataSource(selectedRingFile);
                break;
            case "本地文件回放":
                source = new LocalFileDataSource(selectedLocalFile);
                break;
            default:
                Toast.makeText(this, "请选择数据源", Toast.LENGTH_SHORT).show();
                return;
        }
        
        // 统一启动流程
        SessionConfig config = new SessionConfig.Builder()
                .setMeasurementTime(60)
                .setShouldRecord(recordCheckbox.isChecked())
                .setRecordPath(getRecordPath())
                .build();
        
        session.start(source, config);
        updateUI(true);
    }
    
    private void stopMeasurement() {
        session.stop();
        updateUI(false);
    }
    
    private void updateUI(boolean measuring) {
        startButton.setEnabled(!measuring);
        stopButton.setEnabled(measuring);
        // 统一的状态文本
        statusText.setText(measuring ? 
                "测量中 (" + session.getSourceType() + ")" : 
                "就绪");
    }
}
```

---

### 方案二：模式切换器（中等侵入）

保留现有代码结构，但用策略模式封装在线/离线差异：

```java
/**
 * 测量模式策略接口
 */
public interface MeasurementMode {
    void startMeasurement(int duration);
    void stopMeasurement();
    void onDataReceived(byte[] data);
    String getModeName();
}

public class OnlineMode implements MeasurementMode {
    @Override
    public void startMeasurement(int duration) {
        // 发送在线测试命令
    }
}

public class OfflineMode implements MeasurementMode {
    @Override
    public void startMeasurement(int duration) {
        // 发送离线录制启动命令到戒指
    }
    
    @Override
    public void stopMeasurement() {
        // 停止录制 → 下载文件 → 回放
    }
}

// MainActivity 中切换模式
private MeasurementMode currentMode = new OnlineMode();

private void onModeSwitch(String mode) {
    currentMode = mode.equals("在线") ? new OnlineMode() : new OfflineMode();
}
```

---

## 渐进式重构步骤（推荐）

### 阶段 1：抽象数据流（1-2 天）
1. 定义 `SensorDataSource` 接口与 `SampleBatch` 数据结构
2. 实现 `LiveBleDataSource`，把现有 `NotificationHandler` 适配进去
3. 修改 `VitalSignsProcessor` 输入为 `SampleBatch`（当前已接近此结构）

### 阶段 2：统一会话管理（2-3 天）
1. 实现 `MeasurementSession` 管理器
2. 重构 `MainActivity` 的开始/停止逻辑，使用 `MeasurementSession`
3. 删除冗余的 `isMeasuring`、`isOfflineRecording` 等标志

### 阶段 3：实现离线数据源（2-3 天）
1. 实现 `OfflineFileDataSource`，复用现有文件下载逻辑
2. 解析戒指文件格式为 `SampleBatch`
3. 支持回放控制（播放/暂停/倍速）

### 阶段 4：UI 合并与清理（1-2 天）
1. 合并在线/离线测试页面为统一的"测量"页
2. 用下拉选择器或底部工具栏切换数据源
3. 删除重复的按钮与控件
4. 更新权限请求逻辑（在线模式才需要 BLE 权限）

### 阶段 5：录制功能装饰器（1 天）
```java
public class RecordingDataSource implements SensorDataSource {
    private final SensorDataSource upstream;
    private final FileWriter writer;
    
    @Override
    public void start(SourceConfig config, DataListener listener) {
        upstream.start(config, batch -> {
            writer.write(batch);  // 顺手录制
            listener.onSampleBatch(batch);  // 透传给下游
        });
    }
}
```

---

## 文件格式统一建议

### 当前问题
- 戒指端文件格式（`.bin` 或专有格式）
- 手机端保存格式（当前用 CSV + Hex 字符串）
- 没有统一的元数据头

### 建议格式

**选项 A：简单 CSV（易读，体积大）**
```csv
# Metadata
device_id,ABC123
firmware_version,1.0.81
sampling_rate,25
start_time_utc,2024-10-30T10:23:45.123Z
channels,green,red,ir,accX,accY,accZ,gyroX,gyroY,gyroZ,temp0,temp1,temp2

# Data
timestamp_us,green,red,ir,accX,accY,accZ,gyroX,gyroY,gyroZ,temp0,temp1,temp2
1698668625123456,12345,23456,34567,100,-50,980,10,-5,2,3200,3210,3205
...
```

**选项 B：二进制 + JSON 头（紧凑，高效）**
```
[JSON Header: 256 bytes]
{
  "version": "1.0",
  "device_id": "ABC123",
  "sampling_rate": 25,
  "start_time_utc": "2024-10-30T10:23:45.123Z",
  "channels": ["green", "red", "ir", "accX", "accY", "accZ", ...],
  "data_offset": 256,
  "sample_count": 15000
}

[Binary Data]
每个样本 48 字节：
- timestamp (8 bytes, uint64)
- green, red, ir (4 bytes each, uint32)
- accX, accY, accZ (2 bytes each, int16)
- gyroX, gyroY, gyroZ (2 bytes each, int16)
- temp0, temp1, temp2 (2 bytes each, int16)
```

### 解析器示例
```java
public class UnifiedFileParser {
    public static SampleBatch parseFile(File file) {
        // 自动检测格式（CSV 或二进制）
        if (isBinaryFormat(file)) {
            return parseBinary(file);
        } else {
            return parseCsv(file);
        }
    }
}
```

---

## 与 Flutter 迁移的关联

重构后的架构直接映射到 Flutter：

```dart
// Dart 侧接口
abstract class SensorDataSource {
  Stream<SampleBatch> get dataStream;
  Future<void> start(SourceConfig config);
  Future<void> stop();
}

class LiveBleDataSource implements SensorDataSource {
  final MethodChannel _channel;
  // 通过 Platform Channel 调用原生 BLE
}

class FilePlaybackDataSource implements SensorDataSource {
  final File sourceFile;
  // 纯 Dart 实现文件解析与回放
}

// UI 层统一
class MeasurementPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column([
      DataSourceSelector(),  // 在线/离线/本地文件
      StartStopButton(),
      RealTimePlot(),
    ]);
  }
}
```

---

## 预期收益

### 代码质量
- **减少 30-40% 重复代码**（估算：300-400 行）
- 状态管理简化为单一 `SessionState`
- 测试覆盖率提升（数据源可模拟）

### 可维护性
- 新增数据源只需实现 `SensorDataSource` 接口
- 算法优化只需修改 `VitalSignsProcessor`，不影响数据来源
- UI 与数据解耦，方便 A/B 测试不同界面

### 用户体验
- 统一的操作流程（不再区分"在线测试"和"离线下载"两个入口）
- 支持本地文件回放（调试、演示、二次分析）
- 断线后可无缝切换到本地文件继续查看

---

## 风险与注意事项

1. **戒指固件协议依赖**
   - 离线模式需要戒指支持"启动录制"命令
   - 如果戒指只能被动存储，需适配为"定时下载"模式

2. **文件格式兼容性**
   - 需逆向工程戒指 `.bin` 文件格式或查阅 SDK 文档
   - 建议先用十六进制编辑器分析几个样本文件

3. **性能瓶颈**
   - 文件回放时需控制速率（实时倍速），避免 UI 卡顿
   - 大文件（>10MB）考虑分块加载

4. **权限管理**
   - 在线模式需要 BLE 权限，离线/回放不需要
   - 动态申请权限，避免用户困惑

---

## 实施建议

### 优先级
**高优先级**（先做）：
- 数据源接口定义
- 在线数据源适配
- 会话管理器
- UI 合并

**中优先级**（可延后）：
- 离线文件解析
- 回放控制（暂停/倍速）
- 录制装饰器

**低优先级**（可选）：
- 本地文件格式转换工具
- 批量分析脚本

### 测试策略
1. **单元测试**：`VitalSignsProcessor` 输入输出验证
2. **集成测试**：模拟数据源 → 处理器 → UI 全链路
3. **真机测试**：在线模式 + 离线模式对比结果一致性

---

## 总结

当前架构的核心问题是"在线/离线"在**UI 层与业务逻辑层耦合**，导致重复代码与复杂状态管理。

**推荐方案**：
1. 引入 `SensorDataSource` 接口，统一数据来源抽象
2. 用 `MeasurementSession` 管理会话生命周期
3. 合并 UI 页面，用数据源选择器区分模式
4. 文件格式标准化，支持本地回放

**最小可行实施**（1 周内落地）：
- 定义接口 + 适配现有在线逻辑
- 重构 `MainActivity` 用会话管理器
- 合并在线/离线按钮为统一"开始测量"

此方案对现有代码侵入性小，可渐进式实施，且为后续 Flutter 迁移奠定良好基础。

