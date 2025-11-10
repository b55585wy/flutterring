import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openring_flutter/application/controllers/measurement_controller.dart';
import 'package:openring_flutter/domain/models/ble_event.dart';
import 'package:openring_flutter/domain/models/sample.dart';

void main() {
  late StreamController<BleEvent> eventController;
  late List<int> startDurations;
  late bool stopInvoked;

  MeasurementController createController() {
    return MeasurementController(
      eventStream: eventController.stream,
      startLiveMeasurement: ({int duration = 0}) async {
        startDurations.add(duration);
      },
      stopMeasurement: () async {
        stopInvoked = true;
      },
    );
  }

  setUp(() {
    eventController = StreamController<BleEvent>.broadcast();
    startDurations = [];
    stopInvoked = false;
  });

  tearDown(() async {
    await eventController.close();
  });

  test('start triggers measurement and updates state', () async {
    final controller = createController();
    addTearDown(controller.dispose);

    await controller.start(duration: 120);

    expect(controller.state.isRecording, isTrue);
    expect(controller.state.remainingSeconds, 120);
    expect(startDurations, [120]);
  });

  test('stop ends measurement and invokes platform stop', () async {
    final controller = createController();
    addTearDown(controller.dispose);

    await controller.start(duration: 60);
    await controller.stop();

    expect(controller.state.isRecording, isFalse);
    expect(stopInvoked, isTrue);
  });

  test('handles vital signs and sample batch events', () async {
    final controller = createController();
    addTearDown(controller.dispose);

    eventController.add(const BleEvent.vitalSignsUpdate(
      heartRate: 72,
      respiratoryRate: 16,
      quality: SignalQuality.good,
    ));
    eventController.add(BleEvent.sampleBatch(
      samples: const [
        Sample(
          timestamp: 1,
          green: 10,
          red: 20,
          ir: 30,
          accX: 1,
          accY: 2,
          accZ: 3,
          gyroX: 4,
          gyroY: 5,
          gyroZ: 6,
          temp0: 33,
          temp1: 34,
          temp2: 35,
        ),
      ],
      timestamp: 123,
    ));

    // Allow async listeners to process events.
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.heartRate, 72);
    expect(controller.state.respiratoryRate, 16);
    expect(controller.state.signalQuality, SignalQuality.good);
    expect(controller.state.samples, hasLength(1));
    final sample = controller.state.samples.first;
    expect(sample.ppgGreen, 10);
    expect(sample.ppgRed, 20);
  });
}
