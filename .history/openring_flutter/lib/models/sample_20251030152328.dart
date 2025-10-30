import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample.freezed.dart';
part 'sample.g.dart';

/// 传感器样本数据
@freezed
class Sample with _$Sample {
  const factory Sample({
    required int timestamp,
    // PPG 通道
    required int green,
    required int red,
    required int ir,
    // 加速度计
    required int accX,
    required int accY,
    required int accZ,
    // 陀螺仪
    required int gyroX,
    required int gyroY,
    required int gyroZ,
    // 温度
    required int temp0,
    required int temp1,
    required int temp2,
  }) = _Sample;

  factory Sample.fromJson(Map<String, dynamic> json) => _$SampleFromJson(json);
}

/// 样本批次（用于批量传输）
@freezed
class SampleBatch with _$SampleBatch {
  const factory SampleBatch({
    required List<Sample> samples,
    required int timestamp,
    @Default({}) Map<String, dynamic> metadata,
  }) = _SampleBatch;

  factory SampleBatch.fromJson(Map<String, dynamic> json) =>
      _$SampleBatchFromJson(json);
}
