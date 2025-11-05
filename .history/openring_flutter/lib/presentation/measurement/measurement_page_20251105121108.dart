import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:openring_flutter/application/controllers/measurement_controller.dart';
import 'package:openring_flutter/domain/models/ble_event.dart'
    as ble show ConnectionState, RecordingState, SignalQuality; // ✅ 使用别名
import 'package:openring_flutter/application/controllers/device_connection_controller.dart';

class MeasurementPage extends ConsumerStatefulWidget {
  const MeasurementPage({super.key});

  @override
  ConsumerState<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends ConsumerState<MeasurementPage>
    with SingleTickerProviderStateMixin {
  bool _showWave = false;
  late AnimationController _pulseController;

  // ✅ 添加连接状态监听
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _qualityToString(ble.SignalQuality quality) {
    switch (quality) {
      case ble.SignalQuality.excellent:
        return '优秀';
      case ble.SignalQuality.good:
        return '良好';
      case ble.SignalQuality.fair:
        return '一般';
      case ble.SignalQuality.poor:
        return '差';
      case ble.SignalQuality.noSignal:
        return '无信号';
    }
  }

  // ✅ 显示时长选择对话框
  Future<int?> _showDurationDialog() async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择测量时长'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationOption('30 秒', 30),
            _buildDurationOption('1 分钟 (60秒)', 60),
            _buildDurationOption('2 分钟 (120秒)', 120),
            _buildDurationOption('5 分钟 (300秒)', 300),
            const Divider(),
            _buildDurationOption('自定义...', -1),
          ],
        ),
      ),
    );
  }

  // 时长选项
  Widget _buildDurationOption(String label, int seconds) {
    return ListTile(
      title: Text(label),
      onTap: () async {
        if (seconds == -1) {
          // 自定义时长
          Navigator.pop(context);
          final customDuration = await _showCustomDurationDialog();
          if (customDuration != null && mounted) {
            Navigator.pop(context, customDuration);
          }
        } else {
          Navigator.pop(context, seconds);
        }
      },
    );
  }

  // 自定义时长输入对话框
  Future<int?> _showCustomDurationDialog() async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义测量时长'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '时长（秒）',
            hintText: '请输入1-3600秒',
            suffixText: '秒',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 3600) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入1-3600之间的数字')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '实时测量',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 数据源选择器
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '数据源',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: '实时测量（在线）',
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items: const [
                            DropdownMenuItem(
                              value: '实时测量（在线）',
                              child: Row(
                                children: [
                                  Icon(Icons.sensors,
                                      size: 20, color: Color(0xFF10B981)),
                                  SizedBox(width: 12),
                                  Text('实时测量（在线）'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '戒指录制（离线）',
                              child: Row(
                                children: [
                                  Icon(Icons.fiber_manual_record,
                                      size: 20, color: Color(0xFFEF4444)),
                                  SizedBox(width: 12),
                                  Text('戒指录制（离线）'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '本地文件回放',
                              child: Row(
                                children: [
                                  Icon(Icons.folder_open,
                                      size: 20, color: Color(0xFF6366F1)),
                                  SizedBox(width: 12),
                                  Text('本地文件回放'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 生理指标卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalSignCard(
                            '心率',
                            widget.measurementController.heartRate,
                            'BPM',
                            Icons.favorite_rounded,
                            const Color(0xFFEF4444),
                            widget.measurementController.isRecording,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildVitalSignCard(
                            '呼吸率',
                            widget.measurementController.respiratoryRate,
                            'RPM',
                            Icons.air,
                            const Color(0xFF3B82F6),
                            false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSignalQualityBar(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 波形图表
            const Text(
              '实时波形',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Container(
                height: 280,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                        child: _buildWaveformChannel(
                            'PPG Green', const Color(0xFF10B981))),
                    const Divider(height: 1),
                    Expanded(
                        child: _buildWaveformChannel(
                            'PPG Red', const Color(0xFFEF4444))),
                    const Divider(height: 1),
                    Expanded(
                        child: _buildWaveformChannel(
                            'PPG IR', const Color(0xFFF59E0B))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 数据统计
            if (widget.measurementController.isRecording && widget.measurementController.sampleCount > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '已接收 ${widget.measurementController.sampleCount} 个样本',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.measurementController.isRecording && widget.measurementController.sampleCount > 0) const SizedBox(height: 16),

            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: _buildControlButton(
                    widget.measurementController.isRecording ? '停止测量' : (_isConnected ? '开始测量' : '请先连接设备'),
                    widget.measurementController.isRecording ? Icons.stop_circle : Icons.play_circle_filled,
                    widget.measurementController.isRecording
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    // ✅ 检查连接状态后才允许操作
                    (!widget.measurementController.isRecording && !_isConnected)
                        ? null
                        : () async {
                            if (widget.measurementController.isRecording) {
                              // 停止测量
                              try {
                                print('🔵 Flutter Measurement: 停止测量');
                                await widget.measurementController.stopMeasurement();
                                setState(() {
                                  // _isRecording = false; // This state is now managed by the controller
                                  // _heartRate = 0;
                                  // _respiratoryRate = 0;
                                  // _signalQuality = '无信号';
                                  // _ppgGreenData.clear();
                                  // _sampleCount = 0;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('测量已停止')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('停止测量失败: $e')),
                                  );
                                }
                              }
                            } else {
                              // ✅ 显示时长选择对话框
                              final duration = await _showDurationDialog();
                              if (duration == null) return;

                              // 开始测量
                              try {
                                print(
                                    '🔵 Flutter Measurement: 开始测量，时长=$duration秒');
                                await widget.measurementController.startLiveMeasurement(
                                    duration: duration);
                                setState(() {
                                  // _isRecording = true; // This state is now managed by the controller
                                  // _sampleCount = 0;
                                });
                                print(
                                    '🔵 Flutter Measurement: 测量状态已更新，_isRecording=$_isRecording');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('测量已开始，时长$duration秒')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('启动测量失败: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignCard(
    String label,
    int value,
    String unit,
    IconData icon,
    Color color,
    bool animate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (animate)
                ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
                  child: Icon(icon, color: color, size: 24),
                )
              else
                Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value == 0 ? '--' : value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalQualityBar() {
    final qualityLevel = _qualityToString(widget.measurementController.signalQuality) == '优秀'
        ? 1.0
        : _qualityToString(widget.measurementController.signalQuality) == '良好'
            ? 0.75
            : _qualityToString(widget.measurementController.signalQuality) == '一般'
                ? 0.5
                : 0.0;

    final qualityColor = _qualityToString(widget.measurementController.signalQuality) == '优秀'
        ? const Color(0xFF10B981)
        : _qualityToString(widget.measurementController.signalQuality) == '良好'
            ? const Color(0xFF3B82F6)
            : _qualityToString(widget.measurementController.signalQuality) == '一般'
                ? const Color(0xFFF59E0B)
                : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '信号质量',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _qualityToString(widget.measurementController.signalQuality),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: qualityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: qualityLevel,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(qualityColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformChannel(String label, Color color) {
    return Stack(
      children: [
        Center(
          child: Text(
            widget.measurementController.isRecording ? '数据采集中...' : '等待开始',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ),
        if (widget.measurementController.isRecording)
          CustomPaint(
            painter: WaveformPainter(color: color),
            child: Container(),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed, // ✅ 改为可空，支持禁用状态
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey, // ✅ 禁用时显示灰色
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 简单的波形绘制器
class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = 100;
    final dx = size.width / points;

    for (int i = 0; i < points; i++) {
      final x = i * dx;
      final y = size.height / 2 +
          math.sin(i / 5 + DateTime.now().millisecond / 100) * size.height / 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
