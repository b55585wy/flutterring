import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/domain/models/ble_event.dart' as ble;
import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';

class BleScanController extends StateNotifier<BleScanState> {
  BleScanController({
    Stream<ble.BleEvent>? eventStream,
    Future<void> Function()? scanDevices,
    Future<void> Function()? stopScan,
  })  : _eventStream = eventStream ?? RingPlatform.eventStream,
        _scanDevices = scanDevices ?? RingPlatform.scanDevices,
        _stopScan = stopScan ?? RingPlatform.stopScan,
        super(const BleScanState()) {
    _subscription = _eventStream.listen(_onEvent);
  }

  final Stream<ble.BleEvent> _eventStream;
  final Future<void> Function() _scanDevices;
  final Future<void> Function() _stopScan;
  late final StreamSubscription<ble.BleEvent> _subscription;

  Future<void> startScan() async {
    if (state.isScanning) return;

    state = state.copyWith(
      isScanning: true,
      devices: <BleDiscoveredDevice>[],
      errorMessage: null,
    );

    try {
      await _scanDevices();
    } catch (error) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> stopScan() async {
    if (!state.isScanning) return;

    try {
      await _stopScan();
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isScanning: false);
    }
  }

  void _onEvent(ble.BleEvent event) {
    event.when(
      deviceFound: (name, address, rssi) {
        final now = DateTime.now();
        final updated = List<BleDiscoveredDevice>.from(state.devices);
        final index = updated.indexWhere((device) => device.address == address);
        final device = BleDiscoveredDevice(
          name: name.isNotEmpty ? name : '未知设备',
          address: address,
          rssi: rssi,
          lastSeen: now,
        );

        if (index >= 0) {
          updated[index] = device;
        } else {
          updated.add(device);
        }

        updated.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
        state = state.copyWith(devices: updated);
      },
      scanCompleted: () {
        state = state.copyWith(isScanning: false);
      },
      error: (message, code) {
        state = state.copyWith(
          isScanning: false,
          errorMessage: message,
        );
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
class BleScanState {
  static const Object _noChange = Object();

  const BleScanState({
    this.isScanning = false,
    List<BleDiscoveredDevice> devices = const [],
    this.errorMessage,
  }) : devices = List.unmodifiable(devices);

  final bool isScanning;
  final List<BleDiscoveredDevice> devices;
  final String? errorMessage;

  BleScanState copyWith({
    bool? isScanning,
    List<BleDiscoveredDevice>? devices,
    Object? errorMessage = _noChange,
  }) {
    return BleScanState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices != null ? List.unmodifiable(devices) : this.devices,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

@immutable
class BleDiscoveredDevice {
  const BleDiscoveredDevice({
    required this.name,
    required this.address,
    required this.lastSeen,
    this.rssi,
  });

  final String name;
  final String address;
  final int? rssi;
  final DateTime lastSeen;

  int get signalStrength => rssi ?? -999;

  BleDiscoveredDevice copyWith({
    String? name,
    String? address,
    int? rssi,
    DateTime? lastSeen,
  }) {
    return BleDiscoveredDevice(
      name: name ?? this.name,
      address: address ?? this.address,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

final bleScanControllerProvider =
    StateNotifierProvider<BleScanController, BleScanState>((ref) {
  return BleScanController();
});

