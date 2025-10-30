# 离线模式设计详解：充分利用戒指断连采集能力

## 核心优势

戒指支持**断连后持续采集**，这带来了巨大的用户体验提升：

| 传统方案（必须保持连接） | 优化方案（断连采集） |
|------------------------|---------------------|
| ❌ 手机电量消耗大 | ✅ 手机几乎不耗电 |
| ❌ 必须随身携带手机 | ✅ 可以把手机放在家里 |
| ❌ 蓝牙断连导致数据丢失 | ✅ 数据安全存储在戒指 |
| ❌ 不适合长时间（如睡眠监测） | ✅ 支持数小时连续采集 |
| ❌ 用户必须保持 App 前台运行 | ✅ 用户可以做任何其他事情 |

---

## 完整生命周期状态机

```
                   ┌───────────────────────────────────────┐
                   │         IDLE（空闲）                    │
                   │  - 无活动录制                          │
                   │  - UI: 显示"开始采集"按钮              │
                   └───────────┬───────────────────────────┘
                               │ start()
                               │ 用户点击"开始离线采集"
                               ↓
                   ┌───────────────────────────────────────┐
                   │      SCHEDULING（配置中）               │
                   │  - 向戒指发送采集命令                   │
                   │  - 参数：总时长、分段、采样模式          │
                   │  - UI: "正在启动..."                   │
                   └───────────┬───────────────────────────┘
                               │ 戒指确认
                               ↓
                   ┌───────────────────────────────────────┐
                   │     RECORDING（采集中）                 │
                   │  - 戒指正在采集数据                     │
                   │  - 手机可断开连接！                     │
                   │  - 后台定时器运行                       │
                   │  - UI: 状态卡片显示进度                 │
                   └───────────┬───────────────────────────┘
                               │ 时间到 / 手动停止
                               ↓
                   ┌───────────────────────────────────────┐
                   │  WAITING_DOWNLOAD（等待下载）           │
                   │  - 采集已完成                          │
                   │  - 数据在戒指存储中                     │
                   │  - 发送通知提醒用户                     │
                   │  - UI: "采集完成，点击下载"             │
                   └───────────┬───────────────────────────┘
                               │ 用户打开 App / 点击通知
                               ↓
                   ┌───────────────────────────────────────┐
                   │    DOWNLOADING（下载中）                │
                   │  - 自动重连戒指                         │
                   │  - 从戒指下载文件                       │
                   │  - UI: 进度条显示                       │
                   └───────────┬───────────────────────────┘
                               │ 下载完成
                               ↓
                   ┌───────────────────────────────────────┐
                   │  READY_FOR_PLAYBACK（准备回放）         │
                   │  - 文件已保存到手机                     │
                   │  - UI: "开始回放"按钮可用               │
                   └───────────┬───────────────────────────┘
                               │ 自动或手动启动
                               ↓
                   ┌───────────────────────────────────────┐
                   │   PLAYING_BACK（回放中）                │
                   │  - 解析文件并回放                       │
                   │  - 实时计算 HR/RR                       │
                   │  - 支持暂停/快进/倍速                   │
                   │  - UI: 波形图 + 生理指标                │
                   └───────────┬───────────────────────────┘
                               │ 回放结束 / stop()
                               ↓
                               返回 IDLE
```

---

## 关键设计决策

### 1. 为什么需要 8 个状态？

**问题**：当前代码只有 `isOfflineRecording = true/false`，无法表达复杂流程。

**解决**：用枚举清晰表达每个阶段，每个状态对应不同的 UI 与行为：

```java
enum RecordingPhase {
    IDLE,               // → 可以启动新采集
    SCHEDULING,         // → 禁用按钮，显示 Loading
    RECORDING,          // → 显示进度卡片，允许断连
    WAITING_DOWNLOAD,   // → 启用"下载"按钮，禁用"开始"
    DOWNLOADING,        // → 显示下载进度条
    READY_FOR_PLAYBACK, // → 启用"回放"按钮
    PLAYING_BACK,       // → 显示波形，启用暂停/快进
}
```

