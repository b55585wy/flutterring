import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 筛选记录
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.show_chart, color: Colors.white),
              ),
              title: Text('测量记录 ${index + 1}'),
              subtitle: Text('2024-10-30 14:23 • 5分钟\nHR: 75 BPM, RR: 15 RPM'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  // TODO: 回放记录
                },
              ),
              onTap: () {
                // TODO: 显示详情
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 导出记录
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }
}
