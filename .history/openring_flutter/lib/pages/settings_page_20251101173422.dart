import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ble_event.dart' as ble;
import '../models/device_info.dart';
import '../services/ring_platform.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isConnected = false;
  DeviceInfo? _deviceInfo;
  StreamSubscription<ble.BleEvent>? _bleSubscription;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevice();
    _listenToBleEvents();
  }

  @override
  void dispose() {
    _bleSubscription?.cancel();
    super.dispose();
  }

  void _listenToBleEvents() {
    _bleSubscription = RingPlatform.eventStream.listen((event) {
      event.maybeWhen(
        connectionStateChanged: (state, name, address) {
          // 连接中或已连接时都视为"连接状态"
          if (state == ble.ConnectionState.connected) {
            _loadConnectedDevice();
          } else if (state == ble.ConnectionState.disconnected) {
            setState(() {
              _isConnected = false;
              _deviceInfo = null;
            });
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _loadConnectedDevice() async {
    try {
      print('🔵 Flutter Settings: 开始加载设备信息');
      final device = await RingPlatform.getConnectedDevice();
      print('🔵 Flutter Settings: 获取到设备 - $device');
      if (!mounted) return;
      setState(() {
        _deviceInfo = device;
        _isConnected = device != null;
      });
      print(
          '🔵 Flutter Settings: _isConnected = $_isConnected, name = ${device?.name}, address = ${device?.address}');
    } catch (e) {
      print('🔵 Flutter Settings: 加载设备信息失败 - $e');
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _deviceInfo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadConnectedDevice,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              '设备管理',
              [
                _buildSettingItem(
                  Icons.bluetooth_connected,
                  '连接状态',
                  _isConnected
                      ? '已连接'
                      : '未连接',
                  _isConnected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  _loadConnectedDevice,
                ),
                _buildSettingItem(
                  Icons.devices,
                  '设备信息',
                  _deviceInfo != null
                      ? '${_deviceInfo?.name ?? 'OpenRing'}\n${_deviceInfo?.address ?? '未知地址'}'
                      : '暂无设备',
                  const Color(0xFF6366F1),
                  _loadConnectedDevice,
                ),
                _buildSettingItem(
                  Icons.update,
                  '固件更新',
                  '检查更新',
                  const Color(0xFFF59E0B),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '数据管理',
              [
                _buildSettingItem(
                  Icons.cloud_upload,
                  '数据同步',
                  '自动同步',
                  const Color(0xFF3B82F6),
                  () {},
                ),
                _buildSettingItem(
                  Icons.file_download,
                  '数据导出',
                  '导出 CSV',
                  const Color(0xFF8B5CF6),
                  () {},
                ),
                _buildSettingItem(
                  Icons.delete_sweep,
                  '清除数据',
                  '谨慎操作',
                  const Color(0xFFEF4444),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '应用设置',
              [
                _buildSettingItem(
                  Icons.notifications,
                  '通知设置',
                  '已开启',
                  const Color(0xFF10B981),
                  () {},
                ),
                _buildSettingItem(
                  Icons.language,
                  '语言设置',
                  '简体中文',
                  const Color(0xFF6366F1),
                  () {},
                ),
                _buildSettingItem(
                  Icons.dark_mode,
                  '深色模式',
                  '跟随系统',
                  const Color(0xFF64748B),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '关于',
              [
                _buildSettingItem(
                  Icons.info,
                  '版本信息',
                  'v1.0.0',
                  const Color(0xFF64748B),
                  () {},
                ),
                _buildSettingItem(
                  Icons.privacy_tip,
                  '隐私政策',
                  '',
                  const Color(0xFF64748B),
                  () {},
                ),
                _buildSettingItem(
                  Icons.description,
                  '用户协议',
                  '',
                  const Color(0xFF64748B),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Card(
          child: Column(
            children: items
                .expand((item) => [item, const Divider(height: 1)])
                .take(items.length * 2 - 1)
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String trailing,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ],
      ),
    );
  }
}
