import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const _Section(title: '设备设置'),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('蓝牙设备'),
            subtitle: const Text('管理已连接的设备'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 打开设备管理
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('时间同步'),
            subtitle: const Text('同步戒指时间'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 时间同步
            },
          ),
          const Divider(),
          
          const _Section(title: '测量设置'),
          SwitchListTile(
            secondary: const Icon(Icons.fiber_manual_record),
            title: const Text('自动录制'),
            subtitle: const Text('测量时自动保存到本地'),
            value: true,
            onChanged: (value) {
              // TODO: 切换自动录制
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('默认测量时长'),
            subtitle: const Text('60 秒'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 设置测量时长
            },
          ),
          const Divider(),
          
          const _Section(title: '通知设置'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('离线采集完成提醒'),
            subtitle: const Text('戒指录制完成后通知'),
            value: true,
            onChanged: (value) {
              // TODO: 切换通知
            },
          ),
          const Divider(),
          
          const _Section(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本'),
            subtitle: const Text('1.0.0+1'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('使用说明'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 打开使用说明
            },
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

