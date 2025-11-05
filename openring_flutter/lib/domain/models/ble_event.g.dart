// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceFoundEventImpl _$$DeviceFoundEventImplFromJson(
        Map<String, dynamic> json) =>
    _$DeviceFoundEventImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      rssi: (json['rssi'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DeviceFoundEventImplToJson(
        _$DeviceFoundEventImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'rssi': instance.rssi,
      'runtimeType': instance.$type,
    };

_$ScanCompletedEventImpl _$$ScanCompletedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$ScanCompletedEventImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ScanCompletedEventImplToJson(
        _$ScanCompletedEventImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$ConnectionStateChangedEventImpl _$$ConnectionStateChangedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$ConnectionStateChangedEventImpl(
      state: $enumDecode(_$ConnectionStateEnumMap, json['state']),
      deviceName: json['deviceName'] as String?,
      address: json['address'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ConnectionStateChangedEventImplToJson(
        _$ConnectionStateChangedEventImpl instance) =>
    <String, dynamic>{
      'state': _$ConnectionStateEnumMap[instance.state]!,
      'deviceName': instance.deviceName,
      'address': instance.address,
      'runtimeType': instance.$type,
    };

const _$ConnectionStateEnumMap = {
  ConnectionState.disconnected: 'disconnected',
  ConnectionState.connecting: 'connecting',
  ConnectionState.connected: 'connected',
  ConnectionState.disconnecting: 'disconnecting',
  ConnectionState.error: 'error',
};

_$SampleBatchEventImpl _$$SampleBatchEventImplFromJson(
        Map<String, dynamic> json) =>
    _$SampleBatchEventImpl(
      samples: (json['samples'] as List<dynamic>)
          .map((e) => Sample.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: (json['timestamp'] as num).toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SampleBatchEventImplToJson(
        _$SampleBatchEventImpl instance) =>
    <String, dynamic>{
      'samples': instance.samples,
      'timestamp': instance.timestamp,
      'runtimeType': instance.$type,
    };

_$VitalSignsUpdateEventImpl _$$VitalSignsUpdateEventImplFromJson(
        Map<String, dynamic> json) =>
    _$VitalSignsUpdateEventImpl(
      heartRate: (json['heartRate'] as num?)?.toInt(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
      quality: $enumDecode(_$SignalQualityEnumMap, json['quality']),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$VitalSignsUpdateEventImplToJson(
        _$VitalSignsUpdateEventImpl instance) =>
    <String, dynamic>{
      'heartRate': instance.heartRate,
      'respiratoryRate': instance.respiratoryRate,
      'quality': _$SignalQualityEnumMap[instance.quality]!,
      'runtimeType': instance.$type,
    };

const _$SignalQualityEnumMap = {
  SignalQuality.excellent: 'excellent',
  SignalQuality.good: 'good',
  SignalQuality.fair: 'fair',
  SignalQuality.poor: 'poor',
  SignalQuality.noSignal: 'noSignal',
};

_$FileListReceivedEventImpl _$$FileListReceivedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$FileListReceivedEventImpl(
      files: (json['files'] as List<dynamic>)
          .map((e) => RingFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FileListReceivedEventImplToJson(
        _$FileListReceivedEventImpl instance) =>
    <String, dynamic>{
      'files': instance.files,
      'runtimeType': instance.$type,
    };

_$FileDownloadProgressEventImpl _$$FileDownloadProgressEventImplFromJson(
        Map<String, dynamic> json) =>
    _$FileDownloadProgressEventImpl(
      fileName: json['fileName'] as String,
      currentBytes: (json['currentBytes'] as num).toInt(),
      totalBytes: (json['totalBytes'] as num).toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FileDownloadProgressEventImplToJson(
        _$FileDownloadProgressEventImpl instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'currentBytes': instance.currentBytes,
      'totalBytes': instance.totalBytes,
      'runtimeType': instance.$type,
    };

_$FileDownloadCompletedEventImpl _$$FileDownloadCompletedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$FileDownloadCompletedEventImpl(
      fileName: json['fileName'] as String,
      localPath: json['localPath'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FileDownloadCompletedEventImplToJson(
        _$FileDownloadCompletedEventImpl instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'localPath': instance.localPath,
      'runtimeType': instance.$type,
    };

_$RecordingStateChangedEventImpl _$$RecordingStateChangedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$RecordingStateChangedEventImpl(
      state: $enumDecode(_$RecordingStateEnumMap, json['state']),
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$RecordingStateChangedEventImplToJson(
        _$RecordingStateChangedEventImpl instance) =>
    <String, dynamic>{
      'state': _$RecordingStateEnumMap[instance.state]!,
      'progressPercent': instance.progressPercent,
      'remainingSeconds': instance.remainingSeconds,
      'runtimeType': instance.$type,
    };

const _$RecordingStateEnumMap = {
  RecordingState.idle: 'idle',
  RecordingState.scheduling: 'scheduling',
  RecordingState.recording: 'recording',
  RecordingState.waitingDownload: 'waitingDownload',
  RecordingState.downloading: 'downloading',
  RecordingState.readyForPlayback: 'readyForPlayback',
  RecordingState.playingBack: 'playingBack',
  RecordingState.error: 'error',
};

_$RssiUpdatedEventImpl _$$RssiUpdatedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$RssiUpdatedEventImpl(
      rssi: (json['rssi'] as num).toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$RssiUpdatedEventImplToJson(
        _$RssiUpdatedEventImpl instance) =>
    <String, dynamic>{
      'rssi': instance.rssi,
      'runtimeType': instance.$type,
    };

_$BatteryLevelUpdatedEventImpl _$$BatteryLevelUpdatedEventImplFromJson(
        Map<String, dynamic> json) =>
    _$BatteryLevelUpdatedEventImpl(
      level: (json['level'] as num).toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BatteryLevelUpdatedEventImplToJson(
        _$BatteryLevelUpdatedEventImpl instance) =>
    <String, dynamic>{
      'level': instance.level,
      'runtimeType': instance.$type,
    };

_$BleErrorEventImpl _$$BleErrorEventImplFromJson(Map<String, dynamic> json) =>
    _$BleErrorEventImpl(
      message: json['message'] as String,
      code: json['code'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BleErrorEventImplToJson(_$BleErrorEventImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'runtimeType': instance.$type,
    };

_$RingFileImpl _$$RingFileImplFromJson(Map<String, dynamic> json) =>
    _$RingFileImpl(
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      localPath: json['localPath'] as String?,
      isDownloaded: json['isDownloaded'] as bool?,
    );

Map<String, dynamic> _$$RingFileImplToJson(_$RingFileImpl instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'timestamp': instance.timestamp.toIso8601String(),
      'localPath': instance.localPath,
      'isDownloaded': instance.isDownloaded,
    };
