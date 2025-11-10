import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/application/controllers/device_connection_controller.dart';
import 'package:openring_flutter/application/controllers/measurement_controller.dart';
import 'package:openring_flutter/presentation/measurement/measurement_page.dart';

void main() {
  testWidgets('MeasurementPage renders metrics and action button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          measurementControllerProvider.overrideWith((ref) {
            return MeasurementController(
              eventStream: const Stream.empty(),
              startLiveMeasurement: ({required int duration}) async {},
              stopMeasurement: () async {},
            );
          }),
          deviceConnectionControllerProvider.overrideWith((ref) {
            return DeviceConnectionController(
              eventStream: const Stream.empty(),
              connectDevice: (_) async {},
              disconnectDevice: () async {},
              getConnectedDevice: () async => null,
              getDeviceInfo: () async => null,
              getBatteryLevel: () async => null,
            );
          }),
        ],
        child: const MaterialApp(
          home: MeasurementPage(),
        ),
      ),
    );

    expect(find.text('实时测量'), findsOneWidget);
    expect(find.text('开始测量'), findsOneWidget);
    expect(find.text('心率'), findsOneWidget);
  });
}

