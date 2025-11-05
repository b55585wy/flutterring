import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'measurement_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../services/ring_platform.dart';
import '../models/ble_event.dart' as ble;
import '../models/device_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const MeasurementPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
  bool _isConnected = false;
  bool _isScanning = false;
  List<Map<String, String>> _foundDevices = [];
  DeviceInfo? _deviceInfo;
  int? _batteryLevel;
  int? _currentHeartRate;
  int? _currentRespiratoryRate;
  StateSetter? _deviceSheetSetState;

  @override
  void initState() {
    super.initState();
    _listenToBleEvents();
    _loadDeviceInfo();
  }

  void _listenToBleEvents() {
    RingPlatform.eventStream.listen((event) {
      event.when(
        deviceFound: (name, address, rssi) {
          setState(() {
            // 去重：检查是否已存在相同地址的设备
            final exists =
                _foundDevices.any((device) => device['address'] == address);
            if (!exists) {
              _foundDevices.add({
                'name': name,
                'address': address,
              });
            }
          });
          _deviceSheetSetState?.call(() {});
        },
        scanCompleted: () {
          setState(() {
            _isScanning = false;
          });
          _deviceSheetSetState?.call(() {});
        },
        connectionStateChanged: (state, deviceName, address) {
          setState(() {
            _isConnected = state == ble.ConnectionState.connected;
          });
          if (_isConnected) {
            _loadDeviceInfo();
          }
        },
        vitalSignsUpdate: (hr, rr, quality) {
          setState(() {
            _currentHeartRate = hr;
            _currentRespiratoryRate = rr;
          });
        },
        batteryLevelUpdated: (level) {
          setState(() {
            _batteryLevel = level;
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
      );
    });
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await RingPlatform.getDeviceInfo();
      final battery = await RingPlatform.getBatteryLevel();
      setState(() {
        _deviceInfo = info;
        _batteryLevel = battery;
      });
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _startScan() async {
    // 1. 先请求权限
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

    // 2. 开始扫描
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
    });
    _deviceSheetSetState?.call(() {});

    try {
      await RingPlatform.scanDevices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描失败: $e')),
        );
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectDevice(String macAddress) async {
    try {
      print('🔵 Flutter: 开始连接设备 - $macAddress');
      await RingPlatform.connectDevice(macAddress);
      print('✅ Flutter: 连接命令已发送');
      if (mounted) {
        Navigator.pop(context); // Close device list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在连接...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Flutter: 连接失败 - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接失败: $e')),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await RingPlatform.disconnect();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('断开失败: $e')),
        );
      }
    }
  }

  void _showDeviceList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _deviceSheetSetState = setModalState;
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
                          if (_isScanning)
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
                      child: _foundDevices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bluetooth_searching,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isScanning
                                        ? '正在扫描附近的戒指...'
                                        : '未找到设备，请重新扫描',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _foundDevices.length,
                              itemBuilder: (context, index) {
                                final device = _foundDevices[index];
                                final address = device['address'] ?? '';
                                final hasAddress = address.isNotEmpty;
                                return ListTile(
                                  leading: const Icon(Icons.bluetooth),
                                  title: Text(device['name'] ?? '未命名设备'),
                                  subtitle: Text(
                                    hasAddress ? address : '未知地址',
                                  ),
                                  trailing: hasAddress
                                      ? const Icon(Icons.chevron_right)
                                      : const Icon(Icons.block,
                                          color: Colors.redAccent),
                                  enabled: hasAddress,
                                  onTap: hasAddress
                                      ? () => _connectDevice(address)
                                      : null,
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
    ).whenComplete(() {
      _deviceSheetSetState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        color: (_isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: _isConnected
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
                            _isConnected ? '戒指已连接' : '戒指未连接',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isConnected
                                ? (_deviceInfo != null
                                    ? '${_deviceInfo!.name} - 电量 ${_batteryLevel ?? '--'}%'
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
                    if (_isConnected)
                      TextButton(
                        onPressed: _disconnect,
                        child: const Text('断开'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          _startScan();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _showDeviceList();
                          });
                        },
                        child: const Text('扫描'),
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
