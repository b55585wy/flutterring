import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/domain/models/ble_event.dart' as ble;
import 'package:openring_flutter/domain/models/device_info.dart';
import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';

class DeviceConnectionController extends StateNotifier<DeviceConnectionState> {
  DeviceConnectionController({
    Stream<ble.BleEvent>? eventStream,
    Future<void> Function(String address)? connectDevice,
    Future<void> Function()? disconnectDevice,
    Future<DeviceInfo?> Function()? getConnectedDevice,
    Future<DeviceInfo?> Function()? getDeviceInfo,
    Future<int?> Function()? getBatteryLevel,
  })  : _eventStream = eventStream ?? RingPlatform.eventStream,
        _connectDevice = connectDevice ?? RingPlatform.connectDevice,
        _disconnectDevice = disconnectDevice ?? RingPlatform.disconnect,
        _getConnectedDevice =
            getConnectedDevice ?? RingPlatform.getConnectedDevice,
        _getDeviceInfo = getDeviceInfo ?? RingPlatform.getDeviceInfo,
        _getBatteryLevel = getBatteryLevel ?? RingPlatform.getBatteryLevel,
        super(const DeviceConnectionState()) {
    _subscription = _eventStream.listen(_onEvent);
    Future.microtask(_hydrateInitialConnection);
  }

  final Stream<ble.BleEvent> _eventStream;
  final Future<void> Function(String address) _connectDevice;
  final Future<void> Function() _disconnectDevice;
  final Future<DeviceInfo?> Function() _getConnectedDevice;
  final Future<DeviceInfo?> Function() _getDeviceInfo;
  final Future<int?> Function() _getBatteryLevel;
  late final StreamSubscription<ble.BleEvent> _subscription;

  Future<void> connect(String address) async {
    state = state.copyWith(
      isBusy: true,
      address: address,
      lastError: null,
      status: ble.ConnectionState.connecting,
    );

    try {
      await _connectDevice(address);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        lastError: error.toString(),
        status: ble.ConnectionState.error,
      );
    }
  }

  Future<void> disconnect() async {
    if (state.isBusy) return;

    state = state.copyWith(
      isBusy: true,
      lastError: null,
      status: ble.ConnectionState.disconnecting,
    );

    try {
      await _disconnectDevice();
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        lastError: error.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _refreshDeviceInfo();
  }

  void _onEvent(ble.BleEvent event) {
    event.maybeWhen(
      connectionStateChanged: (connectionState, deviceName, address) {
        // 处理连接失败状态
        if (connectionState == ble.ConnectionState.failed) {
          state = state.copyWith(
            status: ble.ConnectionState.disconnected,
            deviceName: null,
            address: null,
            isBusy: false,
            lastError: '连接失败，请确保设备在范围内并重试',
          );
          return;
        }
        
        state = state.copyWith(
          status: connectionState,
          deviceName: deviceName,
          address: address,
          isBusy: false,
          lastError: null,
        );

        if (connectionState == ble.ConnectionState.connected) {
          _refreshDeviceInfo();
        }

        if (connectionState == ble.ConnectionState.disconnected) {
          state = state.copyWith(deviceInfo: null);
        }
      },
      batteryLevelUpdated: (level) {
        final info = state.deviceInfo;
        if (info != null) {
          state = state.copyWith(
            deviceInfo: info.copyWith(batteryLevel: level),
          );
        }
      },
      error: (message, code) {
        state = state.copyWith(
          isBusy: false,
          lastError: message,
          status: ble.ConnectionState.error,
        );
      },
      orElse: () {},
    );
  }

  Future<void> _hydrateInitialConnection() async {
    try {
      final device = await _getConnectedDevice();
      if (!mounted || device == null) {
        return;
      }

      state = state.copyWith(
        status: ble.ConnectionState.connected,
        deviceName: device.name,
        address: device.address,
        deviceInfo: device,
        lastError: null,
      );
      await _refreshDeviceInfo();
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(lastError: error.toString());
    }
  }

  Future<void> _refreshDeviceInfo() async {
    try {
      final info = await _getDeviceInfo();
      final battery = await _getBatteryLevel();
      if (!mounted) return;

      if (info != null) {
        final enriched =
            battery != null ? info.copyWith(batteryLevel: battery) : info;
        state = state.copyWith(
          deviceInfo: enriched,
          deviceName: enriched.name,
          address: enriched.address,
        );
      } else if (battery != null && state.deviceInfo != null) {
        state = state.copyWith(
          deviceInfo: state.deviceInfo!.copyWith(batteryLevel: battery),
        );
      }
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(lastError: error.toString());
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@immutable
class DeviceConnectionState {
  static const Object _noChange = Object();

  const DeviceConnectionState({
    this.status = ble.ConnectionState.disconnected,
    this.deviceName,
    this.address,
    this.deviceInfo,
    this.isBusy = false,
    this.lastError,
  });

  final ble.ConnectionState status;
  final String? deviceName;
  final String? address;
  final DeviceInfo? deviceInfo;
  final bool isBusy;
  final String? lastError;

  bool get isConnected => status == ble.ConnectionState.connected;

  DeviceConnectionState copyWith({
    ble.ConnectionState? status,
    Object? deviceName = _noChange,
    Object? address = _noChange,
    Object? deviceInfo = _noChange,
    bool? isBusy,
    Object? lastError = _noChange,
  }) {
    return DeviceConnectionState(
      status: status ?? this.status,
      deviceName:
          deviceName == _noChange ? this.deviceName : deviceName as String?,
      address: address == _noChange ? this.address : address as String?,
      deviceInfo:
          deviceInfo == _noChange ? this.deviceInfo : deviceInfo as DeviceInfo?,
      isBusy: isBusy ?? this.isBusy,
      lastError: lastError == _noChange ? this.lastError : lastError as String?,
    );
  }
}

final deviceConnectionControllerProvider =
    StateNotifierProvider<DeviceConnectionController, DeviceConnectionState>(
        (ref) {
  return DeviceConnectionController();
});
