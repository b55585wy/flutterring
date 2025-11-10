package com.tsinghua.openring_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.time.Instant
import com.tsinghua.openring.utils.BLEService
import com.lm.sdk.LmAPI
import com.lm.sdk.inter.IResponseListener
import com.lm.sdk.utils.GlobalParameterUtils

class MainActivity: FlutterActivity(), IResponseListener {
    private val METHOD_CHANNEL = "ring/method"
    private val EVENT_CHANNEL = "ring/events"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    
    // ✅ 添加连接状态标志
    private var isConnected = false
    private var currentConnectionState: String = "disconnected"
    private var currentDeviceName: String? = null
    private var currentDeviceAddress: String? = null
    private var lastConnectedIso: String? = null
    
    private val connectionStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) return
            
            when (intent.action) {
                BLEService.BROADCAST_CONNECT_STATE_CHANGE -> {
                    val state = intent.getIntExtra(BLEService.BROADCAST_CONNECT_STATE_VALUE, -1)
                    handleConnectionStateChange(state)
                }
                BLEService.BROADCAST_DATA -> {
                    val data = intent.getByteArrayExtra(BLEService.BROADCAST_DATA_BYTE)
                    if (data != null) {
                        handleDataReceived(data)
                    }
                }
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 初始化 LmAPI
        LmAPI.init(application)
        LmAPI.setDebug(true)
        LmAPI.addWLSCmdListener(this, this)
        
        // 🔄 尽早同步连接状态（在配置 Channel 之前）
        syncConnectionState()
        
        // 注册广播接收器
        val filter = IntentFilter().apply {
            addAction(BLEService.BROADCAST_CONNECT_STATE_CHANGE)
            addAction(BLEService.BROADCAST_DATA)
        }
        LocalBroadcastManager.getInstance(this).registerReceiver(connectionStateReceiver, filter)
        
        // 配置 Method Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "scanDevices" -> {
                    scanDevices(result)
                }
                "stopScan" -> {
                    try {
                        stopScan()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("STOP_SCAN_ERROR", e.message, null)
                    }
                }
                "connectDevice" -> {
                    val macAddress = call.argument<String>("macAddress")
                    if (macAddress != null) {
                        connectDevice(macAddress, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "MAC address is required", null)
                    }
                }
                "disconnect" -> {
                    disconnectDevice(result)
                }
                "getConnectedDevice" -> {
                    result.success(buildConnectedDeviceInfo())
                }
                "startLiveMeasurement" -> {
                    val duration = call.argument<Int>("duration") ?: 60
                    startLiveMeasurement(duration, result)
                }
                "stopMeasurement" -> {
                    stopMeasurement(result)
                }
                "getDeviceInfo" -> {
                    // 返回已连接设备的信息
                    result.success(buildConnectedDeviceInfo())
                }
                "getBatteryLevel" -> {
                    // 返回电池电量
                    val deviceInfo = buildConnectedDeviceInfo()
                    if (deviceInfo != null && deviceInfo.containsKey("battery")) {
                        result.success(deviceInfo["battery"])
                    } else {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 配置 Event Channel
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                // 检查实际连接状态并同步
                syncConnectionState()
                emitConnectionEvent()
            }
            
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }
    
    private fun connectDevice(macAddress: String, result: MethodChannel.Result) {
        try {
            android.util.Log.d("OpenRing", "开始连接设备: $macAddress")
            
            val adapter = BluetoothAdapter.getDefaultAdapter()
            val device = adapter.getRemoteDevice(macAddress)
            
            if (device != null) {
                android.util.Log.d("OpenRing", "设备对象创建成功: ${device.name} - ${device.address}")
                
                GlobalParameterUtils.getInstance().device = device
                currentDeviceName = device.name
                currentDeviceAddress = device.address
                
                if (adapter.isEnabled) {
                    android.util.Log.d("OpenRing", "蓝牙已启用，开始启动 BLEService")
                    
                    val bleServiceIntent = Intent(this, BLEService::class.java)
                    bleServiceIntent.putExtra(BLEService.BLUETOOTH_CONNECT_DEVICE, device)
                    bleServiceIntent.putExtra(BLEService.BLUETOOTH_HID_MODE, false)
                    startService(bleServiceIntent)

                    currentConnectionState = "connecting"
                    emitConnectionEvent()
                    
                    android.util.Log.d("OpenRing", "BLEService 已启动")
                    result.success(null)
                } else {
                    android.util.Log.w("OpenRing", "蓝牙未启用，正在启用...")
                    adapter.enable()
                    result.error("BLUETOOTH_DISABLED", "Enabling Bluetooth", null)
                }
            } else {
                android.util.Log.e("OpenRing", "设备对象为 null")
                result.error("INVALID_DEVICE", "Invalid MAC address", null)
            }
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "连接失败: ${e.message}", e)
            result.error("CONNECT_ERROR", e.message, null)
        }
    }
    
    private fun disconnectDevice(result: MethodChannel.Result) {
        try {
            android.util.Log.d("OpenRing", "开始断开连接...")
            
            // ✅ 1. 如果正在测量，先停止
            if (isMeasuring) {
                android.util.Log.d("OpenRing", "正在测量中，先停止测量")
                stopMeasurement(null)
            }
            
            // ✅ 2. 停止 BLE 服务
            val bleServiceIntent = Intent(this, BLEService::class.java)
            stopService(bleServiceIntent)
            
            // ✅ 3. 更新连接状态
            isConnected = false
            currentConnectionState = "disconnected"
            currentDeviceName = null
            currentDeviceAddress = null
            
            // ✅ 4. 发送断连事件
            handler.postDelayed({
                emitConnectionEvent()
            }, 100)
            
            android.util.Log.d("OpenRing", "✅ 断开连接成功")
            result.success(null)
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "断开连接失败", e)
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }
    
    private var leScanCallback: BluetoothAdapter.LeScanCallback? = null
    private var isScanning = false
    
    private fun scanDevices(result: MethodChannel.Result) {
        handler.post {
            android.util.Log.d("OpenRing", "========== 开始扫描设备 ==========")
            
            // 检查蓝牙是否开启
            val adapter = BluetoothAdapter.getDefaultAdapter()
            if (adapter == null || !adapter.isEnabled) {
                result.error("BLUETOOTH_DISABLED", "蓝牙未开启", null)
                return@post
            }
            
            // 如果正在扫描，先停止
            if (isScanning) {
                stopScan()
            }
            
            // 清空设备列表
            // discoveredDevices.clear() // This line was removed from the new_code, so it's removed here.
            
            android.util.Log.d("OpenRing", "启动新的扫描...")
            
            // 创建扫描回调
            leScanCallback = BluetoothAdapter.LeScanCallback { device, rssi, scanRecord ->
                // 过滤：只显示有名称的设备
                if (device != null && !device.name.isNullOrEmpty()) {
                    // 调试模式：是否显示所有设备（包括被 SDK 过滤的）
                    val debugShowAllDevices = true  // 设为 true 显示所有设备
                    
                    try {
                        // 使用 LogicalApi 过滤（只保留兼容的设备）
                        val bleDeviceInfo = com.lm.sdk.LogicalApi.getBleDeviceInfoWhenBleScan(
                            device, rssi, scanRecord, true
                        )

                        // 只有通过过滤的设备才发送到 Flutter
                        if (bleDeviceInfo != null) {
                            val infoSummary = try {
                                mapOf(
                                    "className" to bleDeviceInfo::class.java.name,
                                    "hashCode" to bleDeviceInfo.hashCode(),
                                    "string" to bleDeviceInfo.toString()
                                )
                            } catch (infoError: Exception) {
                                android.util.Log.w(
                                    "OpenRing",
                                    "⚠️ bleDeviceInfo.toString() 解析失败: name=${device.name}, address=${device.address}",
                                    infoError
                                )
                                mapOf("error" to infoError.message)
                            }
                            android.util.Log.d(
                                "OpenRing",
                                "设备通过过滤: name=${device.name}, address=${device.address}, info=$infoSummary"
                            )
                            android.util.Log.d(
                                "OpenRing",
                                "发现设备: ${device.name} (${device.address}) RSSI: $rssi"
                            )
                            handler.post {
                                sendEvent(
                                    mapOf(
                                        "type" to "deviceFound",
                                        "device" to mapOf(
                                            "name" to device.name,
                                            "address" to device.address,
                                            "rssi" to rssi
                                        )
                                    )
                                )
                            }
                        } else {
                            android.util.Log.d(
                                "OpenRing",
                                "过滤掉设备: ${device.name} (${device.address}) - LogicalApi 返回 null"
                            )
                        }
                    } catch (e: Exception) {
                        val payload = scanRecord?.toHexString() ?: "null"
                        android.util.Log.w(
                            "OpenRing",
                            "❌ 解析广播异常: name=${device.name}, address=${device.address}, rssi=$rssi, payload=$payload",
                            e
                        )
                    }
                }
            }
            
            // 开始扫描
            @Suppress("DEPRECATION")
            isScanning = adapter.startLeScan(leScanCallback)
            
            if (isScanning) {
                android.util.Log.d("OpenRing", "✅ 扫描已启动，15秒后自动停止")
            } else {
                android.util.Log.e("OpenRing", "❌ 扫描启动失败")
            }
            
            // ✅ 延长到15秒后自动停止
            handler.postDelayed({
                android.util.Log.d("OpenRing", "扫描超时，停止扫描")
                stopScan()
                handler.post {
                    sendEvent(mapOf("type" to "scanCompleted"))
                }
            }, 15000)
            
            result.success(null)
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "启动扫描异常", e)
            result.error("SCAN_ERROR", e.message, null)
        }
    }
    
    private fun ByteArray.toHexString(): String =
        joinToString(separator = "") { byte -> "%02X".format(byte) }

    private fun startNewScan(adapter: BluetoothAdapter, result: MethodChannel.Result) {
        try {
            android.util.Log.d("OpenRing", "启动新的扫描...")
            
            // 创建扫描回调
            leScanCallback = BluetoothAdapter.LeScanCallback { device, rssi, scanRecord ->
                // 过滤：只显示有名称的设备
                if (device != null && !device.name.isNullOrEmpty()) {
                    try {
                        // 使用 LogicalApi 过滤（只保留兼容的设备）
                        val bleDeviceInfo = com.lm.sdk.LogicalApi.getBleDeviceInfoWhenBleScan(
                            device, rssi, scanRecord, true
                        )

                        // 只有通过过滤的设备才发送到 Flutter
                        if (bleDeviceInfo != null) {
                            val infoSummary = try {
                                mapOf(
                                    "className" to bleDeviceInfo::class.java.name,
                                    "hashCode" to bleDeviceInfo.hashCode(),
                                    "string" to bleDeviceInfo.toString()
                                )
                            } catch (infoError: Exception) {
                                android.util.Log.w(
                                    "OpenRing",
                                    "⚠️ bleDeviceInfo.toString() 解析失败: name=${device.name}, address=${device.address}",
                                    infoError
                                )
                                mapOf("error" to infoError.message)
                            }
                            android.util.Log.d(
                                "OpenRing",
                                "设备通过过滤: name=${device.name}, address=${device.address}, info=$infoSummary"
                            )
                            android.util.Log.d(
                                "OpenRing",
                                "发现设备: ${device.name} (${device.address}) RSSI: $rssi"
                            )
                            handler.post {
                                sendEvent(
                                    mapOf(
                                        "type" to "deviceFound",
                                        "device" to mapOf(
                                            "name" to device.name,
                                            "address" to device.address,
                                            "rssi" to rssi
                                        )
                                    )
                                )
                            }
                        } else {
                            android.util.Log.d(
                                "OpenRing",
                                "过滤掉设备: ${device.name} (${device.address}) - LogicalApi 返回 null"
                            )
                        }
                    } catch (e: Exception) {
                        val payload = scanRecord?.toHexString() ?: "null"
                        android.util.Log.w(
                            "OpenRing",
                            "❌ 解析广播异常: name=${device.name}, address=${device.address}, rssi=$rssi, payload=$payload",
                            e
                        )
                    }
                }
            }
            
            // 开始扫描
            @Suppress("DEPRECATION")
            isScanning = adapter.startLeScan(leScanCallback)
            
            if (isScanning) {
                android.util.Log.d("OpenRing", "✅ 扫描已启动，15秒后自动停止")
            } else {
                android.util.Log.e("OpenRing", "❌ 扫描启动失败")
            }
            
            // ✅ 延长到15秒后自动停止
            handler.postDelayed({
                android.util.Log.d("OpenRing", "扫描超时，停止扫描")
                stopScan()
                handler.post {
                    sendEvent(mapOf("type" to "scanCompleted"))
                }
            }, 15000)
            
            result.success(null)
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "启动扫描异常", e)
            result.error("SCAN_ERROR", e.message, null)
        }
    }
    
    private fun stopScan() {
        if (isScanning) {
            val adapter = BluetoothAdapter.getDefaultAdapter()
            @Suppress("DEPRECATION")
            adapter.stopLeScan(leScanCallback)
            isScanning = false
        }
    }
    
    private fun handleConnectionStateChange(state: Int) {
        when (state) {
            BLEService.CONNECT_STATE_SUCCESS -> {
                isConnected = true
                val device = GlobalParameterUtils.getInstance().device
                currentDeviceName = device?.name ?: currentDeviceName
                currentDeviceAddress = device?.address ?: currentDeviceAddress
                lastConnectedIso = Instant.now().toString()
                currentConnectionState = "connected"
                android.util.Log.d("OpenRing", "✅ 连接成功，isConnected = true")
                
                // 💾 保存设备信息到 SharedPreferences
                if (currentDeviceAddress != null) {
                    try {
                        val prefs = getSharedPreferences("OpenRingPrefs", MODE_PRIVATE)
                        prefs.edit().apply {
                            putString("last_device_address", currentDeviceAddress)
                            putString("last_device_name", currentDeviceName)
                            apply()
                        }
                        android.util.Log.d("OpenRing", "💾 设备信息已保存到 SharedPreferences")
                    } catch (e: Exception) {
                        android.util.Log.w("OpenRing", "⚠️ 保存设备信息失败: ${e.message}")
                    }
                }
            }
            BLEService.CONNECT_STATE_GATT_CONNECTING,
            BLEService.CONNECT_STATE_GATT_CONNECTED,
            BLEService.CONNECT_STATE_SERVICE_CONNECTING,
            BLEService.CONNECT_STATE_SERVICE_CONNECTED,
            BLEService.CONNECT_STATE_WRITE_CONNECTING,
            BLEService.CONNECT_STATE_RESPOND_CONNECTING -> {
                // 连接过程中的过渡状态，保持已连接标记不变
                val stage = when (state) {
                    BLEService.CONNECT_STATE_GATT_CONNECTING -> "GATT_CONNECTING"
                    BLEService.CONNECT_STATE_GATT_CONNECTED -> "GATT_CONNECTED"
                    BLEService.CONNECT_STATE_SERVICE_CONNECTING -> "SERVICE_CONNECTING"
                    BLEService.CONNECT_STATE_SERVICE_CONNECTED -> "SERVICE_CONNECTED"
                    BLEService.CONNECT_STATE_WRITE_CONNECTING -> "WRITE_CONNECTING"
                    BLEService.CONNECT_STATE_RESPOND_CONNECTING -> "RESPOND_CONNECTING"
                    else -> "CONNECTING"
                }
                if (!isConnected) {
                    currentConnectionState = "connecting"
                } else {
                    currentConnectionState = "connected"
                }
                android.util.Log.d("OpenRing", "🔄 连接阶段($stage)，当前状态: $currentConnectionState")
            }
            BLEService.CONNECT_STATE_DISCONNECTED,
            BLEService.CONNECT_STATE_SERVICE_DISCONNECTED,
            BLEService.CONNECT_STATE_WRITE_DISCONNECTED,
            BLEService.CONNECT_STATE_RESPOND_DISCONNECTED -> {
                isConnected = false
                currentConnectionState = "disconnected"
                currentDeviceName = null
                currentDeviceAddress = null
                android.util.Log.d("OpenRing", "❌ 已断连，isConnected = false (state=$state)")
            }
            else -> {
                android.util.Log.w("OpenRing", "⚠️ 未识别的连接状态码: $state")
            }
        }

        handler.post {
            emitConnectionEvent(statusCode = state)
        }
    }
    
    private var isMeasuring = false
    private val sampleBuffer = mutableListOf<Map<String, Any>>()
    
    private fun handleDataReceived(data: ByteArray) {
        // 如果不在测量状态，忽略数据
        if (!isMeasuring) return
        
        try {
            // 解析 BLE 数据包为 Sample
            // 数据包格式（参考原项目）：每个样本 36 字节
            // 12 个传感器值，每个 3 字节（24 bit）
            val samples = parseSamples(data)
            
            if (samples.isNotEmpty()) {
                sampleBuffer.addAll(samples)
                
                // 每积累 25 个样本（约 1 秒数据，25Hz），发送一次批次
                if (sampleBuffer.size >= 25) {
                    handler.post {
                        sendEvent(mapOf(
                            "type" to "sampleBatch",
                            "data" to mapOf(
                                "samples" to sampleBuffer.toList(),
                                "timestamp" to System.currentTimeMillis()
                            )
                        ))
                    }
                    sampleBuffer.clear()
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "数据解析失败: ${e.message}", e)
        }
    }
    
    private fun parseSamples(data: ByteArray): List<Map<String, Any>> {
        val samples = mutableListOf<Map<String, Any>>()
        
        // 检查是否是协议数据包
        if (data.size < 14) {
            android.util.Log.w("OpenRing", "数据包太短: ${data.size} 字节")
            return samples
        }
        
        // 检查命令类型（偏移 2）
        val cmd = data[2].toInt() and 0xFF
        if (cmd != 0x3C) {
            // 不是实时数据包，忽略
            return samples
        }
        
        // 解析数据头
        val seq = data[4].toInt() and 0xFF
        val dataNum = data[5].toInt() and 0xFF
        
        android.util.Log.d("OpenRing", "收到实时数据包: seq=$seq, dataNum=$dataNum")
        
        // 每个样本 30 字节
        val bytesPerSample = 30
        val headerSize = 14  // 4 字节帧头 + 10 字节数据头
        
        for (i in 0 until dataNum) {
            val offset = headerSize + i * bytesPerSample
            
            if (offset + bytesPerSample > data.size) {
                android.util.Log.w("OpenRing", "数据不完整，跳过样本 $i")
                break
            }
            
            try {
                // PPG 数据（4 字节无符号整数，小端序）
                val green = readUInt32LE(data, offset)
                val red = readUInt32LE(data, offset + 4)
                val ir = readUInt32LE(data, offset + 8)
                
                // 加速度计数据（2 字节有符号整数，小端序）
                val accX = readInt16LE(data, offset + 12)
                val accY = readInt16LE(data, offset + 14)
                val accZ = readInt16LE(data, offset + 16)
                
                // 陀螺仪数据（2 字节有符号整数，小端序）
                val gyroX = readInt16LE(data, offset + 18)
                val gyroY = readInt16LE(data, offset + 20)
                val gyroZ = readInt16LE(data, offset + 22)
                
                // 温度数据（2 字节有符号整数，小端序）
                val temp0 = readInt16LE(data, offset + 24)
                val temp1 = readInt16LE(data, offset + 26)
                val temp2 = readInt16LE(data, offset + 28)
                
                samples.add(mapOf(
                    "timestamp" to System.currentTimeMillis(),
                    "green" to green,
                    "red" to red,
                    "ir" to ir,
                    "accX" to accX,
                    "accY" to accY,
                    "accZ" to accZ,
                    "gyroX" to gyroX,
                    "gyroY" to gyroY,
                    "gyroZ" to gyroZ,
                    "temp0" to temp0,
                    "temp1" to temp1,
                    "temp2" to temp2
                ))
            } catch (e: Exception) {
                android.util.Log.e("OpenRing", "解析样本 $i 失败: ${e.message}", e)
            }
        }
        
        return samples
    }
    
    // 小端序读取 4 字节无符号整数
    private fun readUInt32LE(data: ByteArray, offset: Int): Long {
        if (offset + 4 > data.size) return 0L
        
        return ((data[offset].toLong() and 0xFF)) or
               ((data[offset + 1].toLong() and 0xFF) shl 8) or
               ((data[offset + 2].toLong() and 0xFF) shl 16) or
               ((data[offset + 3].toLong() and 0xFF) shl 24)
    }
    
    // 小端序读取 2 字节有符号整数
    private fun readInt16LE(data: ByteArray, offset: Int): Int {
        if (offset + 2 > data.size) return 0
        
        val value = ((data[offset].toInt() and 0xFF)) or
                   ((data[offset + 1].toInt() and 0xFF) shl 8)
        
        // 处理符号（16 位有符号数）
        return if (value and 0x8000 != 0) {
            value or -0x10000  // 符号扩展
        } else {
            value
        }
    }
    
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

    private fun syncConnectionState() {
        try {
            android.util.Log.d("OpenRing", "🔄 开始同步连接状态...")
            
            // 1. 先检查 GlobalParameterUtils 中是否有设备信息（运行时缓存）
            var device = GlobalParameterUtils.getInstance().device
            if (device != null) {
                android.util.Log.d("OpenRing", "🔄 从 GlobalParameterUtils 发现设备: ${device.name} - ${device.address}")
            } else {
                // 2. 如果没有，尝试从 SharedPreferences 恢复（持久化存储）
                android.util.Log.d("OpenRing", "ℹ️ GlobalParameterUtils 中没有设备，尝试从 SharedPreferences 恢复...")
                val prefs = getSharedPreferences("OpenRingPrefs", MODE_PRIVATE)
                val savedAddress = prefs.getString("last_device_address", null)
                val savedName = prefs.getString("last_device_name", null)
                
                if (savedAddress != null) {
                    android.util.Log.d("OpenRing", "📦 从 SharedPreferences 恢复设备: $savedName - $savedAddress")
                    
                    // 尝试重新创建设备对象
                    try {
                        val adapter = BluetoothAdapter.getDefaultAdapter()
                        if (adapter != null && adapter.isEnabled) {
                            device = adapter.getRemoteDevice(savedAddress)
                            // 恢复到 GlobalParameterUtils
                            GlobalParameterUtils.getInstance().device = device
                            android.util.Log.d("OpenRing", "✅ 设备对象已重建并恢复到 GlobalParameterUtils")
                        }
                    } catch (e: Exception) {
                        android.util.Log.w("OpenRing", "⚠️ 无法重建设备对象: ${e.message}")
                    }
                } else {
                    android.util.Log.d("OpenRing", "ℹ️ SharedPreferences 中也没有保存的设备信息")
                }
            }
            
            // 3. 如果找到了设备信息，更新连接状态
            if (device != null) {
                val deviceName = device.name ?: currentDeviceName
                val deviceAddress = device.address
                
                android.util.Log.d("OpenRing", "🔄 准备同步设备状态: $deviceName - $deviceAddress")
                
                // 检查蓝牙适配器状态
                val adapter = BluetoothAdapter.getDefaultAdapter()
                if (adapter == null || !adapter.isEnabled) {
                    android.util.Log.w("OpenRing", "⚠️ 蓝牙未启用，无法确认连接状态")
                    return
                }
                
                // 更新状态（注意：这里不能确定是否真的连接，只是恢复了设备信息）
                currentDeviceName = deviceName
                currentDeviceAddress = deviceAddress
                // ⚠️ 不要设置为 connected，因为我们不确定是否真的连接
                // isConnected = true
                // currentConnectionState = "connected"
                lastConnectedIso = Instant.now().toString()
                android.util.Log.d("OpenRing", "✅ 设备信息已恢复，但连接状态保持为 disconnected（需要重新连接）")
            } else {
                android.util.Log.d("OpenRing", "ℹ️ 没有任何设备信息，状态保持为 disconnected")
            }
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "❌ 同步连接状态失败: ${e.message}", e)
        }
    }

    private fun emitConnectionEvent(statusCode: Int? = null) {
        val event = mutableMapOf<String, Any?>(
            "type" to "connectionStateChanged",
            "state" to currentConnectionState
        )
        if (statusCode != null) {
            event["statusCode"] = statusCode
        }
        if (!currentDeviceName.isNullOrEmpty()) {
            event["deviceName"] = currentDeviceName
        }
        if (!currentDeviceAddress.isNullOrEmpty()) {
            event["address"] = currentDeviceAddress
        }
        android.util.Log.d("OpenRing", "📤 发送连接事件: state=$currentConnectionState, name=$currentDeviceName, address=$currentDeviceAddress, eventSink=${if (eventSink != null) "已连接" else "未连接"}")
        sendEvent(event)
    }

    private fun buildConnectedDeviceInfo(): Map<String, Any?>? {
        android.util.Log.d("OpenRing", "📋 buildConnectedDeviceInfo 被调用: currentConnectionState=$currentConnectionState, isConnected=$isConnected")
        
        if (currentConnectionState != "connected") {
            android.util.Log.d("OpenRing", "📋 返回 null，因为状态不是 connected")
            return null
        }

        val device = GlobalParameterUtils.getInstance().device
        val address = currentDeviceAddress ?: device?.address
        val name = currentDeviceName ?: device?.name ?: "OpenRing"
        
        android.util.Log.d("OpenRing", "📋 设备信息: name=$name, address=$address")
        
        if (address == null) {
            android.util.Log.d("OpenRing", "📋 返回 null，因为没有地址")
            return null
        }

        return mapOf(
            "name" to name,
            "address" to address,
            "isConnected" to true,
            "lastConnectedTime" to (lastConnectedIso ?: Instant.now().toString())
        )
    }
    
    // IResponseListener implementations
    override fun lmBleConnecting(code: Int) {
        handler.post {
            sendEvent(mapOf(
                "type" to "connectionStateChanged",
                "state" to "connecting",
                "statusCode" to code
            ))
        }
    }
    
    override fun lmBleConnectionSucceeded(status: Int) {
        handler.post {
            sendEvent(mapOf(
                "type" to "connectionStateChanged",
                "state" to "connected",
                "statusCode" to status
            ))
        }
    }
    
    override fun lmBleConnectionFailed(status: Int) {
        handler.post {
            sendEvent(mapOf(
                "type" to "connectionStateChanged",
                "state" to "failed",
                "statusCode" to status
            ))
        }
    }
    
    override fun VERSION(b: Byte, s: String?) {
        handler.post {
            sendEvent(mapOf(
                "type" to "version",
                "version" to (s ?: "")
            ))
        }
    }
    
    override fun syncTime(b: Byte, bytes: ByteArray?) {}
    
    override fun stepCount(bytes: ByteArray?) {}
    
    override fun clearStepCount(b: Byte) {}
    
    override fun battery(b: Byte, b1: Byte) {}
    
    override fun battery_push(b: Byte, datum: Byte) {}
    
    override fun timeOut() {
        handler.post {
            sendEvent(mapOf(
                "type" to "error",
                "message" to "Connection timeout"
            ))
        }
    }
    
    override fun saveData(data: String?) {
        handler.post {
            sendEvent(mapOf(
                "type" to "saveData",
                "data" to (data ?: "")
            ))
        }
    }
    
    override fun reset(bytes: ByteArray?) {}
    
    override fun setCollection(b: Byte) {}
    
    override fun getCollection(bytes: ByteArray?) {}
    
    override fun getSerialNum(bytes: ByteArray?) {}
    
    override fun setSerialNum(b: Byte) {}
    
    override fun cleanHistory(b: Byte) {}
    
    override fun setBlueToolName(b: Byte) {}
    
    override fun readBlueToolName(b: Byte, s: String?) {}
    
    override fun stopRealTimeBP(b: Byte) {}
    
    override fun BPwaveformData(b: Byte, b1: Byte, s: String?) {}
    
    override fun onSport(i: Int, bytes: ByteArray?) {}
    
    override fun breathLight(b: Byte) {}
    
    override fun SET_HID(b: Byte) {}
    
    override fun GET_HID(b: Byte, b1: Byte, b2: Byte) {}
    
    override fun GET_HID_CODE(bytes: ByteArray?) {}
    
    override fun GET_CONTROL_AUDIO_ADPCM(b: Byte) {}
    
    override fun SET_AUDIO_ADPCM_AUDIO(b: Byte) {}
    
    override fun TOUCH_AUDIO_FINISH_XUN_FEI() {}
    
    override fun setAudio(i: Short, i1: Int, bytes: ByteArray?) {}
    
    override fun stopHeart(b: Byte) {}
    
    override fun stopQ2(b: Byte) {}
    
    override fun GET_ECG(bytes: ByteArray?) {}
    
    override fun SystemControl(systemControlBean: com.lm.sdk.mode.SystemControlBean?) {}
    
    override fun setUserInfo(result: Byte) {}
    
    override fun getUserInfo(sex: Int, height: Int, weight: Int, age: Int) {}
    
    override fun CONTROL_AUDIO(bytes: ByteArray?) {}
    
    override fun motionCalibration(b: Byte) {}
    
    override fun stopBloodPressure(b: Byte) {}
    
    override fun appBind(systemControlBean: com.lm.sdk.mode.SystemControlBean?) {}
    
    override fun appConnect(systemControlBean: com.lm.sdk.mode.SystemControlBean?) {}
    
    override fun appRefresh(systemControlBean: com.lm.sdk.mode.SystemControlBean?) {}
    
    // 启动在线测量
    private fun startLiveMeasurement(duration: Int, result: MethodChannel.Result) {
        android.util.Log.d("OpenRing", "========== 开始测量 ==========")
        android.util.Log.d("OpenRing", "时长: $duration 秒")
        android.util.Log.d("OpenRing", "连接状态: $isConnected")
        android.util.Log.d("OpenRing", "测量状态: $isMeasuring")
        
        try {
            // ✅ 步骤 1: 检查连接状态
            if (!isConnected) {
                android.util.Log.e("OpenRing", "❌ 设备未连接，无法开始测量")
                result.error("NOT_CONNECTED", "设备未连接，请先连接设备", null)
                return
            }
            
            // ✅ 步骤 2: 检查是否已在测量中
            if (isMeasuring) {
                android.util.Log.w("OpenRing", "⚠️ 已在测量中，忽略重复请求")
                result.error("ALREADY_MEASURING", "已在测量中", null)
                return
            }
            
            android.util.Log.d("OpenRing", "✅ 状态检查通过，准备发送命令")
            
            // ✅ 步骤 3: 设置测量状态
            isMeasuring = true
            sampleBuffer.clear()
            
            // ✅ 步骤 4: 发送启动测量命令到戒指
            // 0xC4 是启动实时数据流的命令（参考原项目）
            val startCmd = byteArrayOf(0xC4.toByte())
            android.util.Log.d("OpenRing", "发送命令: ${startCmd.joinToString(" ") { "%02X".format(it) }}")
            
            BLEService.sendCmd(startCmd)
            
            android.util.Log.d("OpenRing", "✅ 命令已发送")
            
            // ✅ 步骤 5: 设置自动停止
            if (duration > 0) {
                android.util.Log.d("OpenRing", "设置 $duration 秒后自动停止")
                handler.postDelayed({
                    stopMeasurement(null)
                }, (duration * 1000).toLong())
            }
            
            result.success(null)
            android.util.Log.d("OpenRing", "========== 测量启动成功 ==========")
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "❌ 启动测量异常", e)
            android.util.Log.e("OpenRing", "异常类型: ${e.javaClass.name}")
            android.util.Log.e("OpenRing", "异常消息: ${e.message}")
            e.printStackTrace()
            
            isMeasuring = false
            result.error("START_MEASUREMENT_ERROR", e.message, null)
        }
    }
    
    // 停止测量
    private fun stopMeasurement(result: MethodChannel.Result?) {
        try {
            android.util.Log.d("OpenRing", "停止在线测量")
            
            // 发送停止测量命令到戒指
            // 0xC5 是停止实时数据流的命令（参考原项目）
            val stopCmd = byteArrayOf(0xC5.toByte())
            BLEService.sendCmd(stopCmd)
            
            // 清除测量状态
            isMeasuring = false
            sampleBuffer.clear()
            
            android.util.Log.d("OpenRing", "已发送停止测量命令")
            
            result?.success(null)
        } catch (e: Exception) {
            android.util.Log.e("OpenRing", "停止测量失败: ${e.message}", e)
            result?.error("STOP_MEASUREMENT_ERROR", e.message, null)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        isMeasuring = false
        sampleBuffer.clear()
        stopScan()
        LocalBroadcastManager.getInstance(this).unregisterReceiver(connectionStateReceiver)
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
    }
}
