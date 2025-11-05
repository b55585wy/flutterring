import 'dart:async';
import 'package:flutter/services.dart';
import '../models/ble_event.dart';
import '../models/sample.dart';
import '../models/device_info.dart';

/// Platform Channel 接口
class RingPlatform {
  static const MethodChannel _methodChannel = MethodChannel('ring/method');
  static const EventChannel _eventChannel = EventChannel('ring/events');

  /// 事件流（统一的 BLE 事件）
  static final Stream<BleEvent> _cachedEventStream =
      _eventChannel.receiveBroadcastStream().map((event) {
    print('🔵 Flutter Platform: 收到原始事件 - $event');

      final map = Map<String, dynamic>.from(event as Map);
      final type = map['type'] as String;
      print('🔵 Flutter Platform: 事件类型 - $type');

      switch (type) {
        case 'deviceFound':
          final device = Map<String, dynamic>.from(map['device'] as Map);
          print(
              '🔵 Flutter Platform: 解析设备 - ${device['name']} (${device['address']})');
          return BleEvent.deviceFound(
            name: device['name'] as String,
            address: device['address'] as String,
            rssi: device['rssi'] as int?,
          );
//      scan completed event
        case 'scanCompleted':
          return const BleEvent.scanCompleted();

        case 'connectionStateChanged':
          // MainActivity.kt 直接在根级别发送 state，不在 data 里
          final stateString = map['state'] as String;
          final state = _parseConnectionState(stateString);
          return BleEvent.connectionStateChanged(
            state: state,
            deviceName: map['deviceName'] as String?,
            address: map['address'] as String?,
          );

        case 'sampleBatch':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          final samplesJson =
              (data['samples'] as List).cast<Map<String, dynamic>>();
          final samples =
              samplesJson.map((json) => Sample.fromJson(json)).toList();
          return BleEvent.sampleBatch(
            samples: samples,
            timestamp: data['timestamp'] as int,
          );

        case 'vitalSignsUpdate':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.vitalSignsUpdate(
            heartRate: data['heartRate'] as int?,
            respiratoryRate: data['respiratoryRate'] as int?,
            quality: _parseSignalQuality(
                data['signalQuality'] as String? ?? 'noSignal'),
          );

        case 'fileListReceived':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          final filesJson =
              (data['files'] as List).cast<Map<String, dynamic>>();
          final files =
              filesJson.map((json) => RingFile.fromJson(json)).toList();
          return BleEvent.fileListReceived(files: files);

        case 'fileDownloadProgress':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.fileDownloadProgress(
            fileName: data['fileName'] as String,
            currentBytes: data['currentBytes'] as int,
            totalBytes: data['totalBytes'] as int,
          );

        case 'fileDownloadCompleted':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.fileDownloadCompleted(
            fileName: data['fileName'] as String,
            localPath: data['localPath'] as String,
          );

        case 'recordingStateChanged':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          final stateString = data['state'] as String;
          final state = _parseRecordingState(stateString);
          return BleEvent.recordingStateChanged(
            state: state,
            progressPercent: data['progressPercent'] as int?,
            remainingSeconds: data['remainingSeconds'] as int?,
          );

        case 'rssiUpdated':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.rssiUpdated(rssi: data['rssi'] as int);

        case 'batteryLevelUpdated':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.batteryLevelUpdated(level: data['level'] as int);

        case 'error':
          final data = Map<String, dynamic>.from(map['data'] as Map);
          return BleEvent.error(
            message: data['message'] as String,
            code: data['code'] as String?,
          );

        default:
          return BleEvent.error(message: 'Unknown event type: $type');
      }
    }).asBroadcastStream();
  static Stream<BleEvent> get eventStream => _cachedEventStream;

  /// 扫描设备
  static Future<void> scanDevices() async {
    try {
      await _methodChannel.invokeMethod('scanDevices');
    } on PlatformException catch (e) {
      throw Exception('Failed to scan devices: ${e.message}');
    }
  }

  /// 停止扫描
  static Future<void> stopScan() async {
    try {
      await _methodChannel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop scan: ${e.message}');
    }
  }

  /// 连接设备
  static Future<void> connectDevice(String macAddress) async {
    try {
      await _methodChannel
          .invokeMethod('connectDevice', {'macAddress': macAddress});
    } on PlatformException catch (e) {
      throw Exception('Failed to connect device: ${e.message}');
    }
  }

