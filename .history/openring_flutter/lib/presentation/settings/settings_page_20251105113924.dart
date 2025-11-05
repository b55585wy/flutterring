import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openring_flutter/application/controllers/device_connection_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(deviceConnectionControllerProvider);
    final controller =
        ref.read(deviceConnectionControllerProvider.notifier);

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
                  iconColor:
                      isConnected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
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
