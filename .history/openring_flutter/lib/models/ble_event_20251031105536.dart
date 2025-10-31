import 'package:freezed_annotation/freezed_annotation.dart';
import 'sample.dart';

part 'ble_event.freezed.dart';
part 'ble_event.g.dart';

/// BLE 事件类型枚举
@freezed
class BleEvent with _$BleEvent {
  /// 设备发现事件
  const factory BleEvent.deviceFound({
    required String name,
    required String address,
    int? rssi,
  }) = DeviceFoundEvent;

  /// 扫描完成事件
  const factory BleEvent.scanCompleted() = ScanCompletedEvent;

  /// 连接状态变化事件
  const factory BleEvent.connectionStateChanged({
    required ConnectionState state,
    String? deviceName,
    String? address,
  }) = ConnectionStateChangedEvent;

  /// 样本批次事件（实时数据）
  const factory BleEvent.sampleBatch({
    required List<Sample> samples,
    required int timestamp,
  }) = SampleBatchEvent;

  /// 生理指标更新事件
  const factory BleEvent.vitalSignsUpdate({
    int? heartRate,
    int? respiratoryRate,
    required double signalQuality,
  }) = VitalSignsUpdateEvent;

  /// 文件列表接收事件
  const factory BleEvent.fileListReceived({
    required List<RingFile> files,
  }) = FileListReceivedEvent;

  /// 文件下载进度事件
  const factory BleEvent.fileDownloadProgress({
    required String fileName,
    required int currentBytes,
    required int totalBytes,
  }) = FileDownloadProgressEvent;

  /// 文件下载完成事件
  const factory BleEvent.fileDownloadCompleted({
    required String fileName,
    required String localPath,
  }) = FileDownloadCompletedEvent;

  /// 录制状态变化事件
  const factory BleEvent.recordingStateChanged({
    required RecordingState state,
    int? progressPercent,
    int? remainingSeconds,
  }) = RecordingStateChangedEvent;

  /// RSSI 更新事件
  const factory BleEvent.rssiUpdated({
    required int rssi,
  }) = RssiUpdatedEvent;

  /// 电量更新事件
  const factory BleEvent.batteryLevelUpdated({
    required int level,
  }) = BatteryLevelUpdatedEvent;

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
  disconnecting,
  error,
}

/// 录制状态枚举
enum RecordingState {
  idle,
  scheduling,
  recording,
  waitingDownload,
  downloading,
  readyForPlayback,
  playingBack,
  error,
}

/// 戒指文件信息
@freezed
class RingFile with _$RingFile {
  const factory RingFile({
    required String fileName,
    required int fileSize,
    required DateTime timestamp,
    String? localPath,
    bool? isDownloaded,
  }) = _RingFile;

  factory RingFile.fromJson(Map<String, dynamic> json) =>
      _$RingFileFromJson(json);
}