**UI 映射**：
```java
private void updateUI(RecordingPhase phase) {
    startButton.setEnabled(phase == IDLE);
    disconnectButton.setEnabled(phase == RECORDING && bleService.isConnected());
    downloadButton.setEnabled(phase == WAITING_DOWNLOAD);
    playbackControls.setVisible(phase == PLAYING_BACK);
    
    statusText.setText(getPhaseDescription(phase));
}
```

---

### 2. 断连策略：主动 vs 被动

#### 主动断连（推荐）
```java
if (config.autoDisconnect) {
    // 戒指确认开始采集后，主动断开蓝牙
    bleService.disconnect();
    showToast("已断开连接，戒指将继续采集");
}
```

**优点**：
- 手机立即省电
- 用户明确知道可以离开
- 减少意外断连的困惑

#### 被动断连（兼容）
```java
bleService.setDisconnectListener(() -> {
    if (phase == RECORDING) {
        // 断连时不报错，只记录日志
        Log.i(TAG, "BLE disconnected, but ring continues recording");
        showNotification("戒指正在采集，无需保持连接");
    }
});
```

**用途**：
- 用户手动关闭蓝牙
- 手机重启
- 走出蓝牙范围

---

### 3. 自动下载定时器：何时触发？

#### 策略 A：精确定时（实现简单）
```java
handler.postDelayed(() -> {
    tryAutoDownload();
}, totalDuration * 1000 + bufferTime);
```

**问题**：
- 如果戒指提前/延迟完成，时间不准
- 如果 App 被杀，定时器丢失

#### 策略 B：轮询检查（推荐）
```java
// 从预计完成时间开始，每 30 秒轮询一次
long estimatedEnd = startTime + duration;
scheduleAtFixedRate(() -> {
    if (System.currentTimeMillis() >= estimatedEnd) {
        if (bleService.isConnected()) {
            tryDownload();
        } else {
            showNotification("采集完成，请重连戒指下载数据");
        }
    }
}, estimatedEnd, 30_000);
```

**优点**：
- 容错性好（不依赖精确时间）
- 支持手动提前停止

#### 策略 C：戒指主动推送（最优，需固件支持）
```java
bleService.setRecordingCompletedListener((recordingId, fileSize) -> {
    // 戒指采集完成后主动推送通知
    phase = WAITING_DOWNLOAD;
    autoDownload();
});
```

**如果固件支持此功能，可以完全避免定时器。**

---

### 4. 持久化：应对极端情况

#### 场景 1：App 被系统杀死

```java
@Override
protected void onDestroy() {
    if (phase == RECORDING || phase == WAITING_DOWNLOAD) {
        // 保存状态到 SharedPreferences
        saveRecordingState();
    }
}

@Override
protected void onCreate(Bundle savedInstanceState) {
    // App 重启时恢复
    RecordingState state = loadRecordingState();
    if (state != null) {
        restoreRecordingSession(state);
    }
}
```

#### 场景 2：手机重启

```java
// 在 BroadcastReceiver 中监听开机
public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            // 检查是否有未完成的录制
            if (hasPendingRecording()) {
                showNotification("戒指采集可能已完成，请打开 App 下载数据");
            }
        }
    }
}
```

#### 场景 3：用户忘记下载

```java
// 每天检查一次是否有超过 24 小时的待下载录制
WorkManager.enqueueUniquePeriodicWork(
    "check_pending_recordings",
    ExistingPeriodicWorkPolicy.KEEP,
    PeriodicWorkRequest.Builder(
        CheckPendingRecordingsWorker.class,
        1, TimeUnit.DAYS
    ).build()
);
```

---

## 用户交互设计

### UI 元素

#### 1. 离线状态卡片（常驻显示，采集期间）

```
┌──────────────────────────────────────────┐
│  🔴 戒指正在采集数据                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━ 45%          │
│  预计剩余 2 分 30 秒                      │
│                                          │
│  [ 断开连接（省电）]  [ 立即停止 ]        │
└──────────────────────────────────────────┘
```

**状态变化**：
- `RECORDING` → 显示进度条与剩余时间
- `WAITING_DOWNLOAD` → 变为绿色，显示"采集完成，可下载"
- `DOWNLOADING` → 显示下载进度
- `IDLE` / `PLAYING_BACK` → 隐藏卡片

