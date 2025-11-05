import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const eventChannel = EventChannel('ring/events');
  final emittedEvents = <Map<String, dynamic>>[
    {
      'type': 'deviceFound',
      'device': {
        'name': 'TestRingA',
        'address': 'AA:BB:CC:DD:EE:01',
        'rssi': -50,
      },
    },
    {
      'type': 'deviceFound',
      'device': {
        'name': 'TestRingB',
        'address': 'AA:BB:CC:DD:EE:02',
        'rssi': -55,
      },
    },
  ];

  group('RingPlatform.eventStream', () {
    late StreamController<dynamic> controller;
    late List<dynamic> listenerAEvents;
    late List<dynamic> listenerBEvents;
    StreamSubscription? subA;
    StreamSubscription? subB;

    setUp(() {
      controller = StreamController<dynamic>.broadcast();
      listenerAEvents = [];
      listenerBEvents = [];

      ServicesBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, MockStreamHandler(controller.stream));
    });

    tearDown(() async {
      await subA?.cancel();
      await subB?.cancel();
      await controller.close();
      ServicesBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, null);
    });

    test('broadcasts deviceFound to multiple listeners', () async {
      subA = RingPlatform.eventStream.listen(listenerAEvents.add);
      subB = RingPlatform.eventStream.listen(listenerBEvents.add);

      for (final event in emittedEvents) {
        controller.add(event);
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(listenerAEvents.length, emittedEvents.length);
      expect(listenerBEvents.length, emittedEvents.length);

      for (var i = 0; i < emittedEvents.length; i++) {
        final expected = emittedEvents[i]['device'] as Map<String, dynamic>;

        final actualA = listenerAEvents[i];
        final actualB = listenerBEvents[i];

        actualA.when(
          deviceFound: (name, address, rssi) {
            expect(name, expected['name']);
            expect(address, expected['address']);
            expect(rssi, expected['rssi']);
          },
          orElse: () => fail('Listener A received unexpected event type'),
        );

        actualB.when(
          deviceFound: (name, address, rssi) {
            expect(name, expected['name']);
            expect(address, expected['address']);
            expect(rssi, expected['rssi']);
          },
          orElse: () => fail('Listener B received unexpected event type'),
        );
      }
    });

    test('cancelling subscription stops receiving events', () async {
      subA = RingPlatform.eventStream.listen(listenerAEvents.add);
      subB = RingPlatform.eventStream.listen(listenerBEvents.add);

      controller.add(emittedEvents.first);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await subA?.cancel();

      controller.add(emittedEvents.last);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(listenerAEvents.length, 1);
      expect(listenerBEvents.length, 2);
    });
  });
}

class MockStreamHandler extends StreamHandler<dynamic> {
  MockStreamHandler(this._stream);

  final Stream<dynamic> _stream;

  @override
  Future<dynamic> onCancel(Object? arguments) => Future.value();

  @override
  Stream<dynamic> onListen(Object? arguments) => _stream;
}

