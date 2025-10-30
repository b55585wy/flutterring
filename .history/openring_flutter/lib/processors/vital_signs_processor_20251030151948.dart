import 'dart:async';
import 'dart:math';
import '../models/sample.dart';
import '../models/ble_event.dart';

/// 生理信号处理器（Dart 版本，从 Java 迁移）
class VitalSignsProcessor {
  static const int _sampleRate = 25; // Hz
  static const int _hrWindowSize = _sampleRate * 8; // 8 秒
  static const int _rrWindowSize = _sampleRate * 30; // 30 秒
  static const int _minPeaksForHR = 3;
  static const int _minPeaksForRR = 2;
  
  // 心率范围约束 (BPM)
  static const int _minHRBpm = 40;
  static const int _maxHRBpm = 200;
  
  // 呼吸率范围约束 (RPM)
  static const int _minRRRpm = 8;
  static const int _maxRRRpm = 40;
  
  // 数据缓冲区
  final _ppgGreenBuffer = <int>[];
  final _ppgIrBuffer = <int>[];
  final _accXBuffer = <int>[];
  final _accYBuffer = <int>[];
  final _accZBuffer = <int>[];
  final _timestampBuffer = <int>[];
  
  // 当前生理指标
  int? _currentHeartRate;
  int? _currentRespiratoryRate;
  SignalQuality _currentSignalQuality = SignalQuality.noSignal;
  DateTime? _lastUpdateTime;
  
  // 流控制器
  final _hrController = StreamController<int>.broadcast();
  final _rrController = StreamController<int>.broadcast();
  final _qualityController = StreamController<SignalQuality>.broadcast();
  
  /// 心率流
  Stream<int> get heartRateStream => _hrController.stream;
  
  /// 呼吸率流
  Stream<int> get respiratoryRateStream => _rrController.stream;
  
  /// 信号质量流
  Stream<SignalQuality> get signalQualityStream => _qualityController.stream;
  
  /// 当前心率
  int? get currentHeartRate => _currentHeartRate;
  
  /// 当前呼吸率
  int? get currentRespiratoryRate => _currentRespiratoryRate;
  
  /// 当前信号质量
  SignalQuality get currentSignalQuality => _currentSignalQuality;
  
  /// 添加样本批次进行处理
  void processBatch(List<Sample> samples) {
    for (var sample in samples) {
      _addSample(sample);
    }
    
    // 处理心率（如果有足够数据）
    if (_ppgGreenBuffer.length >= _hrWindowSize) {
      _processHeartRate();
    }
    
    // 处理呼吸率（如果有足够数据）
    if (_accXBuffer.length >= _rrWindowSize) {
      _processRespiratoryRate();
    }
    
    // 更新信号质量
    _updateSignalQuality();
    
    _lastUpdateTime = DateTime.now();
  }
  
  void _addSample(Sample sample) {
    // 添加到缓冲区
    _ppgGreenBuffer.add(sample.green);
    _ppgIrBuffer.add(sample.ir);
    _accXBuffer.add(sample.accX);
    _accYBuffer.add(sample.accY);
    _accZBuffer.add(sample.accZ);
    _timestampBuffer.add(sample.timestamp);
    
    // 保持 HR 窗口大小
    if (_ppgGreenBuffer.length > _hrWindowSize) {
      _ppgGreenBuffer.removeAt(0);
      _ppgIrBuffer.removeAt(0);
      _timestampBuffer.removeAt(0);
    }
    
    // 保持 RR 窗口大小
    if (_accXBuffer.length > _rrWindowSize) {
      _accXBuffer.removeAt(0);
      _accYBuffer.removeAt(0);
      _accZBuffer.removeAt(0);
    }
  }
  
  /// 处理心率
  void _processHeartRate() {
    try {
      // 使用 PPG Green 通道（通常最佳信号）
      final ppgData = List<int>.from(_ppgGreenBuffer);
      
      // 应用带通滤波 (0.5-4Hz)
      final filtered = _applyBandpassFilter(ppgData, 0.5, 4.0);
      
      // 峰值检测
      final peaks = _detectPeaks(filtered, 0.6);
      
      if (peaks.length >= _minPeaksForHR) {
        // 计算峰间距
        final intervals = <double>[];
        for (var i = 1; i < peaks.length; i++) {
          final interval = (peaks[i] - peaks[i - 1]) / _sampleRate;
          intervals.add(interval);
        }
        
        // 计算中位数（更robust）
        intervals.sort();
        final medianInterval = intervals[intervals.length ~/ 2];
        
        // 转换为 BPM
        final heartRate = (60.0 / medianInterval).round();
        
        // 验证合理范围
        if (heartRate >= _minHRBpm && heartRate <= _maxHRBpm) {
          if (_currentHeartRate != heartRate) {
            _currentHeartRate = heartRate;
            _hrController.add(heartRate);
          }
        }
      }
    } catch (e) {
      // 处理错误但不中断
    }
  }
  
