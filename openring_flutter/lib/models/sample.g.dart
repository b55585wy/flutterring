// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SampleImpl _$$SampleImplFromJson(Map<String, dynamic> json) => _$SampleImpl(
      timestamp: (json['timestamp'] as num).toInt(),
      green: (json['green'] as num).toInt(),
      red: (json['red'] as num).toInt(),
      ir: (json['ir'] as num).toInt(),
      accX: (json['accX'] as num).toInt(),
      accY: (json['accY'] as num).toInt(),
      accZ: (json['accZ'] as num).toInt(),
      gyroX: (json['gyroX'] as num).toInt(),
      gyroY: (json['gyroY'] as num).toInt(),
      gyroZ: (json['gyroZ'] as num).toInt(),
      temp0: (json['temp0'] as num).toInt(),
      temp1: (json['temp1'] as num).toInt(),
      temp2: (json['temp2'] as num).toInt(),
    );

Map<String, dynamic> _$$SampleImplToJson(_$SampleImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'green': instance.green,
      'red': instance.red,
      'ir': instance.ir,
      'accX': instance.accX,
      'accY': instance.accY,
      'accZ': instance.accZ,
      'gyroX': instance.gyroX,
      'gyroY': instance.gyroY,
      'gyroZ': instance.gyroZ,
      'temp0': instance.temp0,
      'temp1': instance.temp1,
      'temp2': instance.temp2,
    };

_$SampleBatchImpl _$$SampleBatchImplFromJson(Map<String, dynamic> json) =>
    _$SampleBatchImpl(
      samples: (json['samples'] as List<dynamic>)
          .map((e) => Sample.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: (json['timestamp'] as num).toInt(),
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SampleBatchImplToJson(_$SampleBatchImpl instance) =>
    <String, dynamic>{
      'samples': instance.samples,
      'timestamp': instance.timestamp,
      'sequenceNumber': instance.sequenceNumber,
    };

_$VitalSignsImpl _$$VitalSignsImplFromJson(Map<String, dynamic> json) =>
    _$VitalSignsImpl(
      heartRate: (json['heartRate'] as num?)?.toInt(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
      quality: $enumDecode(_$SignalQualityEnumMap, json['quality']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$VitalSignsImplToJson(_$VitalSignsImpl instance) =>
    <String, dynamic>{
      'heartRate': instance.heartRate,
      'respiratoryRate': instance.respiratoryRate,
      'quality': _$SignalQualityEnumMap[instance.quality]!,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$SignalQualityEnumMap = {
  SignalQuality.excellent: 'excellent',
  SignalQuality.good: 'good',
  SignalQuality.fair: 'fair',
  SignalQuality.poor: 'poor',
  SignalQuality.noSignal: 'noSignal',
};
