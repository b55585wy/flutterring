import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

/// 设备信息
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String name,
    required String address,
    String? version,
    int? batteryLevel,
    DateTime? lastSyncTime,
    DateTime? lastConnectedTime,
    int? rssi,
    bool? isConnected,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

/// 设备连接配置
@freezed
class DeviceConnectionConfig with _$DeviceConnectionConfig {
  const factory DeviceConnectionConfig({
    @Default(true) bool autoReconnect,
    @Default(30) int connectionTimeout,
    @Default(3) int maxRetries,
  }) = _DeviceConnectionConfig;

  factory DeviceConnectionConfig.fromJson(Map<String, dynamic> json) =>
      _$DeviceConnectionConfigFromJson(json);
}
