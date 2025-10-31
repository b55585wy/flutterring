import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample.freezed.dart';
part 'sample.g.dart';

/// 单个传感器样本
@freezed
class Sample with _$Sample {
  const factory Sample({
    required int timestamp,
    // PPG 通道（光电容积脉搏波）
    required int green,
    required int red,
    required int ir,
    // 加速度计通道
    required int accX,
    required int accY,
    required int accZ,
    // 陀螺仪通道
    required int gyroX,
    required int gyroY,
    required int gyroZ,
    // 温度通道
    required int temp0,
    required int temp1,
    required int temp2,
  }) = _Sample;

  factory Sample.fromJson(Map<String, dynamic> json) => _$SampleFromJson(json);
}

/// 样本批次（用于高效传输）
@freezed
class SampleBatch with _$SampleBatch {
  const factory SampleBatch({
    required List<Sample> samples,
    required int timestamp,
    int? sequenceNumber,
  }) = _SampleBatch;

  factory SampleBatch.fromJson(Map<String, dynamic> json) =>
      _$SampleBatchFromJson(json);
}

/// 信号质量枚举
enum SignalQuality {
  excellent,
  good,
  fair,
  poor,
  noSignal,
}

/// 生理指标数据
@freezed
class VitalSigns with _$VitalSigns {
  const factory VitalSigns({
    int? heartRate,
    int? respiratoryRate,
    required SignalQuality quality,
    required DateTime timestamp,
  }) = _VitalSigns;

  factory VitalSigns.fromJson(Map<String, dynamic> json) =>
      _$VitalSignsFromJson(json);
}
