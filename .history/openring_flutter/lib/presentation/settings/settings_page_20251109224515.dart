import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/application/controllers/device_connection_controller.dart';
import 'package:openring_flutter/infrastructure/storage/device_storage.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _rememberDevice = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final remember = await DeviceStorage.getRememberDevice();
    if (mounted) {
      setState(() {
        _rememberDevice = remember;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(deviceConnectionControllerProvider);
    final controller = ref.read(deviceConnectionControllerProvider.notifier);

    final isConnected = connectionState.isConnected;
    final deviceInfo = connectionState.deviceInfo;
    final deviceName = deviceInfo?.name ?? connectionState.deviceName;
    final deviceAddress =
        deviceInfo?.address ?? connectionState.address ?? '未知地址';
    final batteryLevel = deviceInfo?.batteryLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              '设备管理',
              [
                _buildSettingItem(
                  icon: Icons.bluetooth_connected,
                  title: '连接状态',
                  trailing: isConnected ? '已连接' : '未连接',
                  iconColor: isConnected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                  onTap: controller.refresh,
                ),
                _buildSettingItem(
                  icon: Icons.devices,
                  title: '设备',
                  trailing: deviceInfo != null
                      ? '${deviceName ?? '研究戒指'}\n$deviceAddress'
                      : '暂无',
                  iconColor: const Color(0xFF6366F1),
                  onTap: controller.refresh,
                ),
                _buildSettingItem(
                  icon: Icons.battery_full,
                  title: '电量',
                  trailing: batteryLevel != null ? '$batteryLevel%' : '--',
                  iconColor: const Color(0xFF0EA5E9),
                  onTap: controller.refresh,
                ),
                _buildSettingItem(
                  icon: Icons.update,
                  title: '固件更新',
                  trailing: '检查更新',
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '数据管理',
              [
                _buildSettingItem(
                  icon: Icons.cloud_upload,
                  title: '数据同步',
                  trailing: '自动同步',
                  iconColor: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.file_download,
                  title: '数据导出',
                  trailing: '导出 CSV',
                  iconColor: const Color(0xFF8B5CF6),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.delete_sweep,
                  title: '清除数据',
                  trailing: '谨慎操作',
                  iconColor: const Color(0xFFEF4444),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '应用设置',
              [
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: '通知设置',
                  trailing: '已开启',
                  iconColor: const Color(0xFF10B981),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: '语言设置',
                  trailing: '简体中文',
                  iconColor: const Color(0xFF6366F1),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: '深色模式',
                  trailing: '跟随系统',
                  iconColor: const Color(0xFF64748B),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '关于',
              [
                _buildSettingItem(
                  icon: Icons.info,
                  title: '版本信息',
                  trailing: 'v1.0.0',
                  iconColor: const Color(0xFF64748B),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: '隐私政策',
                  trailing: '',
                  iconColor: const Color(0xFF64748B),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.description,
                  title: '用户协议',
                  trailing: '',
                  iconColor: const Color(0xFF64748B),
                  onTap: () {},
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String trailing,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
            Flexible(
              child: Text(
                trailing,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
