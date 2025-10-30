import 'dart:async';
import 'package:flutter/services.dart';
import '../models/ble_event.dart';
import '../models/ring_file.dart';

/// Platform Channel 统一接口
class RingPlatformInterface {
  static const MethodChannel _methodChannel = MethodChannel('ring/method');
  static const EventChannel _eventChannel = EventChannel('ring/events');
  
  Stream<BleEvent>? _eventStream;
  
  /// 单例模式
  static final RingPlatformInterface _instance = RingPlatformInterface._internal();
  factory RingPlatformInterface() => _instance;
  RingPlatformInterface._internal();
  
  /// 事件流（单例，避免重复订阅）
  Stream<BleEvent> get eventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          try {
            return BleEvent.fromJson(Map<String, dynamic>.from(event as Map));
          } catch (e) {
            return BleEvent.error(message: 'Failed to parse event: $e');
          }
        });
    return _eventStream!;
  }
  
  // ==================== 设备管理 ====================
  
  /// 扫描设备
  Future<void> scanDevices() async {
    try {
      await _methodChannel.invokeMethod('scanDevices');
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 连接设备
  Future<void> connectDevice(String macAddress) async {
    try {
      await _methodChannel.invokeMethod('connectDevice', {
        'macAddress': macAddress,
      });
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 断开连接
  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 获取已连接设备信息
  Future<Map<String, dynamic>?> getConnectedDevice() async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectedDevice');
      return result != null ? Map<String, dynamic>.from(result as Map) : null;
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== 测量控制 ====================
  
  /// 启动在线测量
  Future<void> startLiveMeasurement(int duration) async {
    try {
      await _methodChannel.invokeMethod('startLiveMeasurement', {
        'duration': duration,
      });
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 停止测量
  Future<void> stopMeasurement() async {
    try {
      await _methodChannel.invokeMethod('stopMeasurement');
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 启动离线录制
  Future<void> startOfflineRecording({
    required int totalDuration,
    required int segmentDuration,
  }) async {
    try {
      await _methodChannel.invokeMethod('startOfflineRecording', {
        'totalDuration': totalDuration,
        'segmentDuration': segmentDuration,
      });
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== 文件操作 ====================
  
  /// 获取文件列表
  Future<List<RingFile>> getFileList() async {
    try {
      final result = await _methodChannel.invokeMethod('getFileList');
      if (result == null) return [];
      
      final List<dynamic> fileList = result as List<dynamic>;
      return fileList
          .map((e) => RingFile.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 下载文件
  Future<String> downloadFile(String fileName) async {
    try {
      final result = await _methodChannel.invokeMethod('downloadFile', {
        'fileName': fileName,
      });
      return result as String; // 返回本地文件路径
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 删除文件
  Future<void> deleteFile(String fileName) async {
    try {
      await _methodChannel.invokeMethod('deleteFile', {
        'fileName': fileName,
      });
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== 时间同步 ====================
  
  /// 更新设备时间
  Future<void> updateDeviceTime() async {
    try {
      await _methodChannel.invokeMethod('updateDeviceTime');
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 校准时间
  Future<void> calibrateTime() async {
    try {
      await _methodChannel.invokeMethod('calibrateTime');
    } on PlatformException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== 错误处理 ====================
  
  Exception _handleError(PlatformException e) {
    return Exception('Platform Error [${e.code}]: ${e.message}');
  }
}

