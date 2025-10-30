import 'package:freezed_annotation/freezed_annotation.dart';
import 'sample.dart';
import 'ring_file.dart';

part 'ble_event.freezed.dart';
part 'ble_event.g.dart';

/// 蓝牙事件统一模型
@freezed
class BleEvent with _$BleEvent {
  /// 连接状态变化
  const factory BleEvent.connectionStateChanged({
    required ConnectionState state,
    String? deviceName,
    String? macAddress,
  }) = ConnectionStateChanged;
  
  /// 实时样本数据
  const factory BleEvent.sampleBatch({
    required List<Sample> samples,
    required int timestamp,
  }) = SampleBatchEvent;
  
  /// 生理指标更新
  const factory BleEvent.vitalSignsUpdate({
    int? heartRate,
    int? respiratoryRate,
    required SignalQuality quality,
  }) = VitalSignsUpdateEvent;
  
  /// 文件列表响应
  const factory BleEvent.fileListReceived({
    required List<RingFile> files,
  }) = FileListReceivedEvent;
  
  /// 文件下载进度
  const factory BleEvent.downloadProgress({
    required String fileName,
    required double progress,
  }) = DownloadProgressEvent;
  
  /// 错误事件
  const factory BleEvent.error({
    required String message,
    String? code,
  }) = BleErrorEvent;
  
  factory BleEvent.fromJson(Map<String, dynamic> json) => 
      _$BleEventFromJson(json);
}

/// 连接状态枚举
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// 信号质量枚举
enum SignalQuality {
  excellent,
  good,
  fair,
  poor,
  noSignal,
}

extension SignalQualityX on SignalQuality {
  String get displayName {
    switch (this) {
      case SignalQuality.excellent:
        return '优秀';
      case SignalQuality.good:
        return '良好';
      case SignalQuality.fair:
        return '一般';
      case SignalQuality.poor:
        return '较差';
      case SignalQuality.noSignal:
        return '无信号';
    }
  }
  
  String get colorHex {
    switch (this) {
      case SignalQuality.excellent:
        return '#4CAF50';
      case SignalQuality.good:
        return '#8BC34A';
      case SignalQuality.fair:
        return '#FFC107';
      case SignalQuality.poor:
        return '#FF5722';
      case SignalQuality.noSignal:
        return '#9E9E9E';
    }
  }
}

