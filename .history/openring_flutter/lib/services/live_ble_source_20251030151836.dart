import 'dart:async';
import 'sensor_data_source.dart';
import '../platform/ring_platform_interface.dart';
import '../models/sample.dart';
import '../models/ble_event.dart';

/// 在线 BLE 数据源（实时流）
class LiveBleDataSource implements SensorDataSource {
  final RingPlatformInterface _platform;
  
  final _sampleController = StreamController<List<Sample>>.broadcast();
  final _stateController = StreamController<SourceState>.broadcast();
  
  StreamSubscription<BleEvent>? _eventSubscription;
  
  LiveBleDataSource(this._platform);
  
  @override
  SourceType get type => SourceType.liveBle;
  
  @override
  Stream<List<Sample>> get sampleStream => _sampleController.stream;
  
  @override
  Stream<SourceState> get stateStream => _stateController.stream;
  
  @override
  Future<void> start(SourceConfig config) async {
    _stateController.add(SourceState.preparing);
    
    // 订阅事件流
    _eventSubscription = _platform.eventStream.listen((event) {
      event.when(
        sampleBatch: (samples, timestamp) {
          _sampleController.add(samples);
        },
        connectionStateChanged: (state, deviceName, macAddress) {
          if (state == ConnectionState.connected) {
            _stateController.add(SourceState.streaming);
          } else if (state == ConnectionState.disconnected) {
            _stateController.add(SourceState.stopped);
          }
        },
        error: (message, code) {
          _stateController.add(SourceState.error);
        },
        vitalSignsUpdate: (_, __, ___) {
          // 生理指标由 VitalSignsProcessor 处理
        },
        fileListReceived: (_) {
          // 文件列表事件不在这里处理
        },
        downloadProgress: (_, __) {
          // 下载进度不在这里处理
        },
      );
    });
    
    // 启动在线测量
    try {
      await _platform.startLiveMeasurement(config.duration ?? 60);
    } catch (e) {
      _stateController.add(SourceState.error);
      rethrow;
    }
  }
  
  @override
  Future<void> stop() async {
    try {
      await _platform.stopMeasurement();
      _stateController.add(SourceState.stopped);
    } catch (e) {
      _stateController.add(SourceState.error);
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _sampleController.close();
    await _stateController.close();
  }
}

