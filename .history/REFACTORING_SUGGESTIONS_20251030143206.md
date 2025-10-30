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

**离线采集数据源（Ring-Initiated Recording）**
```java
public class OfflineRecordingDataSource implements SensorDataSource {
    private final BLEService bleService;
    private RecordingState state = RecordingState.IDLE;
    
    enum RecordingState {
        IDLE,           // 空闲
        SCHEDULING,     // 发送启动命令到戒指
        RECORDING,      // 戒指正在采集（可断连）
        DOWNLOADING,    // 从戒指下载文件
        PLAYING_BACK    // 本地回放
    }
    
    @Override
    public void start(SourceConfig config, DataListener listener) {
        state = RecordingState.SCHEDULING;
        
        // 1. 向戒指发送"离线采集"命令
        //    参数：总时长、分段时长、采样模式
        byte[] cmd = buildOfflineRecordingCommand(
            config.getTotalDuration(),    // 如 300 秒
            config.getSegmentDuration(),  // 如 60 秒/段
            config.getSamplingMode()      // PPG+ACC / PPG+ACC+Gyro / etc.
        );
        bleService.sendCommand(cmd);
        
        // 2. 等待戒指确认并开始采集
        bleService.setResponseListener(response -> {
            if (response.isSuccess()) {
                state = RecordingState.RECORDING;
                
                // 3. 通知用户可以断连了
                listener.onStateChanged(SourceState.STREAMING);
                showNotification("戒指正在采集，可安全断开连接");
                
                // 4. 可选：断开蓝牙以节省手机电量
                if (config.shouldDisconnectAfterStart()) {
                    bleService.disconnect();
                }
                
                // 5. 设置定时器：预计完成时间到后自动重连并下载
                scheduleAutoDownload(config.getTotalDuration(), listener);
            }
        });
    }
    
    /**
     * 定时自动下载（用户体验优化）
     */
    private void scheduleAutoDownload(int duration, DataListener listener) {
        Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(() -> {
            // 采集预计完成，尝试重连并下载
            if (state == RecordingState.RECORDING) {
                downloadLatestFile(listener);
            }
        }, duration * 1000 + 10000); // 加 10 秒缓冲
    }
    
    /**
     * 从戒指下载最新文件并回放
     */
    public void downloadLatestFile(DataListener listener) {
        state = RecordingState.DOWNLOADING;
        
        // 1. 重连戒指（如果已断连）
        bleService.reconnect(() -> {
            // 2. 获取文件列表
            bleService.getFileList(files -> {
                // 3. 找到最新文件（根据时间戳）
                FileInfo latestFile = files.stream()
                    .max(Comparator.comparing(f -> f.timestamp))
                    .orElse(null);
                
                if (latestFile != null) {
                    // 4. 下载文件
                    bleService.downloadFile(latestFile.fileName, downloadedFile -> {
                        state = RecordingState.PLAYING_BACK;
                        
                        // 5. 回放文件
                        playbackFile(downloadedFile, listener);
                    });
                }
            });
        });
    }
    
    /**
     * 本地文件回放
     */
    private void playbackFile(File file, DataListener listener) {
        PlaybackThread thread = new PlaybackThread(file, listener);
        thread.start();
    }
    
    @Override
    public void stop() {
        if (state == RecordingState.RECORDING) {
            // 向戒指发送"停止采集"命令
            bleService.sendCommand(buildStopRecordingCommand());
        } else if (state == RecordingState.PLAYING_BACK) {
            // 停止回放
            playbackThread.interrupt();
        }
        state = RecordingState.IDLE;
    }
    
    @Override
    public SourceType getType() { return SourceType.OFFLINE_RECORDING; }
}
```

**关键特性**：
- **启动后可断连**：发送命令后，戒指独立工作
- **自动提醒下载**：采集完成后通知用户重连
- **无缝体验**：下载完自动进入回放模式
- **手机省电**：采集期间手机可锁屏/关闭蓝牙

**本地文件回放数据源（用于调试/演示）**
```java
public class LocalFileDataSource implements SensorDataSource {
    private final File localFile;
    private PlaybackThread thread;
    
    @Override
    public void start(SourceConfig config, DataListener listener) {
        // 直接从本地文件回放，无需连接戒指
        thread = new PlaybackThread(localFile, listener, config.getPlaybackSpeed());
        thread.start();
    }
    
    @Override
    public void pause() { thread.pause(); }
    @Override
    public void resume() { thread.resume(); }
    @Override
    public void seek(long timestamp) { thread.seekTo(timestamp); }
}
```

