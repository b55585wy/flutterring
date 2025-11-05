# Application Layer

This directory will host state management and use-case logic that bridges UI and
infrastructure. Planned controllers/services:

- `ble_scan_controller.dart`
- `device_connection_controller.dart`
- `measurement_controller.dart`
- `settings_controller.dart`

Completed:
- `ble_scan_controller.dart`
- `device_connection_controller.dart`

Planned next:
- `measurement_controller.dart`
- `settings_controller.dart`

Each controller should expose Riverpod providers for the widgets in
`lib/presentation`. Keep implementation modular so that they can be easily
tested.

