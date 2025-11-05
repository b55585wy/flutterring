import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:openring_flutter/application/controllers/ble_scan_controller.dart';
import 'package:openring_flutter/domain/models/ble_event.dart';

void main() {
  group('BleScanController', () {
    late StreamController<BleEvent> eventController;
    late BleScanController controller;

    setUp(() {
      eventController = StreamController<BleEvent>.broadcast();
      controller = BleScanController(
        eventStream: eventController.stream,
        scanDevices: () async {},
        stopScan: () async {},
      );
    });

    tearDown(() async {
      await eventController.close();
      controller.dispose();
    });

    test('records discovered devices and updates RSSI', () async {
      eventController.add(
        BleEvent.deviceFound(
          name: 'Test Ring',
          address: 'AA:BB:CC:DD:EE:01',
          rssi: -60,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.state.devices.length, 1);
      expect(controller.state.devices.first.address, 'AA:BB:CC:DD:EE:01');
      expect(controller.state.devices.first.rssi, -60);

      eventController.add(
        BleEvent.deviceFound(
          name: 'Test Ring',
          address: 'AA:BB:CC:DD:EE:01',
          rssi: -40,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.state.devices.length, 1);
      expect(controller.state.devices.first.rssi, -40);
    });

    test('startScan toggles scanning flag and clears devices', () async {
      eventController.add(
        BleEvent.deviceFound(
          name: 'Existing',
          address: 'AA:AA',
          rssi: -70,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(controller.state.devices, isNotEmpty);

      await controller.startScan();

      expect(controller.state.isScanning, isTrue);
      expect(controller.state.devices, isEmpty);

      await controller.stopScan();
      expect(controller.state.isScanning, isFalse);
    });
  });
}