  /// 处理呼吸率
  void _processRespiratoryRate() {
    try {
      // 计算加速度幅值
      final accMagnitude = <double>[];
      for (var i = 0; i < _accXBuffer.length; i++) {
        final x = _accXBuffer[i].toDouble();
        final y = _accYBuffer[i].toDouble();
        final z = _accZBuffer[i].toDouble();
        final magnitude = sqrt(x * x + y * y + z * z);
        accMagnitude.add(magnitude);
      }
      
      // 应用低通滤波 (0.1-0.7Hz)
      final filtered = _applyBandpassFilter(
        accMagnitude.map((e) => e.toInt()).toList(),
        0.1,
        0.7,
      );
      
      // 峰值检测
      final peaks = _detectPeaks(filtered, 0.4);
      
      if (peaks.length >= _minPeaksForRR) {
        // 计算呼吸率
        final totalTime = _rrWindowSize / _sampleRate;
        final respiratoryRate = ((peaks.length - 1) * 60.0 / totalTime).round();
        
        // 验证合理范围
        if (respiratoryRate >= _minRRRpm && respiratoryRate <= _maxRRRpm) {
          if (_currentRespiratoryRate != respiratoryRate) {
            _currentRespiratoryRate = respiratoryRate;
            _rrController.add(respiratoryRate);
          }
        }
      }
    } catch (e) {
      // 处理错误但不中断
    }
  }
  
  /// 应用带通滤波（简化版移动平均）
  List<double> _applyBandpassFilter(
    List<int> data,
    double lowFreq,
    double highFreq,
  ) {
    final windowSize = max(1, _sampleRate ~/ 5);
    final filtered = <double>[];
    
    for (var i = 0; i < data.length; i++) {
      var sum = 0.0;
      var count = 0;
      
      final start = max(0, i - windowSize ~/ 2);
      final end = min(data.length, i + windowSize ~/ 2 + 1);
      
      for (var j = start; j < end; j++) {
        sum += data[j];
        count++;
      }
      
      filtered.add(sum / count);
    }
    
    return filtered;
  }
  
  /// 峰值检测
  List<int> _detectPeaks(List<double> data, double threshold) {
    final peaks = <int>[];
    
    if (data.length < 3) return peaks;
    
    // 计算动态阈值
    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final dynamicThreshold = minVal + (maxVal - minVal) * threshold;
    
    // 查找峰值
    for (var i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i - 1] &&
          data[i] > data[i + 1] &&
          data[i] > dynamicThreshold) {
        // 避免峰值过密
        if (peaks.isEmpty || i - peaks.last > _sampleRate ~/ 4) {
          peaks.add(i);
        }
      }
    }
    
    return peaks;
  }
  
  /// 更新信号质量
  void _updateSignalQuality() {
    if (_ppgGreenBuffer.isEmpty) {
      _updateQuality(SignalQuality.noSignal);
      return;
    }
    
    final minVal = _ppgGreenBuffer.reduce(min);
    final maxVal = _ppgGreenBuffer.reduce(max);
    final range = maxVal - minVal;
    final mean = _ppgGreenBuffer.reduce((a, b) => a + b) / _ppgGreenBuffer.length;
    
    SignalQuality quality;
    if (mean > 1000 && range > 2000) {
      quality = SignalQuality.excellent;
    } else if (mean > 1000 && range > 1500) {
      quality = SignalQuality.good;
    } else if (mean > 1000 && range > 1000) {
      quality = SignalQuality.fair;
    } else if (mean > 1000) {
      quality = SignalQuality.poor;
    } else {
      quality = SignalQuality.noSignal;
    }
    
    _updateQuality(quality);
  }
  
  void _updateQuality(SignalQuality quality) {
    if (_currentSignalQuality != quality) {
      _currentSignalQuality = quality;
      _qualityController.add(quality);
    }
  }
  
  /// 重置处理器
  void reset() {
    _ppgGreenBuffer.clear();
    _ppgIrBuffer.clear();
    _accXBuffer.clear();
    _accYBuffer.clear();
    _accZBuffer.clear();
    _timestampBuffer.clear();
    
    _currentHeartRate = null;
    _currentRespiratoryRate = null;
    _currentSignalQuality = SignalQuality.noSignal;
    _lastUpdateTime = null;
  }
  
  /// 释放资源
  void dispose() {
    _hrController.close();
    _rrController.close();
    _qualityController.close();
  }
  
  /// 获取缓冲区状态（调试用）
  String getBufferStatus() {
    return 'PPG: ${_ppgGreenBuffer.length}/$_hrWindowSize, '
        'ACC: ${_accXBuffer.length}/$_rrWindowSize';
  }
}

