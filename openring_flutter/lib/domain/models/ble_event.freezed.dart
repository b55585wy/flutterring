// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BleEvent _$BleEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'deviceFound':
      return DeviceFoundEvent.fromJson(json);
    case 'scanCompleted':
      return ScanCompletedEvent.fromJson(json);
    case 'connectionStateChanged':
      return ConnectionStateChangedEvent.fromJson(json);
    case 'sampleBatch':
      return SampleBatchEvent.fromJson(json);
    case 'vitalSignsUpdate':
      return VitalSignsUpdateEvent.fromJson(json);
    case 'fileListReceived':
      return FileListReceivedEvent.fromJson(json);
    case 'fileDownloadProgress':
      return FileDownloadProgressEvent.fromJson(json);
    case 'fileDownloadCompleted':
      return FileDownloadCompletedEvent.fromJson(json);
    case 'recordingStateChanged':
      return RecordingStateChangedEvent.fromJson(json);
    case 'rssiUpdated':
      return RssiUpdatedEvent.fromJson(json);
    case 'batteryLevelUpdated':
      return BatteryLevelUpdatedEvent.fromJson(json);
    case 'error':
      return BleErrorEvent.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'BleEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$BleEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this BleEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleEventCopyWith<$Res> {
  factory $BleEventCopyWith(BleEvent value, $Res Function(BleEvent) then) =
      _$BleEventCopyWithImpl<$Res, BleEvent>;
}

/// @nodoc
class _$BleEventCopyWithImpl<$Res, $Val extends BleEvent>
    implements $BleEventCopyWith<$Res> {
  _$BleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DeviceFoundEventImplCopyWith<$Res> {
  factory _$$DeviceFoundEventImplCopyWith(_$DeviceFoundEventImpl value,
          $Res Function(_$DeviceFoundEventImpl) then) =
      __$$DeviceFoundEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, String address, int? rssi});
}

