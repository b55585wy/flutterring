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
import com.tsinghua.openring.utils.BLEService
import com.tsinghua.openring.utils.NotificationHandler
import com.realsil.sdk.core.bluetooth.LmAPI
import com.realsil.sdk.core.bluetooth.callback.*

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "ring/method"
    private val EVENT_CHANNEL = "ring/events"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 配置 Method Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "scanDevices" -> {
                    scanDevices(result)
                }
                "stopScan" -> {
                    LmAPI.SCAN_STOP(this@MainActivity)
                    result.success(null)
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
                    LmAPI.DEVICE_DISCONNECT(this@MainActivity)
                    result.success(null)
                }
                "getConnectedDevice" -> {
                    // TODO: 获取当前连接的设备信息
                    result.success(null)
                }
                "startLiveMeasurement" -> {
                    val duration = call.argument<Int>("duration") ?: 60
                    // TODO: 启动在线测量
                    result.success(null)
                }
                "stopMeasurement" -> {
                    // TODO: 停止测量
                    result.success(null)
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
                setupBleCallbacks()
            }
            
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }
    
    private fun scanDevices(result: MethodChannel.Result) {
        try {
            LmAPI.SCAN_DEVICE(this@MainActivity, object : IBluetoothDiscoveryCallback {
                override fun onDeviceFound(device: BluetoothDevice) {
                    handler.post {
                        sendEvent(mapOf(
                            "type" to "deviceFound",
                            "device" to mapOf(
                                "name" to (device.name ?: "Unknown"),
                                "address" to device.address
                            )
                        ))
                    }
                }
                
                override fun onDiscoveryFinished() {
                    handler.post {
                        sendEvent(mapOf("type" to "scanCompleted"))
                    }
                }
            })
            result.success(null)
        } catch (e: Exception) {
            result.error("SCAN_ERROR", e.message, null)
        }
    }
    
    private fun connectDevice(macAddress: String, result: MethodChannel.Result) {
        try {
            val adapter = BluetoothAdapter.getDefaultAdapter()
            val device = adapter.getRemoteDevice(macAddress)
            
            LmAPI.DEVICE_CONNECT(this@MainActivity, device, object : IConnectionCallback {
                override fun onConnectionSucceeded(status: Int) {
                    handler.post {
                        sendEvent(mapOf(
                            "type" to "connectionStateChanged",
                            "state" to "connected",
                            "address" to macAddress
                        ))
                    }
                }
                
                override fun onConnectionFailed(status: Int) {
                    handler.post {
                        sendEvent(mapOf(
                            "type" to "connectionStateChanged",
                            "state" to "disconnected",
                            "address" to macAddress
                        ))
                    }
                }
                
                override fun onDisconnected(status: Int) {
                    handler.post {
                        sendEvent(mapOf(
                            "type" to "connectionStateChanged",
                            "state" to "disconnected",
                            "address" to macAddress
                        ))
                    }
                }
            })
            result.success(null)
        } catch (e: Exception) {
            result.error("CONNECT_ERROR", e.message, null)
        }
    }
    
    private fun setupBleCallbacks() {
        // 订阅 BLE 数据回调
        LmAPI.addWLSCmdListener(this@MainActivity, object : IResponseListener {
            override fun saveData(data: String) {
                // 原始数据回调
                handler.post {
                    sendEvent(mapOf(
                        "type" to "rawData",
                        "data" to data
                    ))
                }
            }
            
            override fun lmBleConnectionSucceeded(status: Int) {
                handler.post {
                    sendEvent(mapOf(
                        "type" to "connectionStateChanged",
                        "state" to "connected"
                    ))
                }
            }
            
            override fun lmBleConnectionFailed(status: Int) {
                handler.post {
                    sendEvent(mapOf(
                        "type" to "connectionStateChanged",
                        "state" to "failed"
                    ))
                }
            }
            
            override fun lmBleDisconnected(status: Int) {
                handler.post {
                    sendEvent(mapOf(
                        "type" to "connectionStateChanged",
                        "state" to "disconnected"
                    ))
                }
            }
            
            // 其他回调方法根据需要实现
            override fun rssiUpdate(rssi: Int) {
                handler.post {
                    sendEvent(mapOf(
                        "type" to "rssiUpdate",
                        "rssi" to rssi
                    ))
                }
            }
            
            override fun onError(errorCode: Int, message: String?) {
                handler.post {
                    sendEvent(mapOf(
                        "type" to "error",
                        "code" to errorCode,
                        "message" to (message ?: "Unknown error")
                    ))
                }
            }
        })
    }
    
    private fun sendEvent(event: Map<String, Any>) {
        eventSink?.success(event)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
    }
}