  /// 断开连接
  static Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }

  /// 启动在线测量
  static Future<void> startLiveMeasurement({int duration = 60}) async {
    try {
      await _methodChannel.invokeMethod('startLiveMeasurement', {
        'duration': duration,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start live measurement: ${e.message}');
    }
  }

  /// 停止测量
  static Future<void> stopMeasurement() async {
    try {
      await _methodChannel.invokeMethod('stopMeasurement');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop measurement: ${e.message}');
    }
  }

  /// 获取已连接设备信息
  static Future<DeviceInfo?> getConnectedDevice() async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectedDevice');
      if (result != null) {
        return DeviceInfo.fromJson(Map<String, dynamic>.from(result));
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('Failed to get connected device: ${e.message}');
    }
  }

  /// 启动离线录制
  static Future<void> startOfflineRecording({
    required int totalDuration,
    required int segmentDuration,
    required int samplingMode,
    bool autoDisconnect = false,
  }) async {
    try {
      await _methodChannel.invokeMethod('startOfflineRecording', {
        'totalDuration': totalDuration,
        'segmentDuration': segmentDuration,
        'samplingMode': samplingMode,
        'autoDisconnect': autoDisconnect,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start offline recording: ${e.message}');
    }
  }

  /// 停止离线录制
  static Future<void> stopOfflineRecording() async {
    try {
      await _methodChannel.invokeMethod('stopOfflineRecording');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop offline recording: ${e.message}');
    }
  }

  /// 获取设备信息（版本、电量等）
  static Future<DeviceInfo?> getDeviceInfo() async {
    try {
      final result = await _methodChannel.invokeMethod('getDeviceInfo');
      if (result != null) {
        return DeviceInfo.fromJson(Map<String, dynamic>.from(result));
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('Failed to get device info: ${e.message}');
    }
  }

  /// 获取电量
  static Future<int?> getBatteryLevel() async {
    try {
      return await _methodChannel.invokeMethod<int>('getBatteryLevel');
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }

  /// 同步设备时间
  static Future<void> updateDeviceTime() async {
    try {
      await _methodChannel.invokeMethod('updateDeviceTime');
    } on PlatformException catch (e) {
      throw Exception('Failed to update device time: ${e.message}');
    }
  }

  /// 校准时间
  static Future<void> calibrateTime() async {
    try {
      await _methodChannel.invokeMethod('calibrateTime');
    } on PlatformException catch (e) {
      throw Exception('Failed to calibrate time: ${e.message}');
    }
  }

  /// 获取文件列表
  static Future<List<RingFile>> getFileList() async {
    try {
      final result = await _methodChannel.invokeMethod('getFileList');
      if (result != null) {
        final List<dynamic> filesJson = result as List;
        return filesJson
            .map((json) => RingFile.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } on PlatformException catch (e) {
      throw Exception('Failed to get file list: ${e.message}');
    }
  }

  /// 下载文件
  static Future<void> downloadFile(String fileName) async {
    try {
      await _methodChannel.invokeMethod('downloadFile', {'fileName': fileName});
    } on PlatformException catch (e) {
      throw Exception('Failed to download file: ${e.message}');
    }
  }

  /// 删除文件
  static Future<void> deleteFile(String fileName) async {
    try {
      await _methodChannel.invokeMethod('deleteFile', {'fileName': fileName});
    } on PlatformException catch (e) {
      throw Exception('Failed to delete file: ${e.message}');
    }
  }

  /// 格式化文件系统
  static Future<void> formatFileSystem() async {
    try {
      await _methodChannel.invokeMethod('formatFileSystem');
    } on PlatformException catch (e) {
      throw Exception('Failed to format file system: ${e.message}');
    }
  }

  // 辅助方法：解析连接状态
  static ConnectionState _parseConnectionState(String state) {
    switch (state) {
      case 'disconnected':
        return ConnectionState.disconnected;
      case 'connecting':
        return ConnectionState.connecting;
      case 'connected':
        return ConnectionState.connected;
      case 'disconnecting':
        return ConnectionState.disconnecting;
      case 'error':
        return ConnectionState.error;
      default:
        return ConnectionState.disconnected;
    }
  }

  // 辅助方法：解析录制状态
  static RecordingState _parseRecordingState(String state) {
    switch (state) {
      case 'idle':
        return RecordingState.idle;
      case 'scheduling':
        return RecordingState.scheduling;
      case 'recording':
        return RecordingState.recording;
      case 'waitingDownload':
        return RecordingState.waitingDownload;
      case 'downloading':
        return RecordingState.downloading;
      case 'readyForPlayback':
        return RecordingState.readyForPlayback;
      case 'playingBack':
        return RecordingState.playingBack;
      case 'error':
        return RecordingState.error;
      default:
        return RecordingState.idle;
    }
  }

  // 辅助方法：解析信号质量
  static SignalQuality _parseSignalQuality(String quality) {
    switch (quality) {
      case 'excellent':
        return SignalQuality.excellent;
      case 'good':
        return SignalQuality.good;
      case 'fair':
        return SignalQuality.fair;
      case 'poor':
        return SignalQuality.poor;
      case 'noSignal':
      default:
        return SignalQuality.noSignal;
    }
  }
}