/// @nodoc
class __$$DeviceFoundEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$DeviceFoundEventImpl>
    implements _$$DeviceFoundEventImplCopyWith<$Res> {
  __$$DeviceFoundEventImplCopyWithImpl(_$DeviceFoundEventImpl _value,
      $Res Function(_$DeviceFoundEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? rssi = freezed,
  }) {
    return _then(_$DeviceFoundEventImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      rssi: freezed == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceFoundEventImpl implements DeviceFoundEvent {
  const _$DeviceFoundEventImpl(
      {required this.name,
      required this.address,
      this.rssi,
      final String? $type})
      : $type = $type ?? 'deviceFound';

  factory _$DeviceFoundEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceFoundEventImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final int? rssi;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.deviceFound(name: $name, address: $address, rssi: $rssi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceFoundEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.rssi, rssi) || other.rssi == rssi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, address, rssi);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceFoundEventImplCopyWith<_$DeviceFoundEventImpl> get copyWith =>
      __$$DeviceFoundEventImplCopyWithImpl<_$DeviceFoundEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return deviceFound(name, address, rssi);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return deviceFound?.call(name, address, rssi);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (deviceFound != null) {
      return deviceFound(name, address, rssi);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return deviceFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return deviceFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (deviceFound != null) {
      return deviceFound(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceFoundEventImplToJson(
      this,
    );
  }
}

abstract class DeviceFoundEvent implements BleEvent {
  const factory DeviceFoundEvent(
      {required final String name,
      required final String address,
      final int? rssi}) = _$DeviceFoundEventImpl;

  factory DeviceFoundEvent.fromJson(Map<String, dynamic> json) =
      _$DeviceFoundEventImpl.fromJson;

  String get name;
  String get address;
  int? get rssi;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceFoundEventImplCopyWith<_$DeviceFoundEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ScanCompletedEventImplCopyWith<$Res> {
  factory _$$ScanCompletedEventImplCopyWith(_$ScanCompletedEventImpl value,
          $Res Function(_$ScanCompletedEventImpl) then) =
      __$$ScanCompletedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ScanCompletedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$ScanCompletedEventImpl>
    implements _$$ScanCompletedEventImplCopyWith<$Res> {
  __$$ScanCompletedEventImplCopyWithImpl(_$ScanCompletedEventImpl _value,
      $Res Function(_$ScanCompletedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$ScanCompletedEventImpl implements ScanCompletedEvent {
  const _$ScanCompletedEventImpl({final String? $type})
      : $type = $type ?? 'scanCompleted';

  factory _$ScanCompletedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanCompletedEventImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.scanCompleted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ScanCompletedEventImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return scanCompleted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return scanCompleted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (scanCompleted != null) {
      return scanCompleted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return scanCompleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return scanCompleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (scanCompleted != null) {
      return scanCompleted(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanCompletedEventImplToJson(
      this,
    );
  }
}

abstract class ScanCompletedEvent implements BleEvent {
  const factory ScanCompletedEvent() = _$ScanCompletedEventImpl;

  factory ScanCompletedEvent.fromJson(Map<String, dynamic> json) =
      _$ScanCompletedEventImpl.fromJson;
}

/// @nodoc
abstract class _$$ConnectionStateChangedEventImplCopyWith<$Res> {
  factory _$$ConnectionStateChangedEventImplCopyWith(
          _$ConnectionStateChangedEventImpl value,
          $Res Function(_$ConnectionStateChangedEventImpl) then) =
      __$$ConnectionStateChangedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConnectionState state, String? deviceName, String? address});
}

/// @nodoc
class __$$ConnectionStateChangedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$ConnectionStateChangedEventImpl>
    implements _$$ConnectionStateChangedEventImplCopyWith<$Res> {
  __$$ConnectionStateChangedEventImplCopyWithImpl(
      _$ConnectionStateChangedEventImpl _value,
      $Res Function(_$ConnectionStateChangedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? deviceName = freezed,
    Object? address = freezed,
  }) {
    return _then(_$ConnectionStateChangedEventImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as ConnectionState,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionStateChangedEventImpl implements ConnectionStateChangedEvent {
  const _$ConnectionStateChangedEventImpl(
      {required this.state, this.deviceName, this.address, final String? $type})
      : $type = $type ?? 'connectionStateChanged';

  factory _$ConnectionStateChangedEventImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ConnectionStateChangedEventImplFromJson(json);

  @override
  final ConnectionState state;
  @override
  final String? deviceName;
  @override
  final String? address;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.connectionStateChanged(state: $state, deviceName: $deviceName, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStateChangedEventImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, state, deviceName, address);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStateChangedEventImplCopyWith<_$ConnectionStateChangedEventImpl>
      get copyWith => __$$ConnectionStateChangedEventImplCopyWithImpl<
          _$ConnectionStateChangedEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return connectionStateChanged(state, deviceName, address);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return connectionStateChanged?.call(state, deviceName, address);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (connectionStateChanged != null) {
      return connectionStateChanged(state, deviceName, address);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return connectionStateChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return connectionStateChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (connectionStateChanged != null) {
      return connectionStateChanged(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionStateChangedEventImplToJson(
      this,
    );
  }
}

abstract class ConnectionStateChangedEvent implements BleEvent {
  const factory ConnectionStateChangedEvent(
      {required final ConnectionState state,
      final String? deviceName,
      final String? address}) = _$ConnectionStateChangedEventImpl;

  factory ConnectionStateChangedEvent.fromJson(Map<String, dynamic> json) =
      _$ConnectionStateChangedEventImpl.fromJson;

  ConnectionState get state;
  String? get deviceName;
  String? get address;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStateChangedEventImplCopyWith<_$ConnectionStateChangedEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SampleBatchEventImplCopyWith<$Res> {
  factory _$$SampleBatchEventImplCopyWith(_$SampleBatchEventImpl value,
          $Res Function(_$SampleBatchEventImpl) then) =
      __$$SampleBatchEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Sample> samples, int timestamp});
}

/// @nodoc
class __$$SampleBatchEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$SampleBatchEventImpl>
    implements _$$SampleBatchEventImplCopyWith<$Res> {
  __$$SampleBatchEventImplCopyWithImpl(_$SampleBatchEventImpl _value,
      $Res Function(_$SampleBatchEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? samples = null,
    Object? timestamp = null,
  }) {
    return _then(_$SampleBatchEventImpl(
      samples: null == samples
          ? _value._samples
          : samples // ignore: cast_nullable_to_non_nullable
              as List<Sample>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SampleBatchEventImpl implements SampleBatchEvent {
  const _$SampleBatchEventImpl(
      {required final List<Sample> samples,
      required this.timestamp,
      final String? $type})
      : _samples = samples,
        $type = $type ?? 'sampleBatch';

  factory _$SampleBatchEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SampleBatchEventImplFromJson(json);

  final List<Sample> _samples;
  @override
  List<Sample> get samples {
    if (_samples is EqualUnmodifiableListView) return _samples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_samples);
  }

  @override
  final int timestamp;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.sampleBatch(samples: $samples, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SampleBatchEventImpl &&
            const DeepCollectionEquality().equals(other._samples, _samples) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_samples), timestamp);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SampleBatchEventImplCopyWith<_$SampleBatchEventImpl> get copyWith =>
      __$$SampleBatchEventImplCopyWithImpl<_$SampleBatchEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return sampleBatch(samples, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return sampleBatch?.call(samples, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (sampleBatch != null) {
      return sampleBatch(samples, timestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return sampleBatch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return sampleBatch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (sampleBatch != null) {
      return sampleBatch(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SampleBatchEventImplToJson(
      this,
    );
  }
}

abstract class SampleBatchEvent implements BleEvent {
  const factory SampleBatchEvent(
      {required final List<Sample> samples,
      required final int timestamp}) = _$SampleBatchEventImpl;

  factory SampleBatchEvent.fromJson(Map<String, dynamic> json) =
      _$SampleBatchEventImpl.fromJson;

  List<Sample> get samples;
  int get timestamp;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SampleBatchEventImplCopyWith<_$SampleBatchEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VitalSignsUpdateEventImplCopyWith<$Res> {
  factory _$$VitalSignsUpdateEventImplCopyWith(
          _$VitalSignsUpdateEventImpl value,
          $Res Function(_$VitalSignsUpdateEventImpl) then) =
      __$$VitalSignsUpdateEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? heartRate, int? respiratoryRate, SignalQuality quality});
}

/// @nodoc
class __$$VitalSignsUpdateEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$VitalSignsUpdateEventImpl>
    implements _$$VitalSignsUpdateEventImplCopyWith<$Res> {
  __$$VitalSignsUpdateEventImplCopyWithImpl(_$VitalSignsUpdateEventImpl _value,
      $Res Function(_$VitalSignsUpdateEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartRate = freezed,
    Object? respiratoryRate = freezed,
    Object? quality = null,
  }) {
    return _then(_$VitalSignsUpdateEventImpl(
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      respiratoryRate: freezed == respiratoryRate
          ? _value.respiratoryRate
          : respiratoryRate // ignore: cast_nullable_to_non_nullable
              as int?,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as SignalQuality,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VitalSignsUpdateEventImpl implements VitalSignsUpdateEvent {
  const _$VitalSignsUpdateEventImpl(
      {this.heartRate,
      this.respiratoryRate,
      required this.quality,
      final String? $type})
      : $type = $type ?? 'vitalSignsUpdate';

  factory _$VitalSignsUpdateEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$VitalSignsUpdateEventImplFromJson(json);

  @override
  final int? heartRate;
  @override
  final int? respiratoryRate;
  @override
  final SignalQuality quality;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.vitalSignsUpdate(heartRate: $heartRate, respiratoryRate: $respiratoryRate, quality: $quality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalSignsUpdateEventImpl &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.respiratoryRate, respiratoryRate) ||
                other.respiratoryRate == respiratoryRate) &&
            (identical(other.quality, quality) || other.quality == quality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, heartRate, respiratoryRate, quality);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalSignsUpdateEventImplCopyWith<_$VitalSignsUpdateEventImpl>
      get copyWith => __$$VitalSignsUpdateEventImplCopyWithImpl<
          _$VitalSignsUpdateEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return vitalSignsUpdate(heartRate, respiratoryRate, quality);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return vitalSignsUpdate?.call(heartRate, respiratoryRate, quality);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (vitalSignsUpdate != null) {
      return vitalSignsUpdate(heartRate, respiratoryRate, quality);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return vitalSignsUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return vitalSignsUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (vitalSignsUpdate != null) {
      return vitalSignsUpdate(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VitalSignsUpdateEventImplToJson(
      this,
    );
  }
}

abstract class VitalSignsUpdateEvent implements BleEvent {
  const factory VitalSignsUpdateEvent(
      {final int? heartRate,
      final int? respiratoryRate,
      required final SignalQuality quality}) = _$VitalSignsUpdateEventImpl;

  factory VitalSignsUpdateEvent.fromJson(Map<String, dynamic> json) =
      _$VitalSignsUpdateEventImpl.fromJson;

  int? get heartRate;
  int? get respiratoryRate;
  SignalQuality get quality;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VitalSignsUpdateEventImplCopyWith<_$VitalSignsUpdateEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FileListReceivedEventImplCopyWith<$Res> {
  factory _$$FileListReceivedEventImplCopyWith(
          _$FileListReceivedEventImpl value,
          $Res Function(_$FileListReceivedEventImpl) then) =
      __$$FileListReceivedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<RingFile> files});
}

/// @nodoc
class __$$FileListReceivedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$FileListReceivedEventImpl>
    implements _$$FileListReceivedEventImplCopyWith<$Res> {
  __$$FileListReceivedEventImplCopyWithImpl(_$FileListReceivedEventImpl _value,
      $Res Function(_$FileListReceivedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? files = null,
  }) {
    return _then(_$FileListReceivedEventImpl(
      files: null == files
          ? _value._files
          : files // ignore: cast_nullable_to_non_nullable
              as List<RingFile>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FileListReceivedEventImpl implements FileListReceivedEvent {
  const _$FileListReceivedEventImpl(
      {required final List<RingFile> files, final String? $type})
      : _files = files,
        $type = $type ?? 'fileListReceived';

  factory _$FileListReceivedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileListReceivedEventImplFromJson(json);

  final List<RingFile> _files;
  @override
  List<RingFile> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.fileListReceived(files: $files)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileListReceivedEventImpl &&
            const DeepCollectionEquality().equals(other._files, _files));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_files));

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileListReceivedEventImplCopyWith<_$FileListReceivedEventImpl>
      get copyWith => __$$FileListReceivedEventImplCopyWithImpl<
          _$FileListReceivedEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return fileListReceived(files);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return fileListReceived?.call(files);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (fileListReceived != null) {
      return fileListReceived(files);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return fileListReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return fileListReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (fileListReceived != null) {
      return fileListReceived(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FileListReceivedEventImplToJson(
      this,
    );
  }
}

abstract class FileListReceivedEvent implements BleEvent {
  const factory FileListReceivedEvent({required final List<RingFile> files}) =
      _$FileListReceivedEventImpl;

  factory FileListReceivedEvent.fromJson(Map<String, dynamic> json) =
      _$FileListReceivedEventImpl.fromJson;

  List<RingFile> get files;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileListReceivedEventImplCopyWith<_$FileListReceivedEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FileDownloadProgressEventImplCopyWith<$Res> {
  factory _$$FileDownloadProgressEventImplCopyWith(
          _$FileDownloadProgressEventImpl value,
          $Res Function(_$FileDownloadProgressEventImpl) then) =
      __$$FileDownloadProgressEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fileName, int currentBytes, int totalBytes});
}

/// @nodoc
class __$$FileDownloadProgressEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$FileDownloadProgressEventImpl>
    implements _$$FileDownloadProgressEventImplCopyWith<$Res> {
  __$$FileDownloadProgressEventImplCopyWithImpl(
      _$FileDownloadProgressEventImpl _value,
      $Res Function(_$FileDownloadProgressEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? currentBytes = null,
    Object? totalBytes = null,
  }) {
    return _then(_$FileDownloadProgressEventImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      currentBytes: null == currentBytes
          ? _value.currentBytes
          : currentBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FileDownloadProgressEventImpl implements FileDownloadProgressEvent {
  const _$FileDownloadProgressEventImpl(
      {required this.fileName,
      required this.currentBytes,
      required this.totalBytes,
      final String? $type})
      : $type = $type ?? 'fileDownloadProgress';

  factory _$FileDownloadProgressEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileDownloadProgressEventImplFromJson(json);

  @override
  final String fileName;
  @override
  final int currentBytes;
  @override
  final int totalBytes;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.fileDownloadProgress(fileName: $fileName, currentBytes: $currentBytes, totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileDownloadProgressEventImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.currentBytes, currentBytes) ||
                other.currentBytes == currentBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fileName, currentBytes, totalBytes);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileDownloadProgressEventImplCopyWith<_$FileDownloadProgressEventImpl>
      get copyWith => __$$FileDownloadProgressEventImplCopyWithImpl<
          _$FileDownloadProgressEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return fileDownloadProgress(fileName, currentBytes, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return fileDownloadProgress?.call(fileName, currentBytes, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (fileDownloadProgress != null) {
      return fileDownloadProgress(fileName, currentBytes, totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return fileDownloadProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return fileDownloadProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (fileDownloadProgress != null) {
      return fileDownloadProgress(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FileDownloadProgressEventImplToJson(
      this,
    );
  }
}

abstract class FileDownloadProgressEvent implements BleEvent {
  const factory FileDownloadProgressEvent(
      {required final String fileName,
      required final int currentBytes,
      required final int totalBytes}) = _$FileDownloadProgressEventImpl;

  factory FileDownloadProgressEvent.fromJson(Map<String, dynamic> json) =
      _$FileDownloadProgressEventImpl.fromJson;

  String get fileName;
  int get currentBytes;
  int get totalBytes;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileDownloadProgressEventImplCopyWith<_$FileDownloadProgressEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FileDownloadCompletedEventImplCopyWith<$Res> {
  factory _$$FileDownloadCompletedEventImplCopyWith(
          _$FileDownloadCompletedEventImpl value,
          $Res Function(_$FileDownloadCompletedEventImpl) then) =
      __$$FileDownloadCompletedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fileName, String localPath});
}

/// @nodoc
class __$$FileDownloadCompletedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$FileDownloadCompletedEventImpl>
    implements _$$FileDownloadCompletedEventImplCopyWith<$Res> {
  __$$FileDownloadCompletedEventImplCopyWithImpl(
      _$FileDownloadCompletedEventImpl _value,
      $Res Function(_$FileDownloadCompletedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? localPath = null,
  }) {
    return _then(_$FileDownloadCompletedEventImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FileDownloadCompletedEventImpl implements FileDownloadCompletedEvent {
  const _$FileDownloadCompletedEventImpl(
      {required this.fileName, required this.localPath, final String? $type})
      : $type = $type ?? 'fileDownloadCompleted';

  factory _$FileDownloadCompletedEventImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$FileDownloadCompletedEventImplFromJson(json);

  @override
  final String fileName;
  @override
  final String localPath;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.fileDownloadCompleted(fileName: $fileName, localPath: $localPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileDownloadCompletedEventImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fileName, localPath);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileDownloadCompletedEventImplCopyWith<_$FileDownloadCompletedEventImpl>
      get copyWith => __$$FileDownloadCompletedEventImplCopyWithImpl<
          _$FileDownloadCompletedEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return fileDownloadCompleted(fileName, localPath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return fileDownloadCompleted?.call(fileName, localPath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (fileDownloadCompleted != null) {
      return fileDownloadCompleted(fileName, localPath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return fileDownloadCompleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return fileDownloadCompleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (fileDownloadCompleted != null) {
      return fileDownloadCompleted(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FileDownloadCompletedEventImplToJson(
      this,
    );
  }
}

abstract class FileDownloadCompletedEvent implements BleEvent {
  const factory FileDownloadCompletedEvent(
      {required final String fileName,
      required final String localPath}) = _$FileDownloadCompletedEventImpl;

  factory FileDownloadCompletedEvent.fromJson(Map<String, dynamic> json) =
      _$FileDownloadCompletedEventImpl.fromJson;

  String get fileName;
  String get localPath;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileDownloadCompletedEventImplCopyWith<_$FileDownloadCompletedEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RecordingStateChangedEventImplCopyWith<$Res> {
  factory _$$RecordingStateChangedEventImplCopyWith(
          _$RecordingStateChangedEventImpl value,
          $Res Function(_$RecordingStateChangedEventImpl) then) =
      __$$RecordingStateChangedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {RecordingState state, int? progressPercent, int? remainingSeconds});
}

/// @nodoc
class __$$RecordingStateChangedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$RecordingStateChangedEventImpl>
    implements _$$RecordingStateChangedEventImplCopyWith<$Res> {
  __$$RecordingStateChangedEventImplCopyWithImpl(
      _$RecordingStateChangedEventImpl _value,
      $Res Function(_$RecordingStateChangedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? progressPercent = freezed,
    Object? remainingSeconds = freezed,
  }) {
    return _then(_$RecordingStateChangedEventImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as RecordingState,
      progressPercent: freezed == progressPercent
          ? _value.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingSeconds: freezed == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordingStateChangedEventImpl implements RecordingStateChangedEvent {
  const _$RecordingStateChangedEventImpl(
      {required this.state,
      this.progressPercent,
      this.remainingSeconds,
      final String? $type})
      : $type = $type ?? 'recordingStateChanged';

  factory _$RecordingStateChangedEventImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RecordingStateChangedEventImplFromJson(json);

  @override
  final RecordingState state;
  @override
  final int? progressPercent;
  @override
  final int? remainingSeconds;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.recordingStateChanged(state: $state, progressPercent: $progressPercent, remainingSeconds: $remainingSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingStateChangedEventImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, state, progressPercent, remainingSeconds);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingStateChangedEventImplCopyWith<_$RecordingStateChangedEventImpl>
      get copyWith => __$$RecordingStateChangedEventImplCopyWithImpl<
          _$RecordingStateChangedEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return recordingStateChanged(state, progressPercent, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return recordingStateChanged?.call(
        state, progressPercent, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (recordingStateChanged != null) {
      return recordingStateChanged(state, progressPercent, remainingSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return recordingStateChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return recordingStateChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (recordingStateChanged != null) {
      return recordingStateChanged(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordingStateChangedEventImplToJson(
      this,
    );
  }
}

abstract class RecordingStateChangedEvent implements BleEvent {
  const factory RecordingStateChangedEvent(
      {required final RecordingState state,
      final int? progressPercent,
      final int? remainingSeconds}) = _$RecordingStateChangedEventImpl;

  factory RecordingStateChangedEvent.fromJson(Map<String, dynamic> json) =
      _$RecordingStateChangedEventImpl.fromJson;

  RecordingState get state;
  int? get progressPercent;
  int? get remainingSeconds;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingStateChangedEventImplCopyWith<_$RecordingStateChangedEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RssiUpdatedEventImplCopyWith<$Res> {
  factory _$$RssiUpdatedEventImplCopyWith(_$RssiUpdatedEventImpl value,
          $Res Function(_$RssiUpdatedEventImpl) then) =
      __$$RssiUpdatedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int rssi});
}

/// @nodoc
class __$$RssiUpdatedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$RssiUpdatedEventImpl>
    implements _$$RssiUpdatedEventImplCopyWith<$Res> {
  __$$RssiUpdatedEventImplCopyWithImpl(_$RssiUpdatedEventImpl _value,
      $Res Function(_$RssiUpdatedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rssi = null,
  }) {
    return _then(_$RssiUpdatedEventImpl(
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RssiUpdatedEventImpl implements RssiUpdatedEvent {
  const _$RssiUpdatedEventImpl({required this.rssi, final String? $type})
      : $type = $type ?? 'rssiUpdated';

  factory _$RssiUpdatedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$RssiUpdatedEventImplFromJson(json);

  @override
  final int rssi;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.rssiUpdated(rssi: $rssi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RssiUpdatedEventImpl &&
            (identical(other.rssi, rssi) || other.rssi == rssi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rssi);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RssiUpdatedEventImplCopyWith<_$RssiUpdatedEventImpl> get copyWith =>
      __$$RssiUpdatedEventImplCopyWithImpl<_$RssiUpdatedEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return rssiUpdated(rssi);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return rssiUpdated?.call(rssi);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (rssiUpdated != null) {
      return rssiUpdated(rssi);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return rssiUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return rssiUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (rssiUpdated != null) {
      return rssiUpdated(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RssiUpdatedEventImplToJson(
      this,
    );
  }
}

abstract class RssiUpdatedEvent implements BleEvent {
  const factory RssiUpdatedEvent({required final int rssi}) =
      _$RssiUpdatedEventImpl;

  factory RssiUpdatedEvent.fromJson(Map<String, dynamic> json) =
      _$RssiUpdatedEventImpl.fromJson;

  int get rssi;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RssiUpdatedEventImplCopyWith<_$RssiUpdatedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BatteryLevelUpdatedEventImplCopyWith<$Res> {
  factory _$$BatteryLevelUpdatedEventImplCopyWith(
          _$BatteryLevelUpdatedEventImpl value,
          $Res Function(_$BatteryLevelUpdatedEventImpl) then) =
      __$$BatteryLevelUpdatedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int level});
}

/// @nodoc
class __$$BatteryLevelUpdatedEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$BatteryLevelUpdatedEventImpl>
    implements _$$BatteryLevelUpdatedEventImplCopyWith<$Res> {
  __$$BatteryLevelUpdatedEventImplCopyWithImpl(
      _$BatteryLevelUpdatedEventImpl _value,
      $Res Function(_$BatteryLevelUpdatedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
  }) {
    return _then(_$BatteryLevelUpdatedEventImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatteryLevelUpdatedEventImpl implements BatteryLevelUpdatedEvent {
  const _$BatteryLevelUpdatedEventImpl(
      {required this.level, final String? $type})
      : $type = $type ?? 'batteryLevelUpdated';

  factory _$BatteryLevelUpdatedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatteryLevelUpdatedEventImplFromJson(json);

  @override
  final int level;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.batteryLevelUpdated(level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatteryLevelUpdatedEventImpl &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, level);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatteryLevelUpdatedEventImplCopyWith<_$BatteryLevelUpdatedEventImpl>
      get copyWith => __$$BatteryLevelUpdatedEventImplCopyWithImpl<
          _$BatteryLevelUpdatedEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return batteryLevelUpdated(level);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return batteryLevelUpdated?.call(level);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (batteryLevelUpdated != null) {
      return batteryLevelUpdated(level);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return batteryLevelUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return batteryLevelUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (batteryLevelUpdated != null) {
      return batteryLevelUpdated(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BatteryLevelUpdatedEventImplToJson(
      this,
    );
  }
}

abstract class BatteryLevelUpdatedEvent implements BleEvent {
  const factory BatteryLevelUpdatedEvent({required final int level}) =
      _$BatteryLevelUpdatedEventImpl;

  factory BatteryLevelUpdatedEvent.fromJson(Map<String, dynamic> json) =
      _$BatteryLevelUpdatedEventImpl.fromJson;

  int get level;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatteryLevelUpdatedEventImplCopyWith<_$BatteryLevelUpdatedEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BleErrorEventImplCopyWith<$Res> {
  factory _$$BleErrorEventImplCopyWith(
          _$BleErrorEventImpl value, $Res Function(_$BleErrorEventImpl) then) =
      __$$BleErrorEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$BleErrorEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$BleErrorEventImpl>
    implements _$$BleErrorEventImplCopyWith<$Res> {
  __$$BleErrorEventImplCopyWithImpl(
      _$BleErrorEventImpl _value, $Res Function(_$BleErrorEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
  }) {
    return _then(_$BleErrorEventImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BleErrorEventImpl implements BleErrorEvent {
  const _$BleErrorEventImpl(
      {required this.message, this.code, final String? $type})
      : $type = $type ?? 'error';

  factory _$BleErrorEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$BleErrorEventImplFromJson(json);

  @override
  final String message;
  @override
  final String? code;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.error(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BleErrorEventImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BleErrorEventImplCopyWith<_$BleErrorEventImpl> get copyWith =>
      __$$BleErrorEventImplCopyWithImpl<_$BleErrorEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String address, int? rssi)
        deviceFound,
    required TResult Function() scanCompleted,
    required TResult Function(
            ConnectionState state, String? deviceName, String? address)
        connectionStateChanged,
    required TResult Function(List<Sample> samples, int timestamp) sampleBatch,
    required TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)
        vitalSignsUpdate,
    required TResult Function(List<RingFile> files) fileListReceived,
    required TResult Function(String fileName, int currentBytes, int totalBytes)
        fileDownloadProgress,
    required TResult Function(String fileName, String localPath)
        fileDownloadCompleted,
    required TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)
        recordingStateChanged,
    required TResult Function(int rssi) rssiUpdated,
    required TResult Function(int level) batteryLevelUpdated,
    required TResult Function(String message, String? code) error,
  }) {
    return error(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String address, int? rssi)? deviceFound,
    TResult? Function()? scanCompleted,
    TResult? Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult? Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult? Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult? Function(List<RingFile> files)? fileListReceived,
    TResult? Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult? Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult? Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult? Function(int rssi)? rssiUpdated,
    TResult? Function(int level)? batteryLevelUpdated,
    TResult? Function(String message, String? code)? error,
  }) {
    return error?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String address, int? rssi)? deviceFound,
    TResult Function()? scanCompleted,
    TResult Function(
            ConnectionState state, String? deviceName, String? address)?
        connectionStateChanged,
    TResult Function(List<Sample> samples, int timestamp)? sampleBatch,
    TResult Function(
            int? heartRate, int? respiratoryRate, SignalQuality quality)?
        vitalSignsUpdate,
    TResult Function(List<RingFile> files)? fileListReceived,
    TResult Function(String fileName, int currentBytes, int totalBytes)?
        fileDownloadProgress,
    TResult Function(String fileName, String localPath)? fileDownloadCompleted,
    TResult Function(
            RecordingState state, int? progressPercent, int? remainingSeconds)?
        recordingStateChanged,
    TResult Function(int rssi)? rssiUpdated,
    TResult Function(int level)? batteryLevelUpdated,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceFoundEvent value) deviceFound,
    required TResult Function(ScanCompletedEvent value) scanCompleted,
    required TResult Function(ConnectionStateChangedEvent value)
        connectionStateChanged,
    required TResult Function(SampleBatchEvent value) sampleBatch,
    required TResult Function(VitalSignsUpdateEvent value) vitalSignsUpdate,
    required TResult Function(FileListReceivedEvent value) fileListReceived,
    required TResult Function(FileDownloadProgressEvent value)
        fileDownloadProgress,
    required TResult Function(FileDownloadCompletedEvent value)
        fileDownloadCompleted,
    required TResult Function(RecordingStateChangedEvent value)
        recordingStateChanged,
    required TResult Function(RssiUpdatedEvent value) rssiUpdated,
    required TResult Function(BatteryLevelUpdatedEvent value)
        batteryLevelUpdated,
    required TResult Function(BleErrorEvent value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceFoundEvent value)? deviceFound,
    TResult? Function(ScanCompletedEvent value)? scanCompleted,
    TResult? Function(ConnectionStateChangedEvent value)?
        connectionStateChanged,
    TResult? Function(SampleBatchEvent value)? sampleBatch,
    TResult? Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult? Function(FileListReceivedEvent value)? fileListReceived,
    TResult? Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult? Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult? Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult? Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult? Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult? Function(BleErrorEvent value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceFoundEvent value)? deviceFound,
    TResult Function(ScanCompletedEvent value)? scanCompleted,
    TResult Function(ConnectionStateChangedEvent value)? connectionStateChanged,
    TResult Function(SampleBatchEvent value)? sampleBatch,
    TResult Function(VitalSignsUpdateEvent value)? vitalSignsUpdate,
    TResult Function(FileListReceivedEvent value)? fileListReceived,
    TResult Function(FileDownloadProgressEvent value)? fileDownloadProgress,
    TResult Function(FileDownloadCompletedEvent value)? fileDownloadCompleted,
    TResult Function(RecordingStateChangedEvent value)? recordingStateChanged,
    TResult Function(RssiUpdatedEvent value)? rssiUpdated,
    TResult Function(BatteryLevelUpdatedEvent value)? batteryLevelUpdated,
    TResult Function(BleErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BleErrorEventImplToJson(
      this,
    );
  }
}

abstract class BleErrorEvent implements BleEvent {
  const factory BleErrorEvent(
      {required final String message,
      final String? code}) = _$BleErrorEventImpl;

  factory BleErrorEvent.fromJson(Map<String, dynamic> json) =
      _$BleErrorEventImpl.fromJson;

  String get message;
  String? get code;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BleErrorEventImplCopyWith<_$BleErrorEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RingFile _$RingFileFromJson(Map<String, dynamic> json) {
  return _RingFile.fromJson(json);
}

/// @nodoc
mixin _$RingFile {
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get localPath => throw _privateConstructorUsedError;
  bool? get isDownloaded => throw _privateConstructorUsedError;

  /// Serializes this RingFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RingFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RingFileCopyWith<RingFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RingFileCopyWith<$Res> {
  factory $RingFileCopyWith(RingFile value, $Res Function(RingFile) then) =
      _$RingFileCopyWithImpl<$Res, RingFile>;
  @useResult
  $Res call(
      {String fileName,
      int fileSize,
      DateTime timestamp,
      String? localPath,
      bool? isDownloaded});
}

/// @nodoc
class _$RingFileCopyWithImpl<$Res, $Val extends RingFile>
    implements $RingFileCopyWith<$Res> {
  _$RingFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RingFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileSize = null,
    Object? timestamp = null,
    Object? localPath = freezed,
    Object? isDownloaded = freezed,
  }) {
    return _then(_value.copyWith(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isDownloaded: freezed == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RingFileImplCopyWith<$Res>
    implements $RingFileCopyWith<$Res> {
  factory _$$RingFileImplCopyWith(
          _$RingFileImpl value, $Res Function(_$RingFileImpl) then) =
      __$$RingFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fileName,
      int fileSize,
      DateTime timestamp,
      String? localPath,
      bool? isDownloaded});
}

/// @nodoc
class __$$RingFileImplCopyWithImpl<$Res>
    extends _$RingFileCopyWithImpl<$Res, _$RingFileImpl>
    implements _$$RingFileImplCopyWith<$Res> {
  __$$RingFileImplCopyWithImpl(
      _$RingFileImpl _value, $Res Function(_$RingFileImpl) _then)
      : super(_value, _then);

  /// Create a copy of RingFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileSize = null,
    Object? timestamp = null,
    Object? localPath = freezed,
    Object? isDownloaded = freezed,
  }) {
    return _then(_$RingFileImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isDownloaded: freezed == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RingFileImpl implements _RingFile {
  const _$RingFileImpl(
      {required this.fileName,
      required this.fileSize,
      required this.timestamp,
      this.localPath,
      this.isDownloaded});

  factory _$RingFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$RingFileImplFromJson(json);

  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final DateTime timestamp;
  @override
  final String? localPath;
  @override
  final bool? isDownloaded;

  @override
  String toString() {
    return 'RingFile(fileName: $fileName, fileSize: $fileSize, timestamp: $timestamp, localPath: $localPath, isDownloaded: $isDownloaded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RingFileImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, fileName, fileSize, timestamp, localPath, isDownloaded);

  /// Create a copy of RingFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RingFileImplCopyWith<_$RingFileImpl> get copyWith =>
      __$$RingFileImplCopyWithImpl<_$RingFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RingFileImplToJson(
      this,
    );
  }
}

abstract class _RingFile implements RingFile {
  const factory _RingFile(
      {required final String fileName,
      required final int fileSize,
      required final DateTime timestamp,
      final String? localPath,
      final bool? isDownloaded}) = _$RingFileImpl;

  factory _RingFile.fromJson(Map<String, dynamic> json) =
      _$RingFileImpl.fromJson;

  @override
  String get fileName;
  @override
  int get fileSize;
  @override
  DateTime get timestamp;
  @override
  String? get localPath;
  @override
  bool? get isDownloaded;

  /// Create a copy of RingFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RingFileImplCopyWith<_$RingFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