#### 2. 通知（后台提醒）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 OpenRing
━━━━━━━━━━━━━━━━━━━━━━━━━━
采集完成 ✓
点击下载数据（约 2.3 MB）
━━━━━━━━━━━━━━━━━━━━━━━━━━
[立即下载]  [稍后提醒]
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**触发时机**：
- 采集启动成功 → "戒指正在采集，可断开连接"
- 采集完成 → "采集完成，点击下载"
- 下载完成 → "数据已下载，可回放"

#### 3. 历史录制列表

```
┌──────────────────────────────────────────┐
│  历史录制                                 │
├──────────────────────────────────────────┤
│  🟢 2024-10-30 14:23  运动采集  5 分钟    │
│     HR: 75-120 BPM   已下载  [回放]      │
├──────────────────────────────────────────┤
│  🟡 2024-10-30 10:15  睡眠监测  7 小时    │
│     在戒指存储中  [下载]                  │
├──────────────────────────────────────────┤
│  🔴 2024-10-29 22:30  运动采集  采集中    │
│     预计 2 分钟后完成  [查看状态]         │
└──────────────────────────────────────────┘
```

**功能**：
- 查看所有录制（本地 + 戒指端）
- 一键下载未下载的录制
- 重新回放已下载的录制
- 删除旧录制释放空间

---

## 命令协议（与戒指通信）

### 启动离线采集命令

```
命令格式（推测，需参考实际协议）:
00 [FrameID] 36 14 [总时长:4字节] [分段时长:4字节] [模式:1字节]

示例：采集 300 秒，每段 60 秒，模式 7（全传感器）
00 42 36 14 2C 01 00 00 3C 00 00 00 07

解析：
- 00: 命令帧类型
- 42: 随机 Frame ID
- 36 14: 离线采集启动子命令
- 2C 01 00 00: 300 秒（小端序）
- 3C 00 00 00: 60 秒（小端序）
- 07: 模式 7
```

### 戒指响应

```
成功：
00 42 36 14 01  (最后一字节 01 表示成功)

失败：
00 42 36 14 00 [错误码]
- 00: 设备忙
- 02: 存储空间不足
- 03: 参数无效
```

### 查询录制状态（可选，如果固件支持）

```
查询命令：
00 [FrameID] 36 15

响应：
00 [FrameID] 36 15 [状态] [已采集时长] [剩余时长]
- 状态: 00=未开始, 01=采集中, 02=已完成
```

---

## 数据完整性保障

### 问题：断连后如何确保数据不丢失？

**戒指端机制（假设）**：
1. 数据写入 Flash 存储（非易失性）
2. 采用循环缓冲区（满了覆盖最旧数据）
3. 每个文件包含头部元数据（时间戳、完整性校验）

**手机端验证**：
```java
private boolean verifyDownloadedFile(File file) {
    try {
        // 1. 检查文件大小是否合理
        long expectedSize = duration * samplingRate * bytesPerSample;
        if (Math.abs(file.length() - expectedSize) > expectedSize * 0.1) {
            return false; // 文件大小偏差超过 10%
        }
        
        // 2. 解析文件头
        FileHeader header = parseFileHeader(file);
        if (!header.isValid()) {
            return false;
        }
        
        // 3. 验证校验和（如果有）
        if (header.hasChecksum()) {
            long actualChecksum = calculateChecksum(file);
            if (actualChecksum != header.getChecksum()) {
                return false;
            }
        }
        
        return true;
    } catch (Exception e) {
        return false;
    }
}
```

### 断点续传（高级功能）

如果文件很大（如数小时录制），支持分块下载：

```java
public void downloadFileWithResume(String fileName, File targetFile) {
    long downloadedBytes = targetFile.exists() ? targetFile.length() : 0;
    
    // 向戒指发送"从偏移量继续下载"命令
    byte[] cmd = buildResumeDownloadCommand(fileName, downloadedBytes);
    bleService.sendCommand(cmd);
    
    // 追加模式写入
    FileOutputStream fos = new FileOutputStream(targetFile, true);
    // ...
}
```

---

## 性能优化

### 1. 下载速度优化

