import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openring_flutter/application/controllers/ble_scan_controller.dart';
import 'package:openring_flutter/application/controllers/device_connection_controller.dart';
import 'package:openring_flutter/application/utils/app_logger.dart';
import 'package:openring_flutter/domain/models/ble_event.dart' as ble;
import 'package:openring_flutter/infrastructure/platform/ring_platform.dart';
import 'package:openring_flutter/presentation/history/history_page.dart';
import 'package:openring_flutter/presentation/measurement/measurement_page.dart';
import 'package:openring_flutter/presentation/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // ✅ 使用 IndexedStack 保持所有页面的状态
  final List<Widget> _pages = const [
    DashboardPage(),
    MeasurementPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_rounded, '仪表盘', 0),
                _buildNavItem(Icons.favorite_rounded, '测量', 1),
                _buildNavItem(Icons.history_rounded, '历史', 2),
                _buildNavItem(Icons.settings_rounded, '设置', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 仪表盘页面
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const _logTag = 'DashboardPage';
  int? _currentHeartRate;
  int? _currentRespiratoryRate;

  // ✅ 保存 subscription 防止被垃圾回收
  StreamSubscription<ble.BleEvent>? _bleSubscription;

  @override
  void initState() {
    super.initState();
    _listenToBleEvents();
  }

  @override
  void dispose() {
    _bleSubscription?.cancel();
    super.dispose();
  }

  void _listenToBleEvents() {
    AppLogger.info(_logTag, '开始监听 BLE 事件');
    _bleSubscription = RingPlatform.eventStream.listen((event) {
      AppLogger.info(_logTag, '收到事件 ${event.runtimeType}');
      event.maybeWhen(
        vitalSignsUpdate: (hr, rr, quality) {
          setState(() {
            _currentHeartRate = hr;
            _currentRespiratoryRate = rr;
          });
        },
        sampleBatch: (_, __) {},
        fileListReceived: (_) {},
        fileDownloadProgress: (_, __, ___) {},
        fileDownloadCompleted: (_, __) {},
        recordingStateChanged: (_, __, ___) {},
        rssiUpdated: (_) {},
        error: (message, code) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('错误: $message')),
            );
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _startScan() async {
    final connectionState = ref.read(deviceConnectionControllerProvider);
    if (connectionState.isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设备已连接，如需重新扫描请先断开连接')),
        );
      }
      return;
    }

    final bluetoothScanStatus = await Permission.bluetoothScan.request();
    final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (!bluetoothScanStatus.isGranted ||
        !bluetoothConnectStatus.isGranted ||
        !locationStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要蓝牙和位置权限才能扫描设备')),
        );
      }
      return;
    }

    await ref.read(bleScanControllerProvider.notifier).startScan();
  }

  Future<void> _connectDevice(String macAddress) async {
    AppLogger.info(_logTag, '开始连接设备 - $macAddress');

    // 检查是否已有连接
    final connectionState = ref.read(deviceConnectionControllerProvider);
    if (connectionState.isConnected ||
        connectionState.status == ble.ConnectionState.connecting) {
      AppLogger.warning(_logTag, '已有活跃连接，拒绝新的连接请求');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请先断开当前连接'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 如果正在扫描，先停止扫描
    final bleState = ref.read(bleScanControllerProvider);
    if (bleState.isScanning) {
      AppLogger.info(_logTag, '停止扫描以开始连接');
      await ref.read(bleScanControllerProvider.notifier).stopScan();
    }

    await ref
        .read(deviceConnectionControllerProvider.notifier)
        .connect(macAddress);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在连接...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await ref.read(deviceConnectionControllerProvider.notifier).disconnect();
  }

  void _showDeviceList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final bleState = ref.watch(bleScanControllerProvider);
            final connectionState =
                ref.watch(deviceConnectionControllerProvider);
            final devices = bleState.devices;
            final isScanning = bleState.isScanning;
            final isBusy = connectionState.isBusy;
            final currentAddress = connectionState.address;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '可用设备',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isScanning)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: devices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bluetooth_searching,
                                    size: 48,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isScanning ? '正在扫描附近的戒指...' : '未找到设备，请重新扫描',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: devices.length,
                              itemBuilder: (context, index) {
                                final device = devices[index];
                                final address = device.address;
                                final isConnecting =
                                    isBusy && currentAddress == address;
                                final signalStrength = device.signalStrength;
                                final signalIcon = signalStrength >= 0.75
                                    ? Icons.signal_cellular_4_bar
                                    : signalStrength >= 0.5
                                        ? Icons.signal_cellular_alt
                                        : signalStrength >= 0.25
                                            ? Icons.signal_cellular_alt_2_bar
                                            : Icons.signal_cellular_alt_1_bar;
                                final signalColor = signalStrength >= 0.75
                                    ? Colors.green
                                    : signalStrength >= 0.5
                                        ? Colors.orange
                                        : Colors.red;

                                return ListTile(
                                  leading: Icon(
                                    signalIcon,
                                    color: signalColor,
                                  ),
                                  title: Text(device.name),
                                  subtitle: Text(
                                      '${address} • ${device.rssi ?? 0} dBm'),
                                  trailing: isConnecting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.chevron_right),
                                  onTap: () => _connectDevice(address),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleScanControllerProvider);
    final connectionState = ref.watch(deviceConnectionControllerProvider);
    final isConnected = connectionState.isConnected;
    final deviceInfo = connectionState.deviceInfo;
    final deviceName = connectionState.deviceName ?? deviceInfo?.name;
    final batteryLevel = deviceInfo?.batteryLevel;
    final isScanning = bleState.isScanning;

    ref.listen<BleScanState>(bleScanControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        });
      }
    });

    ref.listen<DeviceConnectionState>(deviceConnectionControllerProvider,
        (previous, next) {
      // 处理连接失败
      if (next.status == ble.ConnectionState.error ||
          (next.lastError != null && previous?.lastError != next.lastError)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.lastError ?? '连接失败'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: () {
                  if (next.address != null) {
                    _connectDevice(next.address!);
                  }
                },
              ),
            ),
          );
        });
      }

      // 处理连接成功
      if (previous?.status != ble.ConnectionState.connected &&
          next.status == ble.ConnectionState.connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已连接到 ${next.deviceName ?? '设备'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OpenRing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '早上好！',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '开始今天的健康监测',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildQuickStat(
                        '心率',
                        _currentHeartRate != null ? '$_currentHeartRate' : '--',
                        'BPM',
                        Icons.favorite,
                      ),
                      const SizedBox(width: 20),
                      _buildQuickStat(
                        '呼吸',
                        _currentRespiratoryRate != null
                            ? '$_currentRespiratoryRate'
                            : '--',
                        'RPM',
                        Icons.air,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 快速操作
            const Text(
              '快速操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    '开始测量',
                    Icons.play_circle_filled,
                    const Color(0xFF10B981),
                    () {
                      // Navigate to measurement page
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    '查看历史',
                    Icons.history,
                    const Color(0xFF6366F1),
                    () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    '戒指设置',
                    Icons.settings_bluetooth,
                    const Color(0xFFF59E0B),
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    '数据导出',
                    Icons.file_download,
                    const Color(0xFF8B5CF6),
                    () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 连接状态
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: isConnected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? '戒指已连接' : '戒指未连接',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isConnected
                                ? (deviceInfo != null
                                    ? '${deviceName ?? '研究戒指'} - 电量 ${batteryLevel ?? '--'}%'
                                    : '设备运行正常')
                                : '点击扫描并连接您的设备',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isConnected)
                      TextButton(
                        onPressed: connectionState.isBusy ? null : _disconnect,
                        child: const Text('断开'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          if (!isScanning) {
                            _startScan();
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _showDeviceList();
                            });
                          } else {
                            // 如果正在扫描，直接显示设备列表
                            _showDeviceList();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isScanning)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            if (isScanning) const SizedBox(width: 8),
                            Text(isScanning ? '查看设备' : '扫描'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      String label, String value, String unit, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
