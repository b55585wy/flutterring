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
  String? _connectedDeviceName;
  String? _connectedDeviceAddress;
  
  // 扫描到的设备列表 - 实时更新
  final List<BleDevice> _scannedDevices = [];
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _listenToBleEvents();
  }

  // 监听 BLE 事件 - 实时接收扫描到的设备
  void _listenToBleEvents() {
    _eventSubscription = RingPlatform.eventStream.listen((event) {
      final type = event['type'] as String?;
      
      if (!mounted) return;
      
      switch (type) {
        case 'scanStarted':
          setState(() {
            _isScanning = true;
            _scannedDevices.clear(); // 清空之前的列表
          });
          break;
          
        case 'deviceFound':
          // ✅ 实时添加设备到列表
          final deviceData = event['device'] as Map<String, dynamic>?;
          if (deviceData != null) {
            final device = BleDevice(
              name: deviceData['name'] as String,
              address: deviceData['address'] as String,
              rssi: deviceData['rssi'] as int,
            );
            
            setState(() {
              // 检查是否已存在，避免重复
              final index = _scannedDevices.indexWhere(
                (d) => d.address == device.address
              );
              if (index == -1) {
                _scannedDevices.add(device);
                debugPrint('✅ 实时添加设备: ${device.name} (${device.address})');
              } else {
                // 更新 RSSI
                _scannedDevices[index] = device;
              }
            });
          }
          break;
          
        case 'scanCompleted':
          setState(() {
            _isScanning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('扫描完成，发现 ${_scannedDevices.length} 个设备'),
              duration: const Duration(seconds: 2),
            ),
          );
          break;
          
        case 'connectionStateChanged':
          final state = event['state'] as String?;
          final address = event['address'] as String?;
          
          setState(() {
            _isConnected = state == 'connected';
            if (_isConnected && address != null) {
              final device = _scannedDevices.firstWhere(
                (d) => d.address == address,
                orElse: () => BleDevice(name: '未知设备', address: address, rssi: 0),
              );
              _connectedDeviceName = device.name;
              _connectedDeviceAddress = address;
            } else {
              _connectedDeviceName = null;
              _connectedDeviceAddress = null;
            }
          });
          break;
      }
    });
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        _scannedDevices.clear();
        _isScanning = true;
      });
      
      await RingPlatform.scanDevices();
      
      // 30秒后自动停止扫描
      Future.delayed(const Duration(seconds: 30), () {
        if (_isScanning) {
          _stopScan();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await RingPlatform.stopScan();
      setState(() => _isScanning = false);
    } catch (e) {
      debugPrint('停止扫描失败: $e');
    }
  }

  Future<void> _connectToDevice(BleDevice device) async {
    try {
      await RingPlatform.connectDevice(device.address);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在连接 ${device.name}...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      await RingPlatform.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已断开连接')),
      );
    } catch (e) {
      debugPrint('断开连接失败: $e');
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OpenRing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_connected, color: Colors.green),
              onPressed: _disconnect,
              tooltip: '断开连接',
            ),
        ],
      ),
      body: Column(
        children: [
          // 连接状态卡片
          if (_isConnected)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connectedDeviceName ?? '未知设备',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _connectedDeviceAddress ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _disconnect,
                    child: const Text('断开'),
                  ),
                ],
              ),
            ),
          
          // 扫描按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? _stopScan : _startScan,
                icon: Icon(_isScanning ? Icons.stop : Icons.search),
                label: Text(_isScanning ? '停止扫描' : '扫描设备'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isScanning ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          
          // 扫描状态
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '正在扫描... 已发现 ${_scannedDevices.length} 个设备',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // 设备列表 - 实时更新
          Expanded(
            child: _scannedDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.search : Icons.bluetooth_disabled,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning ? '正在搜索设备...' : '点击上方按钮开始扫描',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _scannedDevices.length,
                    itemBuilder: (context, index) {
                      final device = _scannedDevices[index];
                      final isCurrentDevice = _connectedDeviceAddress == device.address;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCurrentDevice
                                  ? Colors.green.shade100
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isCurrentDevice
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth,
                              color: isCurrentDevice
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${device.address} • RSSI: ${device.rssi} dBm',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: isCurrentDevice
                              ? const Chip(
                                  label: Text(
                                    '已连接',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                )
                              : ElevatedButton(
                                  onPressed: () => _connectToDevice(device),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('连接'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// BLE 设备模型
class BleDevice {
  final String name;
  final String address;
  final int rssi;

  BleDevice({
    required this.name,
    required this.address,
    required this.rssi,
  });
}
