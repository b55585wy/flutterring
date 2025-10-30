import 'package:flutter/services.dart';
import 'dart:async';

class RingPlatform {
  static const MethodChannel _methodChannel = MethodChannel('ring/method');
  static const EventChannel _eventChannel = EventChannel('ring/events');

  static Stream<Map<String, dynamic>>? _eventStream;

  /// BLE 事件流
  static Stream<Map<String, dynamic>> get eventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _eventStream!;
  }

  /// 扫描设备
  static Future<void> scanDevices() async {
    try {
      await _methodChannel.invokeMethod('scanDevices');
    } catch (e) {
      throw Exception('扫描失败: $e');
    }
  }

  /// 停止扫描
  static Future<void> stopScan() async {
    try {
      await _methodChannel.invokeMethod('stopScan');
    } catch (e) {
      throw Exception('停止扫描失败: $e');
    }
  }

  /// 连接设备
  static Future<void> connectDevice(String macAddress) async {
    try {
      await _methodChannel.invokeMethod('connectDevice', {
        'macAddress': macAddress,
      });
    } catch (e) {
      throw Exception('连接失败: $e');
    }
  }

  /// 断开连接
  static Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } catch (e) {
      throw Exception('断开连接失败: $e');
    }
  }

  /// 获取已连接设备
  static Future<Map<String, dynamic>?> getConnectedDevice() async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectedDevice');
      return result != null ? Map<String, dynamic>.from(result as Map) : null;
    } catch (e) {
      throw Exception('获取设备信息失败: $e');
    }
  }

  /// 开始在线测量
  static Future<void> startLiveMeasurement({int duration = 60}) async {
    try {
      await _methodChannel.invokeMethod('startLiveMeasurement', {
        'duration': duration,
      });
    } catch (e) {
      throw Exception('开始测量失败: $e');
    }
  }

  /// 停止测量
  static Future<void> stopMeasurement() async {
    try {
      await _methodChannel.invokeMethod('stopMeasurement');
    } catch (e) {
      throw Exception('停止测量失败: $e');
    }
  }

  /// 获取设备信息
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _methodChannel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw Exception('获取设备信息失败: $e');
    }
  }
}

/// BLE 事件类型
enum BleEventType {
  deviceFound,
  scanCompleted,
  connectionStateChanged,
  rawData,
  rssiUpdate,
  error,
}

/// BLE 事件
class BleEvent {
  final BleEventType type;
  final Map<String, dynamic> data;

  BleEvent({required this.type, required this.data});

  factory BleEvent.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String;
    final type = _parseEventType(typeString);
    return BleEvent(type: type, data: map);
  }

  static BleEventType _parseEventType(String typeString) {
    switch (typeString) {
      case 'deviceFound':
        return BleEventType.deviceFound;
      case 'scanCompleted':
        return BleEventType.scanCompleted;
      case 'connectionStateChanged':
        return BleEventType.connectionStateChanged;
      case 'rawData':
        return BleEventType.rawData;
      case 'rssiUpdate':
        return BleEventType.rssiUpdate;
      case 'error':
        return BleEventType.error;
      default:
        throw Exception('Unknown event type: $typeString');
    }
  }
}