---

## 离线模式专项优化（基于断连能力）

### 问题：当前离线模式的局限

查看现有代码（`MainActivity.java` 1114-1195 行），发现"运动控制"功能实际就是离线模式的变体：

```java
private void startExercise() {
    int totalDuration = Integer.parseInt(exerciseTotalDurationInput.getText());
    int segmentDuration = Integer.parseInt(exerciseSegmentDurationInput.getText());
    
    NotificationHandler.setExerciseParams(totalDuration, segmentDuration);
    NotificationHandler.startExercise();  // 向戒指发命令
    
    // 问题1：启动后必须保持连接？
    // 问题2：如何知道采集完成？
    // 问题3：如何自动下载结果？
}
```

### 方案：离线模式生命周期管理器

```java
/**
 * 离线采集会话管理器
 * 处理"启动 → 断连 → 等待 → 重连 → 下载 → 回放"完整流程
 */
public class OfflineRecordingSession {
    
    private RecordingPhase phase = RecordingPhase.IDLE;
    private long estimatedEndTime = 0;
    private Timer autoDownloadTimer;
    
    enum RecordingPhase {
        IDLE,               // 0. 空闲
        CONFIGURING,        // 1. 配置参数
        STARTING,           // 2. 发送启动命令
        RECORDING,          // 3. 戒指采集中（可断连）
        WAITING_DOWNLOAD,   // 4. 等待下载（采集已完成）
        DOWNLOADING,        // 5. 下载文件中
        READY_FOR_PLAYBACK, // 6. 文件已下载，可回放
        PLAYING_BACK        // 7. 回放中
    }
    
    /**
     * 启动离线采集
     */
    public void startRecording(RecordingConfig config, SessionCallback callback) {
        phase = RecordingPhase.STARTING;
        
        // 1. 发送离线采集命令到戒指
        byte[] cmd = buildCommand(config);
        bleService.sendCommand(cmd, response -> {
            if (response.isSuccess()) {
                phase = RecordingPhase.RECORDING;
                
                // 2. 记录预计完成时间
                estimatedEndTime = System.currentTimeMillis() + config.duration * 1000;
                
                // 3. 显示通知
                showNotification(
                    "戒指正在采集",
                    String.format("预计 %d 分钟后完成，期间可断开连接", config.duration / 60),
                    createDisconnectAction()
                );
                
                // 4. 可选：自动断开以省电
                if (config.autoDisconnect) {
                    bleService.disconnect();
                    callback.onDisconnected("已断开连接，戒指将继续采集");
                }
                
                // 5. 设置自动下载定时器
                scheduleAutoDownload(config.duration, callback);
                
                callback.onRecordingStarted(estimatedEndTime);
            }
        });
    }
    
    /**
     * 定时器：采集完成后自动尝试下载
     */
    private void scheduleAutoDownload(int duration, SessionCallback callback) {
        autoDownloadTimer = new Timer();
        autoDownloadTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                phase = RecordingPhase.WAITING_DOWNLOAD;
                
                // 显示通知：采集完成，可以下载了
                showDownloadReadyNotification(() -> {
                    downloadAndPlayback(callback);
                });
                
                // 如果用户在附近（手机屏幕亮着），自动尝试下载
                if (isUserPresent()) {
                    autoDownloadWithRetry(callback);
                }
            }
        }, duration * 1000 + 10000); // 加 10 秒缓冲
    }
    
    /**
     * 自动重连并下载（带重试）
     */
    private void autoDownloadWithRetry(SessionCallback callback) {
        int maxRetries = 3;
        int retryInterval = 60000; // 1 分钟
        
        attemptDownload(0, maxRetries, retryInterval, callback);
    }
    
    private void attemptDownload(int attempt, int maxRetries, int interval, SessionCallback callback) {
        if (attempt >= maxRetries) {
            callback.onError("自动下载失败，请手动重连戒指");
            return;
        }
        
        // 尝试重连
        bleService.reconnect(success -> {
            if (success) {
                downloadLatestFile(callback);
            } else {
                // 重试
                callback.onRetrying(attempt + 1, maxRetries);
                new Handler().postDelayed(() -> {
                    attemptDownload(attempt + 1, maxRetries, interval, callback);
                }, interval);
            }
        });
    }
    
    /**
     * 下载最新文件并准备回放
     */
    public void downloadAndPlayback(SessionCallback callback) {
        phase = RecordingPhase.DOWNLOADING;
        callback.onDownloadStarted();
        
        bleService.getFileList(files -> {
            // 找到最接近预期时间的文件
            FileInfo targetFile = findLatestRecording(files, estimatedEndTime);
            
            if (targetFile == null) {
                callback.onError("未找到对应的录制文件");
                return;
            }
            
            bleService.downloadFile(targetFile.fileName, 
                // 进度回调
                progress -> callback.onDownloadProgress(progress),
                // 完成回调
                downloadedFile -> {
                    phase = RecordingPhase.READY_FOR_PLAYBACK;
                    callback.onDownloadComplete(downloadedFile);
                    
                    // 自动开始回放
                    startPlayback(downloadedFile, callback);
                }
            );
        });
    }
    
    /**
     * 回放下载的文件
     */
    public void startPlayback(File file, SessionCallback callback) {
        phase = RecordingPhase.PLAYING_BACK;
        
        LocalFileDataSource playback = new LocalFileDataSource(file);
        playback.start(new SourceConfig(), batch -> {
            callback.onDataBatch(batch);
        });
    }
    
    /**
     * 检查是否有待下载的录制
     */
    public boolean hasPendingRecording() {
        return phase == RecordingPhase.RECORDING || 
               phase == RecordingPhase.WAITING_DOWNLOAD;
    }
    
    /**
     * 获取录制状态摘要（用于 UI 显示）
     */
    public RecordingStatus getStatus() {
        long now = System.currentTimeMillis();
        long remaining = Math.max(0, estimatedEndTime - now);
        
        return new RecordingStatus(
            phase,
            remaining,
            getRemainingPercentage(),
            getPhaseDescription()
        );
    }
    
    interface SessionCallback {
        void onRecordingStarted(long estimatedEndTime);
        void onDisconnected(String reason);
        void onDownloadStarted();
        void onDownloadProgress(float progress);
        void onDownloadComplete(File file);
        void onDataBatch(SampleBatch batch);
        void onRetrying(int attempt, int maxAttempts);
        void onError(String message);
    }
}
```

