import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/domain/models/ble_event.dart' as ble;
import 'package:openring_flutter/domain/models/sample.dart';
import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';

class MeasurementController extends StateNotifier<MeasurementState> {
  MeasurementController({
    Stream<ble.BleEvent>? eventStream,
    Future<void> Function({int duration})? startLiveMeasurement,
    Future<void> Function()? stopMeasurement,
  })  : _eventStream = eventStream ?? RingPlatform.eventStream,
        _startLiveMeasurement = startLiveMeasurement ??
            (({required int duration}) =>
                RingPlatform.startLiveMeasurement(duration: duration)),
        _stopMeasurement = stopMeasurement ?? RingPlatform.stopMeasurement,
        super(const MeasurementState()) {
    _subscription = _eventStream.listen(_onEvent);
  }

  final Stream<ble.BleEvent> _eventStream;
  final Future<void> Function({required int duration}) _startLiveMeasurement;
  final Future<void> Function() _stopMeasurement;
  late final StreamSubscription<ble.BleEvent> _subscription;

  Future<void> start({int duration = 60}) async {
    if (state.isRecording) return;
    state = state.copyWith(
      isRecording: true,
      remainingSeconds: duration,
      samples: const [],
      lastError: null,
    );

    try {
      await _startLiveMeasurement(duration: duration);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isRecording: false,
        lastError: error.toString(),
      );
    }
  }

  Future<void> stop() async {
    if (!state.isRecording) return;

    try {
      await _stopMeasurement();
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(lastError: error.toString());
    } finally {
      state = state.copyWith(isRecording: false);
    }
  }

  void _onEvent(ble.BleEvent event) {
    event.maybeWhen(
      vitalSignsUpdate: (hr, rr, quality) {
        state = state.copyWith(
          heartRate: hr,
          respiratoryRate: rr,
          signalQuality: quality,
        );
      },
      sampleBatch: (samples, timestamp) {
        final updated = state.samples;
        final buffer = List<MeasurementSample>.from(updated)
          ..addAll(samples.map((sample) => MeasurementSample(
                timestamp: sample.timestamp,
                ppgGreen: sample.green,
                ppgRed: sample.red,
                ppgIr: sample.ir,
                accX: sample.accX,
                accY: sample.accY,
                accZ: sample.accZ,
                gyroX: sample.gyroX,
                gyroY: sample.gyroY,
                gyroZ: sample.gyroZ,
                temp0: sample.temp0,
                temp1: sample.temp1,
                temp2: sample.temp2,
              )));

        final maxSamples = state.maxSamples;
        final clipped = buffer.length > maxSamples
            ? buffer.sublist(buffer.length - maxSamples)
            : buffer;

        state = state.copyWith(samples: clipped);
      },
      recordingStateChanged: (status, progress, remainingSeconds) {
        state = state.copyWith(
          recordingStatus: status,
          progressPercent: progress,
          remainingSeconds: remainingSeconds,
        );
      },
      error: (message, code) {
        state = state.copyWith(lastError: message);
      },
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@immutable
class MeasurementState {
  static const Object _noChange = Object();

  const MeasurementState({
    this.isRecording = false,
    this.samples = const [],
    this.heartRate,
    this.respiratoryRate,
    this.signalQuality,
    this.recordingStatus,
    this.progressPercent,
    this.remainingSeconds,
    this.lastError,
    this.maxSamples = 500,
  });

  final bool isRecording;
  final List<MeasurementSample> samples;
  final int? heartRate;
  final int? respiratoryRate;
  final ble.SignalQuality? signalQuality;
  final ble.RecordingState? recordingStatus;
  final int? progressPercent;
  final int? remainingSeconds;
  final String? lastError;
  final int maxSamples;

  MeasurementState copyWith({
    bool? isRecording,
    List<MeasurementSample>? samples,
    Object? heartRate = _noChange,
    Object? respiratoryRate = _noChange,
    ble.SignalQuality? signalQuality,
    ble.RecordingState? recordingStatus,
    Object? progressPercent = _noChange,
    Object? remainingSeconds = _noChange,
    Object? lastError = _noChange,
    int? maxSamples,
  }) {
    return MeasurementState(
      isRecording: isRecording ?? this.isRecording,
      samples: samples ?? this.samples,
      heartRate:
          heartRate == _noChange ? this.heartRate : heartRate as int?,
      respiratoryRate: respiratoryRate == _noChange
          ? this.respiratoryRate
          : respiratoryRate as int?,
      signalQuality: signalQuality ?? this.signalQuality,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      progressPercent: progressPercent == _noChange
          ? this.progressPercent
          : progressPercent as int?,
      remainingSeconds: remainingSeconds == _noChange
          ? this.remainingSeconds
          : remainingSeconds as int?,
      lastError:
          lastError == _noChange ? this.lastError : lastError as String?,
      maxSamples: maxSamples ?? this.maxSamples,
    );
  }
}

@immutable
class MeasurementSample {
  const MeasurementSample({
    required this.timestamp,
    required this.ppgGreen,
    required this.ppgRed,
    required this.ppgIr,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.temp0,
    required this.temp1,
    required this.temp2,
  });

  final int timestamp;
  final int ppgGreen;
  final int ppgRed;
  final int ppgIr;
  final int accX;
  final int accY;
  final int accZ;
  final int gyroX;
  final int gyroY;
  final int gyroZ;
  final int temp0;
  final int temp1;
  final int temp2;
}

final measurementControllerProvider =
    StateNotifierProvider<MeasurementController, MeasurementState>((ref) {
  return MeasurementController();
});
