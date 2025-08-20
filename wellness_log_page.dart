import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo.dart';
import '../models.dart';
import '../app_router.dart';

/// Page for recording daily wellness: sleep, exercise, mood and stress.
class WellnessLogPage extends ConsumerStatefulWidget {
  const WellnessLogPage({super.key});
  @override
  ConsumerState<WellnessLogPage> createState() => _WellnessLogPageState();
}

class _WellnessLogPageState extends ConsumerState<WellnessLogPage> {
  double sleepHours = 7;
  int exerciseMin = 30;
  int mood = 3;
  int stress = 3;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      child: Scaffold(
        appBar: AppBar(title: const Text('身心日誌')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(child: Text('睡眠 (小時)')),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: sleepHours.toStringAsFixed(1),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(suffixText: 'h'),
                    onChanged: (val) {
                      final d = double.tryParse(val);
                      if (d != null) setState(() => sleepHours = d);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('運動 (分鐘)')),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: exerciseMin.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'min'),
                    onChanged: (val) {
                      final d = int.tryParse(val);
                      if (d != null) setState(() => exerciseMin = d);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('心情 (1–5)'),
            Slider(
              value: mood.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$mood',
              onChanged: (v) => setState(() => mood = v.round()),
            ),
            const SizedBox(height: 12),
            Text('壓力 (1–10)'),
            Slider(
              value: stress.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$stress',
              onChanged: (v) => setState(() => stress = v.round()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(repoProvider);
                final now = DateTime.now();
                final log = WellnessLog(
                  date: DateTime(now.year, now.month, now.day),
                  sleepHours: sleepHours,
                  exerciseMin: exerciseMin,
                  mood: mood,
                  stress: stress,
                );
                await repo.saveWellnessLog(log);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('日誌已儲存')),
                  );
                }
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }
}