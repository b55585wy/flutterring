# 问题诊断和修复方案

## 🐛 问题1：测量结束后自动断开连接

### 现象
- 测量完成后，连接状态变为 `disconnected`
- 日志显示：`❌ 已断连，isConnected = false`

### 原因分析
可能的原因：
1. **戒指主动断开**：测量结束后戒指自动断开连接（省电）
2. **BLE 超时**：长时间无数据交互导致连接超时
3. **命令触发**：停止命令（0xC5）可能触发了断连

### 解决方案

#### 方案A：保持连接（推荐）
修改戒指固件或发送保持连接的命令。如果无法修改固件，可以：
- 测量结束后定期发送心跳包
- 或者接受这个行为，让用户重新连接

#### 方案B：自动重连
测量结束后自动重连：

```kotlin
private fun stopMeasurement(result: MethodChannel.Result?) {
    try {
        android.util.Log.d("OpenRing", "停止在线测量")
        
        // 发送停止测量命令
        val stopCmd = byteArrayOf(0xC5.toByte())
        BLEService.sendCmd(stopCmd)
        
        // 清除测量状态
        isMeasuring = false
        sampleBuffer.clear()
        
        // ✅ 新增：延迟检查连接状态，如果断开则自动重连
        handler.postDelayed({
            if (!isConnected && currentDeviceAddress != null) {
                android.util.Log.d("OpenRing", "检测到断连，尝试自动重连...")
                // 重连逻辑
                val adapter = BluetoothAdapter.getDefaultAdapter()
                val device = adapter.getRemoteDevice(currentDeviceAddress)
                GlobalParameterUtils.getInstance().device = device
                
                if (adapter.isEnabled) {
                    val bleServiceIntent = Intent(this, BLEService::class.java)
                    startService(bleServiceIntent)
                }
            }
        }, 2000) // 2秒后检查
        
        result?.success(null)
    } catch (e: Exception) {
        android.util.Log.e("OpenRing", "停止测量失败: ${e.message}", e)
        result?.error("STOP_MEASUREMENT_ERROR", e.message, null)
    }
}
```

#### 方案C：UI 提示（临时方案）
在 Flutter 侧检测到断连后，提示用户重新连接：

```dart
connectionStateChanged: (state, name, address) {
  if (state == ble.ConnectionState.disconnected && _wasRecording) {
    // 测量结束后断连，提示用户
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('测量已完成，连接已断开。如需继续测量，请重新连接。'),
        action: SnackBarAction(
          label: '重新连接',
          onPressed: () {
            // 跳转到主页重新连接
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  _wasRecording = _isRecording;
}
```

---

## 🐛 问题2：扫描到设备但UI不显示

### 现象
- Kotlin 日志显示：`发现设备: BCL603DD43 (F8:18:C2:4C:DD:43)`
- Flutter UI 中设备列表为空
- 没有 `🔵 Flutter Home: 发现设备` 日志

### 原因分析
EventChannel 事件没有正常发送到 Flutter，可能的原因：
1. **EventSink 为 null**：EventChannel 监听器未正确设置
2. **事件格式错误**：Flutter 侧无法解析事件
3. **线程问题**：事件在非主线程发送

### 诊断步骤

#### 步骤1：检查 EventSink 状态
在 `sendEvent` 方法中添加日志：

```kotlin
private fun sendEvent(event: Map<String, Any?>) {
    android.util.Log.d("OpenRing", "📤 尝试发送事件: type=${event["type"]}, eventSink=${if (eventSink != null) "有效" else "null"}")
    if (eventSink == null) {
        android.util.Log.w("OpenRing", "⚠️ EventSink 为 null，事件未发送")
        return
    }
    try {
        eventSink?.success(event)
        android.util.Log.d("OpenRing", "✅ 事件发送成功")
    } catch (e: Exception) {
        android.util.Log.e("OpenRing", "❌ 事件发送失败: ${e.message}", e)
    }
}
```

#### 步骤2：检查扫描事件发送
在 `leScanCallback` 中添加日志：

