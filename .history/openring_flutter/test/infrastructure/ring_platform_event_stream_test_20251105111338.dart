import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'ring/events';
  const codec = StandardMethodCodec();
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

  late bool isListening;

  Future<void> sendEvent(Map<String, dynamic> event) async {
    final ByteData data = codec.encodeSuccessEnvelope(event);
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channelName,
      data,
      (_) {},
    );
  }

  group('RingPlatform.eventStream', () {
    late List<dynamic> listenerAEvents;
    late List<dynamic> listenerBEvents;
    StreamSubscription? subA;
    StreamSubscription? subB;

    setUp(() {
      isListening = false;
      listenerAEvents = [];
      listenerBEvents = [];

      ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
        channelName,
        (ByteData? message) async {
          if (message == null) return null;
          final MethodCall call = codec.decodeMethodCall(message);
          if (call.method == 'listen') {
            isListening = true;
            return codec.encodeSuccessEnvelope(null);
          }
          if (call.method == 'cancel') {
            isListening = false;
            return codec.encodeSuccessEnvelope(null);
          }
          return null;
        },
      );
    });

    tearDown(() async {
      await subA?.cancel();
      await subB?.cancel();
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(channelName, null);
    });

    test('broadcasts deviceFound to multiple listeners', () async {
      subA = RingPlatform.eventStream.listen(listenerAEvents.add);
      subB = RingPlatform.eventStream.listen(listenerBEvents.add);

      expect(isListening, isTrue);

      for (final event in emittedEvents) {
        await sendEvent(event);
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

      expect(isListening, isTrue);

      await sendEvent(emittedEvents.first);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await subA?.cancel();

      await sendEvent(emittedEvents.last);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(listenerAEvents.length, 1);
      expect(listenerBEvents.length, 2);
    });
  });
}

