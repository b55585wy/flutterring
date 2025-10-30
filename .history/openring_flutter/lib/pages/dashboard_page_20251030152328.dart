import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenRing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备状态卡片
            _DeviceStatusCard(),

            const SizedBox(height: 16),

            // 快速操作
            _QuickActionsGrid(),

            const SizedBox(height: 16),

            // 最近记录
            const Text(
              '最近记录',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _RecentRecordsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _DeviceStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 从 Provider 获取设备状态
    final isConnected = false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              size: 40,
              color: isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? '已连接' : '未连接',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isConnected) const Text('Ring Device • 电量 85%'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 连接/断开设备
              },
              child: Text(isConnected ? '断开' : '连接'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _QuickActionButton(
          icon: Icons.play_arrow,
          label: '开始测量',
          color: Colors.blue,
          onTap: () => context.go('/measurement'),
        ),
        _QuickActionButton(
          icon: Icons.history,
          label: '历史记录',
          color: Colors.orange,
          onTap: () => context.go('/history'),
        ),
        _QuickActionButton(
          icon: Icons.bluetooth_searching,
          label: '扫描设备',
          color: Colors.green,
          onTap: () {
            // TODO: 扫描设备
          },
        ),
        _QuickActionButton(
          icon: Icons.settings,
          label: '设置',
          color: Colors.grey,
          onTap: () => context.go('/settings'),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRecordsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: 从数据库加载最近记录
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.insert_drive_file),
          title: Text('测量记录 ${index + 1}'),
          subtitle: const Text('2024-10-30 14:23 • 5分钟'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 打开记录详情
          },
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: '仪表盘',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: '测量',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: '历史',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/measurement');
            break;
          case 2:
            context.go('/history');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
    );
  }
}
