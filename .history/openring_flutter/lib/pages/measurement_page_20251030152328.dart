import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeasurementPage extends ConsumerStatefulWidget {
  const MeasurementPage({super.key});

  @override
  ConsumerState<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends ConsumerState<MeasurementPage> {
  String _selectedSource = '实时测量（在线）';
  final _sources = ['实时测量（在线）', '戒指录制（离线）', '本地文件回放'];

  bool _isActive = false;
  int? _heartRate;
  int? _respiratoryRate;
  String _signalQuality = '无信号';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测量'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 数据源选择器
            _DataSourceSelector(
              selectedSource: _selectedSource,
              sources: _sources,
              onChanged: (value) {
                setState(() {
                  _selectedSource = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // 离线状态卡片（仅离线模式显示）
            if (_selectedSource == '戒指录制（离线）') _OfflineStatusCard(),

            const SizedBox(height: 16),

            // 生理指标卡片
            _VitalSignsCard(
              heartRate: _heartRate,
              respiratoryRate: _respiratoryRate,
              signalQuality: _signalQuality,
            ),

            const SizedBox(height: 16),

            // 波形图表
            const _WaveformChartPlaceholder(),

            const SizedBox(height: 16),

            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isActive
                      ? null
                      : () {
                          setState(() {
                            _isActive = true;
                          });
                          // TODO: 启动测量
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始测量'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 48),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isActive
                      ? () {
                          setState(() {
                            _isActive = false;
                          });
                          // TODO: 停止测量
                        }
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 48),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSourceSelector extends StatelessWidget {
  final String selectedSource;
  final List<String> sources;
  final ValueChanged<String?> onChanged;

  const _DataSourceSelector({
    required this.selectedSource,
    required this.sources,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据源',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedSource,
              isExpanded: true,
              items: sources.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  '戒指正在采集数据',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(value: 0.45),
            const SizedBox(height: 8),
            const Text('预计剩余 2 分 30 秒'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: 断开连接
                  },
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('断开连接（省电）'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalSignsCard extends StatelessWidget {
  final int? heartRate;
  final int? respiratoryRate;
  final String signalQuality;

  const _VitalSignsCard({
    required this.heartRate,
    required this.respiratoryRate,
    required this.signalQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _VitalSign(
              icon: Icons.favorite,
              label: '心率',
              value: heartRate?.toString() ?? '--',
              unit: 'BPM',
              color: Colors.red,
            ),
            _VitalSign(
              icon: Icons.air,
              label: '呼吸率',
              value: respiratoryRate?.toString() ?? '--',
              unit: 'RPM',
              color: Colors.blue,
            ),
            _VitalSign(
              icon: Icons.signal_cellular_alt,
              label: '信号质量',
              value: signalQuality,
              unit: '',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalSign extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _VitalSign({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (unit.isNotEmpty)
          Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _WaveformChartPlaceholder extends StatelessWidget {
  const _WaveformChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: _WaveformChannel(label: 'PPG Green', color: Colors.green),
          ),
          const Divider(height: 1),
          Expanded(
            child: _WaveformChannel(label: 'PPG Red', color: Colors.red),
          ),
          const Divider(height: 1),
          Expanded(
            child: _WaveformChannel(label: 'PPG IR', color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

class _WaveformChannel extends StatelessWidget {
  final String label;
  final Color color;

  const _WaveformChannel({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            '等待数据...',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