### UI 改进：离线模式状态卡片

```xml
<!-- activity_main.xml 中添加离线状态卡片 -->
<androidx.cardview.widget.CardView
    android:id="@+id/offlineStatusCard"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:visibility="gone">
    
    <LinearLayout android:orientation="vertical">
        <!-- 状态图标 -->
        <ImageView 
            android:id="@+id/offlineStatusIcon"
            android:src="@drawable/ic_ring_recording"/>
        
        <!-- 阶段描述 -->
        <TextView 
            android:id="@+id/offlinePhaseText"
            android:text="戒指正在采集数据"/>
        
        <!-- 进度条 -->
        <ProgressBar
            android:id="@+id/offlineProgressBar"
            style="?android:attr/progressBarStyleHorizontal"/>
        
        <!-- 剩余时间 -->
        <TextView
            android:id="@+id/offlineRemainingTime"
            android:text="预计剩余 12 分钟"/>
        
        <!-- 操作按钮 -->
        <LinearLayout android:orientation="horizontal">
            <Button 
                android:id="@+id/disconnectButton"
                android:text="断开连接（省电）"/>
            
            <Button
                android:id="@+id/downloadNowButton"
                android:text="立即下载"
                android:enabled="false"/>
        </LinearLayout>
    </LinearLayout>
</androidx.cardview.widget.CardView>
```

