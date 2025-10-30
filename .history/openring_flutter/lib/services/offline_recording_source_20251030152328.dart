import 'dart:async';
import 'sensor_data_source.dart';
import '../platform/ring_platform_interface.dart';
import '../models/sample.dart';

/// 离线录制阶段
enum RecordingPhase {
  idle,
  scheduling,
  recording,
  waitingDownload,
  downloading,
  readyForPlayback,
  playingBack,
}

/// 离线录制数据源（支持断连）
class OfflineRecordingDataSource implements SensorDataSource {
  final RingPlatformInterface _platform;

  RecordingPhase _phase = RecordingPhase.idle;
  DateTime? _estimatedEndTime;
  Timer? _autoDownloadTimer;
  String? _downloadedFilePath;

  final _sampleController = StreamController<List<Sample>>.broadcast();
  final _stateController = StreamController<SourceState>.broadcast();
  final _phaseController = StreamController<RecordingPhase>.broadcast();

  /// 录制阶段流（供 UI 监听）
  Stream<RecordingPhase> get phaseStream => _phaseController.stream;

  /// 当前阶段
  RecordingPhase get currentPhase => _phase;

  /// 预计完成时间
  DateTime? get estimatedEndTime => _estimatedEndTime;

  OfflineRecordingDataSource(this._platform);

  @override
  SourceType get type => SourceType.offlineRecording;

  @override
  Stream<List<Sample>> get sampleStream => _sampleController.stream;

  @override
  Stream<SourceState> get stateStream => _stateController.stream;

  @override
  Future<void> start(SourceConfig config) async {
    _phase = RecordingPhase.scheduling;
    _phaseController.add(_phase);
    _stateController.add(SourceState.preparing);

    // 1. 发送离线录制命令到戒指
    try {
      await _platform.startOfflineRecording(
        totalDuration: config.duration ?? 300,
        segmentDuration: config.segmentDuration ?? 60,
      );
    } catch (e) {
      _phase = RecordingPhase.idle;
      _phaseController.add(_phase);
      _stateController.add(SourceState.error);
      rethrow;
    }

    // 2. 戒指确认后，进入 RECORDING 状态
    _phase = RecordingPhase.recording;
    _phaseController.add(_phase);
    _stateController.add(SourceState.streaming);

    // 3. 记录预计完成时间
    _estimatedEndTime = DateTime.now().add(
      Duration(seconds: config.duration ?? 300),
    );

    // 4. 可选：自动断连以省电
    if (config.autoDisconnect) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        await _platform.disconnect();
      } catch (e) {
        // 断连失败不影响录制
      }
    }

    // 5. 设置自动下载定时器
    _scheduleAutoDownload(config.duration ?? 300);
  }

  void _scheduleAutoDownload(int duration) {
    _autoDownloadTimer?.cancel();
    _autoDownloadTimer = Timer(
      Duration(seconds: duration + 10), // 加 10 秒缓冲
      () async {
        _phase = RecordingPhase.waitingDownload;
        _phaseController.add(_phase);

        // TODO: 显示通知：采集完成，可下载
        // await _showDownloadNotification();

        // 尝试自动下载
        await attemptAutoDownload();
      },
    );
  }

  /// 尝试自动下载（可被 UI 手动触发）
  Future<void> attemptAutoDownload() async {
    _phase = RecordingPhase.downloading;
    _phaseController.add(_phase);

    try {
      // 1. 重连戒指（如果已断连）
      // await _platform.connectDevice(/* 保存的 MAC 地址 */);

      // 2. 获取文件列表
      final files = await _platform.getFileList();

      // 3. 找到最新文件（根据时间戳最接近预期完成时间）
      final latestFile = _findLatestFile(files);

      if (latestFile == null) {
        throw Exception('No matching file found');
      }

      // 4. 下载文件
      _downloadedFilePath = await _platform.downloadFile(latestFile.fileName);

      _phase = RecordingPhase.readyForPlayback;
      _phaseController.add(_phase);

      // 5. 自动开始回放
      await _startPlayback();
    } catch (e) {
      _phase = RecordingPhase.waitingDownload;
      _phaseController.add(_phase);
      _stateController.add(SourceState.error);
      rethrow;
    }
  }

  Future<void> _startPlayback() async {
    if (_downloadedFilePath == null) {
      throw Exception('No file to playback');
    }

    _phase = RecordingPhase.playingBack;
    _phaseController.add(_phase);

    try {
      // 解析文件并按时间戳回放
      final samples = await _parseFile(_downloadedFilePath!);

      // 模拟实时流（批量发送）
      const batchSize = 25; // 25Hz
      for (var i = 0; i < samples.length; i += batchSize) {
        final batch = samples.sublist(
          i,
          (i + batchSize).clamp(0, samples.length),
        );
        _sampleController.add(batch);

        // 按采样率延迟
        await Future.delayed(const Duration(milliseconds: 40)); // 1000ms / 25Hz
      }

      // 回放完成
      _phase = RecordingPhase.idle;
      _phaseController.add(_phase);
      _stateController.add(SourceState.stopped);
    } catch (e) {
      _stateController.add(SourceState.error);
      rethrow;
    }
  }

  /// 查找最新文件（根据时间戳）
  dynamic _findLatestFile(List<dynamic> files) {
    if (files.isEmpty) return null;

    // TODO: 实现更精确的文件匹配逻辑
    // 根据文件名中的时间戳与 estimatedEndTime 比较
    return files.first;
  }

  /// 解析戒指文件格式
  Future<List<Sample>> _parseFile(String filePath) async {
    // TODO: 实现文件解析逻辑
    // 需要根据实际戒指文件格式进行解析

    // 示例：返回空列表（实际应解析二进制文件）
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<void> stop() async {
    _autoDownloadTimer?.cancel();

    if (_phase == RecordingPhase.recording) {
      try {
        await _platform.stopMeasurement();
      } catch (e) {
        // 停止失败不影响状态重置
      }
    }

    _phase = RecordingPhase.idle;
    _phaseController.add(_phase);
    _stateController.add(SourceState.stopped);
  }

  @override
  Future<void> dispose() async {
    await _sampleController.close();
    await _stateController.close();
    await _phaseController.close();
    _autoDownloadTimer?.cancel();
  }

  /// 手动触发下载（供 UI 调用）
  Future<void> downloadNow() async {
    if (_phase == RecordingPhase.waitingDownload) {
      await attemptAutoDownload();
    }
  }

  /// 断开连接（供 UI 调用）
  Future<void> disconnect() async {
    if (_phase == RecordingPhase.recording) {
      try {
        await _platform.disconnect();
      } catch (e) {
        // 断连失败不影响录制
      }
    }
  }
}
