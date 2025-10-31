// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      version: json['version'] as String?,
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      lastSyncTime: json['lastSyncTime'] == null
          ? null
          : DateTime.parse(json['lastSyncTime'] as String),
      lastConnectedTime: json['lastConnectedTime'] == null
          ? null
          : DateTime.parse(json['lastConnectedTime'] as String),
      rssi: (json['rssi'] as num?)?.toInt(),
      isConnected: json['isConnected'] as bool?,
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'version': instance.version,
      'batteryLevel': instance.batteryLevel,
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'lastConnectedTime': instance.lastConnectedTime?.toIso8601String(),
      'rssi': instance.rssi,
      'isConnected': instance.isConnected,
    };

_$DeviceConnectionConfigImpl _$$DeviceConnectionConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$DeviceConnectionConfigImpl(
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$$DeviceConnectionConfigImplToJson(
        _$DeviceConnectionConfigImpl instance) =>
    <String, dynamic>{
      'autoReconnect': instance.autoReconnect,
      'connectionTimeout': instance.connectionTimeout,
      'maxRetries': instance.maxRetries,
    };
