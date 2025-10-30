package com.tsinghua.openring

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "ring/method"
    private val EVENT_CHANNEL = "ring/events"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 配置 Method Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "scanDevices" -> {
                    // TODO: 调用 BLEService 扫描设备
                    result.success(null)
                }
                "connectDevice" -> {
                    val macAddress = call.argument<String>("macAddress")
                    // TODO: 连接设备
                    result.success(null)
                }
                "disconnect" -> {
                    // TODO: 断开连接
                    result.success(null)
                }
                "getConnectedDevice" -> {
                    // TODO: 获取已连接设备信息
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
                "startOfflineRecording" -> {
                    val totalDuration = call.argument<Int>("totalDuration") ?: 300
                    val segmentDuration = call.argument<Int>("segmentDuration") ?: 60
                    // TODO: 启动离线录制
                    result.success(null)
                }
                "getFileList" -> {
                    // TODO: 获取文件列表
                    result.success(emptyList<Map<String, Any>>())
                }
                "downloadFile" -> {
                    val fileName = call.argument<String>("fileName")
                    // TODO: 下载文件
                    result.success("/path/to/file")
                }
                "deleteFile" -> {
                    val fileName = call.argument<String>("fileName")
                    // TODO: 删除文件
                    result.success(null)
                }
                "updateDeviceTime" -> {
                    // TODO: 更新设备时间
                    result.success(null)
                }
                "calibrateTime" -> {
                    // TODO: 校准时间
                    result.success(null)
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
                // TODO: 订阅 BLE 事件
                
                // 示例：发送模拟事件
                Handler(Looper.getMainLooper()).postDelayed({
                    sendConnectionEvent("disconnected", null, null)
                }, 1000)
            }
            
            override fun onCancel(arguments: Any?) {
                eventSink = null
                // TODO: 取消订阅
            }
        })
    }
    
    // 辅助方法：发送连接状态事件
    private fun sendConnectionEvent(state: String, deviceName: String?, macAddress: String?) {
        val event = mapOf(
            "type" to "connectionStateChanged",
            "state" to state,
            "deviceName" to deviceName,
            "macAddress" to macAddress
        )
        eventSink?.success(event)
    }
    
    // 辅助方法：发送样本数据事件
    private fun sendSampleBatch(samples: List<Map<String, Any>>, timestamp: Long) {
        val event = mapOf(
            "type" to "sampleBatch",
            "samples" to samples,
            "timestamp" to timestamp
        )
        eventSink?.success(event)
    }
    
    // 辅助方法：发送错误事件
    private fun sendError(message: String, code: String? = null) {
        val event = mapOf(
            "type" to "error",
            "message" to message,
            "code" to code
        )
        eventSink?.success(event)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }
}

