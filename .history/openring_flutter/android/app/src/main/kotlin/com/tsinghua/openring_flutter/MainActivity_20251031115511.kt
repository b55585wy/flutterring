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
                    // TODO: 获取当前连接的设备信息
                    result.success(null)
                }
                "startLiveMeasurement" -> {
                    val duration = call.argument<Int>("duration") ?: 60
                    startLiveMeasurement(duration, result)
                }
                "stopMeasurement" -> {
                    stopMeasurement(result)
                }
                "getDeviceInfo" -> {
                    // TODO: 获取设备信息
                    result.success(mapOf(
                        "name" to "OpenRing",
                        "version" to "1.0.0",
                        "battery" to 80
                    ))
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
                
                if (adapter.isEnabled) {
                    android.util.Log.d("OpenRing", "蓝牙已启用，开始启动 BLEService")
                    
                    val bleServiceIntent = Intent(this, BLEService::class.java)
                    bleServiceIntent.putExtra(BLEService.BLUETOOTH_CONNECT_DEVICE, device)
                    bleServiceIntent.putExtra(BLEService.BLUETOOTH_HID_MODE, false)
                    startService(bleServiceIntent)
                    
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
            val bleServiceIntent = Intent(this, BLEService::class.java)
            stopService(bleServiceIntent)
            result.success(null)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }
    
    private var leScanCallback: BluetoothAdapter.LeScanCallback? = null
    private var isScanning = false
    
    private fun scanDevices(result: MethodChannel.Result) {
        try {
            val adapter = BluetoothAdapter.getDefaultAdapter()
            if (!adapter.isEnabled) {
                result.error("BLUETOOTH_DISABLED", "Bluetooth is disabled", null)
                return
            }
            
            if (isScanning) {
                result.success(null)
                return
            }
            
            // 创建扫描回调
            leScanCallback = BluetoothAdapter.LeScanCallback { device, rssi, scanRecord ->
                // 过滤：只显示有名称的设备
                if (device != null && !device.name.isNullOrEmpty()) {
                    // 使用 LogicalApi 过滤（只保留兼容的设备）
                    val bleDeviceInfo = com.lm.sdk.LogicalApi.getBleDeviceInfoWhenBleScan(
                        device, rssi, scanRecord, true
                    )
                    
                    // 只有通过过滤的设备才发送到 Flutter
                    if (bleDeviceInfo != null) {
                        handler.post {
                            sendEvent(mapOf(
                                "type" to "deviceFound",
                                "device" to mapOf(
                                    "name" to device.name,
                                    "address" to device.address,
                                    "rssi" to rssi
                                )
                            ))
                        }
                    }
                }
            }
            
            // 开始扫描
            @Suppress("DEPRECATION")
            isScanning = adapter.startLeScan(leScanCallback)
            
            // 10秒后自动停止
            handler.postDelayed({
                stopScan()
                handler.post {
                    sendEvent(mapOf("type" to "scanCompleted"))
                }
            }, 10000)
            
            result.success(null)
        } catch (e: Exception) {
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
        val stateString = when (state) {
            BLEService.CONNECT_STATE_SUCCESS -> "connected"
            BLEService.CONNECT_STATE_DISCONNECTED -> "disconnected"
            BLEService.CONNECT_STATE_GATT_CONNECTING -> "connecting"
            else -> "unknown"
        }
        
        handler.post {
            sendEvent(mapOf(
                "type" to "connectionStateChanged",
                "state" to stateString,
                "statusCode" to state
            ))
        }
    }
    
    private fun handleDataReceived(data: ByteArray) {
        handler.post {
            sendEvent(mapOf(
                "type" to "rawData",
                "data" to data.joinToString("") { "%02x".format(it) }
            ))
        }
    }
    
    private fun sendEvent(event: Map<String, Any>) {
        eventSink?.success(event)
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
    
    override fun onDestroy() {
        super.onDestroy()
        stopScan()
        LocalBroadcastManager.getInstance(this).unregisterReceiver(connectionStateReceiver)
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
    }
}