```kotlin
override fun onLeScan(device: BluetoothDevice?, rssi: Int, scanRecord: ByteArray?) {
    if (device == null) return
    
    android.util.Log.d("OpenRing", "扫描回调: ${device.name} (${device.address}) RSSI: $rssi")
    
    // 过滤逻辑
    val isOpenRing = LogicalApi.isOpenRingDevice(scanRecord)
    android.util.Log.d("OpenRing", "设备过滤结果: isOpenRing=$isOpenRing")
    
    if (isOpenRing) {
        android.util.Log.d("OpenRing", "发现设备: ${device.name} (${device.address}) RSSI: $rssi")
        
        handler.post {
            android.util.Log.d("OpenRing", "准备发送 deviceFound 事件...")
            sendEvent(mapOf(
                "type" to "deviceFound",
                "device" to mapOf(
                    "name" to (device.name ?: "Unknown"),
                    "address" to device.address,
                    "rssi" to rssi
                )
            ))
        }
    }
}
```

#### 步骤3：检查 Flutter 侧接收
在 `ring_platform.dart` 中添加日志：

```dart
static Stream<BleEvent> get eventStream {
  return _eventChannel.receiveBroadcastStream().map((event) {
    print('🔵 Flutter Platform: 收到原始事件 - $event');
    
    final map = Map<String, dynamic>.from(event as Map);
    final type = map['type'] as String;
    print('🔵 Flutter Platform: 事件类型 - $type');
    
    switch (type) {
      case 'deviceFound':
        final device = Map<String, dynamic>.from(map['device'] as Map);
        print('🔵 Flutter Platform: 解析设备 - ${device['name']} (${device['address']})');
        return BleEvent.deviceFound(
          name: device['name'] as String,
          address: device['address'] as String,
          rssi: device['rssi'] as int?,
        );
      // ... 其他事件
    }
  });
}
```

### 修复方案

#### 修复1：确保 EventSink 在主线程更新
```kotlin
eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        handler.post {
            eventSink = events
            android.util.Log.d("OpenRing", "✅ EventSink 已设置")
            syncConnectionState()
            emitConnectionEvent()
        }
    }
    
    override fun onCancel(arguments: Any?) {
        handler.post {
            eventSink = null
            android.util.Log.d("OpenRing", "ℹ️ EventSink 已清除")
        }
    }
})
```

#### 修复2：检查事件格式
确保事件格式与 Flutter 侧期望的一致：

```kotlin
// Kotlin 侧
mapOf(
    "type" to "deviceFound",
    "device" to mapOf(
        "name" to deviceName,
        "address" to deviceAddress,
        "rssi" to rssi
    )
)

// Flutter 侧期望
case 'deviceFound':
  final device = Map<String, dynamic>.from(map['device'] as Map);
  return BleEvent.deviceFound(
    name: device['name'] as String,
    address: device['address'] as String,
    rssi: device['rssi'] as int?,
  );
```

---

## 🧪 测试步骤

### 测试问题1（断连）
1. 连接戒指
2. 开始测量（选择30秒）
3. 等待自动停止
4. 观察日志：
   - 是否有 `❌ 已断连` 日志？
   - 什么时候断开的？（停止命令发送后多久？）
5. 检查主页连接状态

### 测试问题2（扫描）
1. 确保戒指在附近
2. 点击扫描
3. 观察日志：
   - Kotlin: `发现设备: BCL603DD43`
   - Kotlin: `📤 尝试发送事件: type=deviceFound`
   - Kotlin: `✅ 事件发送成功`
   - Flutter: `🔵 Flutter Platform: 收到原始事件`
   - Flutter: `🔵 Flutter Home: 发现设备`
4. 检查 UI 是否显示设备

---

## 📝 需要你提供的信息

1. **完整的日志**（从扫描开始到测量结束）
   ```bash
   adb logcat -c  # 清除旧日志
   adb logcat | findstr /i "OpenRing Flutter" > test_log.txt
   ```

2. **问题1（断连）的时间点**
   - 停止命令发送时间
   - 断连发生时间
   - 时间差是多少？

3. **问题2（扫描）的详细日志**
   - 是否有 `📤 尝试发送事件` 日志？
   - `eventSink` 是 "有效" 还是 "null"？
   - 是否有 Flutter 侧的接收日志？

---

## 🚀 快速修复（临时）

如果你想快速继续测试，可以：

1. **问题1**：接受测量后断连的行为，每次测量前重新连接
2. **问题2**：先用原生 App 验证戒指是否正常工作，然后重启 Flutter App 再试

---

**创建时间**: 2024-11-01  
**状态**: 等待用户反馈和测试