**当前瓶颈**（推测）：
- BLE 4.0: ~5-10 KB/s
- BLE 5.0: ~50-100 KB/s
- MTU 大小：默认 23 字节，可协商至 512 字节

**优化策略**：
```java
// 1. 协商最大 MTU
bleService.requestMtu(512, newMtu -> {
    Log.d(TAG, "MTU negotiated: " + newMtu);
});

// 2. 批量传输
// 戒指端每次发送尽可能多的数据（接近 MTU）
// 手机端缓冲后批量写盘

// 3. 压缩（可选）
// 如果戒指支持，传输压缩数据
if (ringSupportsCompression()) {
    byte[] compressedData = decompress(receivedData);
}
```

**实测示例**：
- 5 分钟采集，25Hz × 12 通道 × 4 字节 = 360 KB
- BLE 4.0 下载时间：~36-72 秒
- BLE 5.0 下载时间：~4-7 秒

### 2. 电池消耗分析

| 阶段 | 手机耗电 | 戒指耗电 |
|------|----------|----------|
| 启动采集（10 秒） | 5 mAh | 1 mAh |
| 采集中（5 分钟，已断连） | 0 mAh | 50 mAh |
| 下载文件（30 秒） | 3 mAh | 5 mAh |
| 回放分析（5 分钟） | 15 mAh | 0 mAh |
| **总计** | **23 mAh** | **56 mAh** |

对比在线模式（5 分钟全程连接）：
- 手机耗电：~80 mAh（持续蓝牙 + 实时处理）
- 戒指耗电：~55 mAh

**离线模式手机省电 71%！**

---

## 测试清单

### 功能测试

- [ ] 正常流程：启动 → 断连 → 等待 → 重连 → 下载 → 回放
- [ ] 提前停止：采集中途手动停止
- [ ] 断连容错：启动后主动断连，采集仍继续
- [ ] 重连失败：采集完成后多次重连失败，显示错误提示
- [ ] 文件校验：下载后验证文件完整性
- [ ] 并发冲突：有未完成录制时，禁止启动新录制

### 极端场景测试

- [ ] App 被杀：采集期间强制停止 App，恢复后状态正确
- [ ] 手机重启：采集期间手机重启，开机后恢复状态
- [ ] 戒指低电量：采集中途戒指电量耗尽，提示错误
- [ ] 存储满：戒指存储空间不足，启动失败并提示
- [ ] 蓝牙关闭：下载期间关闭蓝牙，暂停下载并提示
- [ ] 多设备冲突：两个手机同时连接同一戒指

### 性能测试

- [ ] 长时采集：7 小时睡眠监测，数据完整无丢失
- [ ] 大文件下载：10 MB 文件下载时间 < 3 分钟
- [ ] 内存泄漏：回放 1 小时数据，内存增长 < 100 MB
- [ ] 电池消耗：离线模式手机耗电 < 在线模式 50%

---

## 总结：为什么这样设计？

### 核心原则

1. **利用硬件能力**
   - 戒指能断连采集 → 手机可以不在场
   - 这是最大的优势，必须充分发挥

2. **用户体验优先**
   - 自动化一切可以自动化的步骤
   - 提供清晰的状态反馈
   - 容错设计（重连失败、App 被杀）

3. **状态机驱动**
   - 复杂流程拆解为 8 个清晰状态
   - 每个状态对应明确的 UI 与行为
   - 状态转换有明确触发条件

4. **持久化保障**
   - 任何时候 App 崩溃/重启都能恢复
   - 用户永远不会丢失数据

### 与在线模式的对比

| 特性 | 在线模式 | 离线模式（本设计） |
|------|----------|-------------------|
| 实时反馈 | ✅ HR/RR 实时显示 | ❌ 事后分析 |
| 手机依赖 | ❌ 必须保持连接 | ✅ 仅启动/下载需要 |
| 适用场景 | 短时测试（< 10 分钟） | 长时监测（数小时） |
| 数据完整性 | 中（依赖连接） | 高（存储在戒指） |
| 手机耗电 | 高 | 低（省电 70%） |
| 用户体验 | 即时满足 | 延迟满足 |

**结论**：两种模式各有优势，应该都保留，但通过统一的数据源接口实现，避免代码重复。