```java
// MainActivity.java 中更新 UI
private void updateOfflineStatusCard() {
    RecordingStatus status = offlineSession.getStatus();
    
    switch (status.phase) {
        case RECORDING:
            offlineStatusCard.setVisibility(View.VISIBLE);
            offlinePhaseText.setText("戒指正在采集数据");
            offlineProgressBar.setProgress(status.progressPercent);
            offlineRemainingTime.setText(formatDuration(status.remainingMs));
            disconnectButton.setEnabled(bleService.isConnected());
            downloadNowButton.setEnabled(false);
            break;
            
        case WAITING_DOWNLOAD:
            offlinePhaseText.setText("采集完成，可以下载了");
            offlineProgressBar.setProgress(100);
            offlineRemainingTime.setText("点击下载按钮获取数据");
            disconnectButton.setEnabled(false);
            downloadNowButton.setEnabled(true);
            // 播放提示音或震动
            vibrate();
            break;
            
        case DOWNLOADING:
            offlinePhaseText.setText("正在下载文件");
            offlineProgressBar.setProgress(status.downloadProgress);
            downloadNowButton.setEnabled(false);
            break;
            
        case PLAYING_BACK:
            offlinePhaseText.setText("正在回放数据");
            offlineStatusCard.setVisibility(View.GONE);
            break;
            
        default:
            offlineStatusCard.setVisibility(View.GONE);
    }
}
```

### 用户体验流程（完整示例）

```
用户操作                     系统行为                          UI 提示
───────────────────────────────────────────────────────────────
1. 选择"离线采集"          显示配置面板                      
   设置时长 300 秒          - 总时长
   设置分段 60 秒            - 分段时长
                           - 采样模式选择

2. 点击"开始采集"          向戒指发送命令                    "正在启动..."
                           ↓
                           戒指确认并开始采集                 "采集已启动"
                           ↓
                           显示状态卡片                       [卡片出现]
                           - 进度条: 0%
                           - 剩余: 5 分钟
                           - [断开连接] 按钮

3. 点击"断开连接"          断开蓝牙                          "已断开，戒指继续采集"
   或自然断连               保持后台定时器                    通知常驻

4. 用户做其他事情          ...等待 5 分钟...                 [通知显示进度]
   （可锁屏/关机）          

5. 采集完成                播放提示音                        "采集完成！"
   （5 分钟后）            显示通知                          "点击下载数据"
                           
6. 用户打开 App            自动尝试重连                      "正在重连..."
   或点击通知               ↓
                           连接成功                          "正在下载..."
                           ↓
                           下载文件                          进度条: 45%
                           ↓
                           下载完成                          "开始回放"

7. 自动回放                解析文件                          波形绘制
                           调用 VitalSignsProcessor          HR: 75 BPM
                           显示实时结果                       RR: 15 RPM

8. 用户查看历史数据        可暂停/快进/倍速                  回放控制栏
```

### 持久化状态（应对 App 被杀或手机重启）

```java
public class OfflineRecordingPersistence {
    private SharedPreferences prefs;
    
    /**
     * 保存录制状态
     */
    public void saveState(OfflineRecordingSession session) {
        prefs.edit()
            .putString("phase", session.getPhase().name())
            .putLong("estimated_end_time", session.getEstimatedEndTime())
            .putString("recording_id", session.getRecordingId())
            .putBoolean("has_pending", true)
            .apply();
    }
    
    /**
     * 恢复录制状态（App 重启时）
     */
    public OfflineRecordingSession restoreState() {
        if (!prefs.getBoolean("has_pending", false)) {
            return null;
        }
        
        RecordingPhase phase = RecordingPhase.valueOf(
            prefs.getString("phase", "IDLE")
        );
        long estimatedEndTime = prefs.getLong("estimated_end_time", 0);
        
        // 检查是否已过期
        if (System.currentTimeMillis() < estimatedEndTime) {
            // 采集尚未完成，恢复定时器
            return OfflineRecordingSession.restore(phase, estimatedEndTime);
        } else {
            // 采集已完成，提示下载
            showDownloadPendingNotification();
            return OfflineRecordingSession.restore(
                RecordingPhase.WAITING_DOWNLOAD, 
                estimatedEndTime
            );
        }
    }
}

// MainActivity.onCreate 中
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    
    // 恢复离线录制会话（如果有）
    OfflineRecordingSession restoredSession = persistence.restoreState();
    if (restoredSession != null) {
        offlineSession = restoredSession;
        updateOfflineStatusCard();
        
        // 如果已完成，自动尝试下载
        if (restoredSession.getPhase() == RecordingPhase.WAITING_DOWNLOAD) {
            showDialog("有待下载的录制数据", "是否立即下载？", 
                () -> offlineSession.downloadAndPlayback(callback)
            );
        }
    }
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

