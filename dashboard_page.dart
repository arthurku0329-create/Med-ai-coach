import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers.dart';
import '../models.dart';
import '../app_router.dart';

/// Displays high‑level statistics and wellness trends.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final wellnessAsync = ref.watch(wellnessLogsProvider);
    return HomeScaffold(
      child: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('載入失敗: $e')),
        data: (tasks) {
          return wellnessAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('載入失敗: $e')),
            data: (logs) {
              final total = tasks.length;
              final done = tasks.where((t) => t.status == 'done').length;
              double avgSleep = 0;
              double avgStress = 0;
              if (logs.isNotEmpty) {
                avgSleep = logs
                        .map((e) => e.sleepHours)
                        .reduce((a, b) => a + b) /
                    logs.length;
                avgStress = logs
                        .map((e) => e.stress.toDouble())
                        .reduce((a, b) => a + b) /
                    logs.length;
              }
              final df = DateFormat('M/d');
              // Prepare last 7 days data for charts (if logs available).
              final recent = logs.reversed.take(7).toList().reversed.toList();
              final dates = recent.map((e) => df.format(e.date)).toList();
              final sleepData = recent.map((e) => e.sleepHours).toList();
              final stressData = recent.map((e) => e.stress.toDouble()).toList();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_alt),
                      title: const Text('任務完成度'),
                      subtitle: Text('$done / $total'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bedtime),
                      title: const Text('平均睡眠'),
                      subtitle: Text(avgSleep.toStringAsFixed(1) + ' 小時'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bolt),
                      title: const Text('平均壓力'),
                      subtitle: Text(avgStress.toStringAsFixed(1) + ' / 10'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (recent.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('睡眠趨勢 (最近 7 天)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: _SimpleLineChart(data: sleepData, labels: dates),
                        ),
                        const SizedBox(height: 24),
                        const Text('壓力趨勢 (最近 7 天)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: _SimpleLineChart(data: stressData, labels: dates),
                        ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// A basic line chart based on a simple custom painter.
///
/// This avoids pulling in a heavy charting library for the MVP.
class _SimpleLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _SimpleLineChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(data, labels),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  _LineChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );
    final maxVal = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
    final minVal = data.isEmpty ? 0 : data.reduce((a, b) => a < b ? a : b);
    final yRange = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    // Draw axes
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final dx = data.length > 1 ? chartWidth / (data.length - 1) : chartWidth;
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + dx * i;
      final y = padding + chartHeight * (1 - (data[i] - minVal) / yRange);
      points.add(Offset(x, y));
    }
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    // Draw dots and labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 3, paint);
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(point.dx - tp.width / 2, size.height - padding + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}