// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  int? get batteryLevel => throw _privateConstructorUsedError;
  DateTime? get lastSyncTime => throw _privateConstructorUsedError;
  DateTime? get lastConnectedTime => throw _privateConstructorUsedError;
  int? get rssi => throw _privateConstructorUsedError;
  bool? get isConnected => throw _privateConstructorUsedError;

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
          DeviceInfo value, $Res Function(DeviceInfo) then) =
      _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call(
      {String name,
      String address,
      String? version,
      int? batteryLevel,
      DateTime? lastSyncTime,
      DateTime? lastConnectedTime,
      int? rssi,
      bool? isConnected});
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? version = freezed,
    Object? batteryLevel = freezed,
    Object? lastSyncTime = freezed,
    Object? lastConnectedTime = freezed,
    Object? rssi = freezed,
    Object? isConnected = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      lastSyncTime: freezed == lastSyncTime
          ? _value.lastSyncTime
          : lastSyncTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastConnectedTime: freezed == lastConnectedTime
          ? _value.lastConnectedTime
          : lastConnectedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rssi: freezed == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int?,
      isConnected: freezed == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
          _$DeviceInfoImpl value, $Res Function(_$DeviceInfoImpl) then) =
      __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String? version,
      int? batteryLevel,
      DateTime? lastSyncTime,
      DateTime? lastConnectedTime,
      int? rssi,
      bool? isConnected});
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
      _$DeviceInfoImpl _value, $Res Function(_$DeviceInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? version = freezed,
    Object? batteryLevel = freezed,
    Object? lastSyncTime = freezed,
    Object? lastConnectedTime = freezed,
    Object? rssi = freezed,
    Object? isConnected = freezed,
  }) {
    return _then(_$DeviceInfoImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      lastSyncTime: freezed == lastSyncTime
          ? _value.lastSyncTime
          : lastSyncTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastConnectedTime: freezed == lastConnectedTime
          ? _value.lastConnectedTime
          : lastConnectedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rssi: freezed == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int?,
      isConnected: freezed == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl(
      {required this.name,
      required this.address,
      this.version,
      this.batteryLevel,
      this.lastSyncTime,
      this.lastConnectedTime,
      this.rssi,
      this.isConnected});

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final String? version;
  @override
  final int? batteryLevel;
  @override
  final DateTime? lastSyncTime;
  @override
  final DateTime? lastConnectedTime;
  @override
  final int? rssi;
  @override
  final bool? isConnected;

  @override
  String toString() {
    return 'DeviceInfo(name: $name, address: $address, version: $version, batteryLevel: $batteryLevel, lastSyncTime: $lastSyncTime, lastConnectedTime: $lastConnectedTime, rssi: $rssi, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.lastSyncTime, lastSyncTime) ||
                other.lastSyncTime == lastSyncTime) &&
            (identical(other.lastConnectedTime, lastConnectedTime) ||
                other.lastConnectedTime == lastConnectedTime) &&
            (identical(other.rssi, rssi) || other.rssi == rssi) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, address, version,
      batteryLevel, lastSyncTime, lastConnectedTime, rssi, isConnected);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(
      this,
    );
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo(
      {required final String name,
      required final String address,
      final String? version,
      final int? batteryLevel,
      final DateTime? lastSyncTime,
      final DateTime? lastConnectedTime,
      final int? rssi,
      final bool? isConnected}) = _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String? get version;
  @override
  int? get batteryLevel;
  @override
  DateTime? get lastSyncTime;
  @override
  DateTime? get lastConnectedTime;
  @override
  int? get rssi;
  @override
  bool? get isConnected;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceConnectionConfig _$DeviceConnectionConfigFromJson(
    Map<String, dynamic> json) {
  return _DeviceConnectionConfig.fromJson(json);
}

/// @nodoc
mixin _$DeviceConnectionConfig {
  bool get autoReconnect => throw _privateConstructorUsedError;
  int get connectionTimeout => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;

  /// Serializes this DeviceConnectionConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceConnectionConfigCopyWith<DeviceConnectionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceConnectionConfigCopyWith<$Res> {
  factory $DeviceConnectionConfigCopyWith(DeviceConnectionConfig value,
          $Res Function(DeviceConnectionConfig) then) =
      _$DeviceConnectionConfigCopyWithImpl<$Res, DeviceConnectionConfig>;
  @useResult
  $Res call({bool autoReconnect, int connectionTimeout, int maxRetries});
}

/// @nodoc
class _$DeviceConnectionConfigCopyWithImpl<$Res,
        $Val extends DeviceConnectionConfig>
    implements $DeviceConnectionConfigCopyWith<$Res> {
  _$DeviceConnectionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoReconnect = null,
    Object? connectionTimeout = null,
    Object? maxRetries = null,
  }) {
    return _then(_value.copyWith(
      autoReconnect: null == autoReconnect
          ? _value.autoReconnect
          : autoReconnect // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionTimeout: null == connectionTimeout
          ? _value.connectionTimeout
          : connectionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceConnectionConfigImplCopyWith<$Res>
    implements $DeviceConnectionConfigCopyWith<$Res> {
  factory _$$DeviceConnectionConfigImplCopyWith(
          _$DeviceConnectionConfigImpl value,
          $Res Function(_$DeviceConnectionConfigImpl) then) =
      __$$DeviceConnectionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool autoReconnect, int connectionTimeout, int maxRetries});
}

/// @nodoc
class __$$DeviceConnectionConfigImplCopyWithImpl<$Res>
    extends _$DeviceConnectionConfigCopyWithImpl<$Res,
        _$DeviceConnectionConfigImpl>
    implements _$$DeviceConnectionConfigImplCopyWith<$Res> {
  __$$DeviceConnectionConfigImplCopyWithImpl(
      _$DeviceConnectionConfigImpl _value,
      $Res Function(_$DeviceConnectionConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoReconnect = null,
    Object? connectionTimeout = null,
    Object? maxRetries = null,
  }) {
    return _then(_$DeviceConnectionConfigImpl(
      autoReconnect: null == autoReconnect
          ? _value.autoReconnect
          : autoReconnect // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionTimeout: null == connectionTimeout
          ? _value.connectionTimeout
          : connectionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceConnectionConfigImpl implements _DeviceConnectionConfig {
  const _$DeviceConnectionConfigImpl(
      {this.autoReconnect = true,
      this.connectionTimeout = 30,
      this.maxRetries = 3});

  factory _$DeviceConnectionConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceConnectionConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool autoReconnect;
  @override
  @JsonKey()
  final int connectionTimeout;
  @override
  @JsonKey()
  final int maxRetries;

  @override
  String toString() {
    return 'DeviceConnectionConfig(autoReconnect: $autoReconnect, connectionTimeout: $connectionTimeout, maxRetries: $maxRetries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceConnectionConfigImpl &&
            (identical(other.autoReconnect, autoReconnect) ||
                other.autoReconnect == autoReconnect) &&
            (identical(other.connectionTimeout, connectionTimeout) ||
                other.connectionTimeout == connectionTimeout) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, autoReconnect, connectionTimeout, maxRetries);

  /// Create a copy of DeviceConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceConnectionConfigImplCopyWith<_$DeviceConnectionConfigImpl>
      get copyWith => __$$DeviceConnectionConfigImplCopyWithImpl<
          _$DeviceConnectionConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceConnectionConfigImplToJson(
      this,
    );
  }
}

abstract class _DeviceConnectionConfig implements DeviceConnectionConfig {
  const factory _DeviceConnectionConfig(
      {final bool autoReconnect,
      final int connectionTimeout,
      final int maxRetries}) = _$DeviceConnectionConfigImpl;

  factory _DeviceConnectionConfig.fromJson(Map<String, dynamic> json) =
      _$DeviceConnectionConfigImpl.fromJson;

  @override
  bool get autoReconnect;
  @override
  int get connectionTimeout;
  @override
  int get maxRetries;

  /// Create a copy of DeviceConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceConnectionConfigImplCopyWith<_$DeviceConnectionConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}
