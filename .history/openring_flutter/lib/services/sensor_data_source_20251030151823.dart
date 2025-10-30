import 'dart:async';
import '../models/sample.dart';

/// 数据源类型
enum SourceType {
  liveBle,
  offlineRecording,
  localFile,
}

/// 数据源状态
enum SourceState {
  idle,
  preparing,
  streaming,
  paused,
  stopped,
  error,
}

/// 数据源配置
class SourceConfig {
  final int? duration;
  final int? segmentDuration;
  final String? filePath;
  final String? fileName;
  final bool autoDisconnect;
  final double playbackSpeed;
  
  const SourceConfig({
    this.duration,
    this.segmentDuration,
    this.filePath,
    this.fileName,
    this.autoDisconnect = false,
    this.playbackSpeed = 1.0,
  });
}

/// 传感器数据源统一接口
abstract class SensorDataSource {
  /// 数据源类型
  SourceType get type;
  
  /// 样本数据流
  Stream<List<Sample>> get sampleStream;
  
  /// 状态流
  Stream<SourceState> get stateStream;
  
  /// 启动数据采集
  Future<void> start(SourceConfig config);
  
  /// 停止采集
  Future<void> stop();
  
  /// 暂停（仅部分数据源支持）
  Future<void> pause() async {
    throw UnimplementedError('Pause not supported for $type');
  }
  
  /// 恢复（仅部分数据源支持）
  Future<void> resume() async {
    throw UnimplementedError('Resume not supported for $type');
  }
  
  /// 释放资源
  Future<void> dispose();
}

