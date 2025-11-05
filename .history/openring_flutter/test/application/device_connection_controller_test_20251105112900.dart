import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:openring_flutter/application/controllers/device_connection_controller.dart';
import 'package:openring_flutter/domain/models/ble_event.dart' as ble;
import 'package:openring_flutter/domain/models/device_info.dart';

void main() {
  group('DeviceConnectionController', () {
    late StreamController<ble.BleEvent> eventController;
    late DeviceConnectionController controller;

    setUp(() {
      eventController = StreamController<ble.BleEvent>.broadcast();
      controller = DeviceConnectionController(
        eventStream: eventController.stream,
        connectDevice: (_) async {},
        disconnectDevice: () async {},
        getConnectedDevice: () async => null,
        getDeviceInfo: () async => const DeviceInfo(
          name: 'TestRing',
          address: 'AA:BB:CC:DD:EE:01',
          batteryLevel: 70,
        ),
        getBatteryLevel: () async => 85,
      );
    });

    tearDown(() async {
      await eventController.close();
      controller.dispose();
    });

    test('updates state when connection events arrive', () async {
      eventController.add(
        ble.BleEvent.connectionStateChanged(
          state: ble.ConnectionState.connected,
          deviceName: 'TestRing',
          address: 'AA:BB:CC:DD:EE:01',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.state.isConnected, isTrue);
      expect(controller.state.deviceInfo?.batteryLevel, 85);
      expect(controller.state.deviceName, 'TestRing');

      eventController.add(
        ble.BleEvent.connectionStateChanged(
          state: ble.ConnectionState.disconnected,
          deviceName: 'TestRing',
          address: 'AA:BB:CC:DD:EE:01',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.state.isConnected, isFalse);
      expect(controller.state.deviceInfo, isNull);
    });
  });
}
