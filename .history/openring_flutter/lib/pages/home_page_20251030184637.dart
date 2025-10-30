import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ring_platform.dart';
import 'dart:async';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isScanning = false;
  bool _isConnected = false;
  String _connectionStatus = '未连接';
  List<Map<String, dynamic>> _scannedDevices = [];
  String? _connectedDeviceName;
  String? _connectedDeviceAddress;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _listenToBleEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToBleEvents() {
    _eventSubscription = RingPlatform.eventStream.listen((event) {
      final type = event['type'] as String;

      switch (type) {
        case 'deviceFound':
          final device = event['device'] as Map<String, dynamic>;
          setState(() {
            // 检查是否已存在
            final exists =
                _scannedDevices.any((d) => d['address'] == device['address']);
            if (!exists) {
              _scannedDevices.add(device);
            }
          });
          break;

        case 'scanStarted':
          setState(() {
            _isScanning = true;
            _scannedDevices.clear();
          });
          break;

        case 'scanCompleted':
          setState(() {
            _isScanning = false;
          });
          break;

        case 'connectionStateChanged':
          final state = event['state'] as String;
          setState(() {
            if (state == 'connected') {
              _isConnected = true;
              _connectionStatus = '已连接';
            } else if (state == 'connecting') {
              _connectionStatus = '连接中...';
            } else {
              _isConnected = false;
              _connectionStatus = '未连接';
              _connectedDeviceName = null;
              _connectedDeviceAddress = null;
            }
          });
          break;

        case 'error':
          final message = event['message'] as String?;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? '发生错误'),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
      }
    });
  }

  Future<void> _startScan() async {
    try {
      await RingPlatform.scanDevices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('扫描失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await RingPlatform.stopScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('停止扫描失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(String macAddress, String deviceName) async {
    try {
      setState(() {
        _connectionStatus = '连接中...';
      });

      await RingPlatform.connectDevice(macAddress);

      setState(() {
        _connectedDeviceName = deviceName;
        _connectedDeviceAddress = macAddress;
        _scannedDevices.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在连接到 $deviceName...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '连接失败';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await RingPlatform.disconnect();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已断开连接'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('断开连接失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenRing 智能戒指'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
            tooltip: '刷新',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 连接状态卡片
            _buildConnectionStatusCard(),
            const SizedBox(height: 20),

            // 扫描控制
            if (!_isConnected) ...[
              _buildScanControls(),
              const SizedBox(height: 20),

              // 扫描到的设备列表
              if (_scannedDevices.isNotEmpty) _buildDeviceList(),
            ],

            // 已连接设备信息
            if (_isConnected) ...[
              _buildConnectedDeviceInfo(),
              const SizedBox(height: 20),
              _buildQuickActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              _isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              size: 64,
              color: _isConnected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _connectionStatus,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _isConnected ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_connectedDeviceName != null) ...[
              const SizedBox(height: 8),
              Text(
                _connectedDeviceName!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _connectedDeviceAddress ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '扫描设备',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isScanning ? _stopScan : _startScan,
          icon: Icon(_isScanning ? Icons.stop : Icons.search),
          label: Text(_isScanning ? '停止扫描' : '开始扫描'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isScanning ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        if (_isScanning) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text(
            '正在扫描附近的设备...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildDeviceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '发现的设备 (${_scannedDevices.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _scannedDevices.length,
          itemBuilder: (context, index) {
            final device = _scannedDevices[index];
            final name = device['name'] as String;
            final address = device['address'] as String;
            final rssi = device['rssi'] as int?;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
                title: Text(name),
                subtitle: Text(address),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rssi != null) ...[
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: _getRssiColor(rssi),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rssi dBm',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () => _connectToDevice(address, name),
                      child: const Text('连接'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConnectedDeviceInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '设备信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('设备名称', _connectedDeviceName ?? '-'),
            const Divider(),
            _buildInfoRow('MAC 地址', _connectedDeviceAddress ?? '-'),
            const Divider(),
            _buildInfoRow('连接状态', '已连接'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _disconnect,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('断开连接'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '快捷操作',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickActionCard(
              icon: Icons.favorite,
              title: '实时测量',
              color: Colors.red,
              onTap: () {
                // TODO: 跳转到测量页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('即将跳转到测量页面')),
                );
              },
            ),
            _buildQuickActionCard(
              icon: Icons.history,
              title: '历史数据',
              color: Colors.blue,
              onTap: () {
                // TODO: 跳转到历史页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('即将跳转到历史页面')),
                );
              },
            ),
            _buildQuickActionCard(
              icon: Icons.settings,
              title: '设备设置',
              color: Colors.grey,
              onTap: () {
                // TODO: 跳转到设置页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('即将跳转到设置页面')),
                );
              },
            ),
            _buildQuickActionCard(
              icon: Icons.info,
              title: '设备信息',
              color: Colors.green,
              onTap: () async {
                try {
                  final info = await RingPlatform.getDeviceInfo();
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('设备信息'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('名称: ${info['name']}'),
                            Text('版本: ${info['version']}'),
                            Text('电量: ${info['battery']}%'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('获取设备信息失败: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi > -60) return Colors.green;
    if (rssi > -80) return Colors.orange;
    return Colors.red;
  }
}
