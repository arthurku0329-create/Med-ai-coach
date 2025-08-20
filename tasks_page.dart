import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../providers.dart';
import '../app_router.dart';
import '../repo.dart';

/// Displays the study schedule and exam countdown for today.
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    // Preload exam and chapter lists from providers for countdown and titles.
    final examsList = ref.watch(examsProvider).maybeWhen(
      data: (e) => e,
      orElse: () => <Exam>[],
    );
    return HomeScaffold(
      child: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('載入任務失敗: $e')),
        data: (tasks) {
          // Determine next exam countdown.
          final now = DateTime.now();
          int? daysLeft;
          String? examTitle;
          // Compute the nearest upcoming exam.
          final upcoming = examsList
              .where((e) => !e.date.isBefore(now))
              .toList();
          if (upcoming.isNotEmpty) {
            upcoming.sort((a, b) => a.date.compareTo(b.date));
            final next = upcoming.first;
            daysLeft = next.date
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;
            examTitle = next.title;
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (daysLeft != null)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '距離【$examTitle】考試還有 ${daysLeft!} 天',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              for (final task in tasks)
                _TaskTile(
                  task: task,
                  chaptersAsync: chaptersAsync,
                  onToggle: () async {
                    final repo = ref.read(repoProvider);
                    await repo.toggleTask(task.id);
                    ref.invalidate(tasksProvider);
                  },
                ),
              const SizedBox(height: 72),
            ],
          );
        },
      ),
    );
  }
}

/// A single task tile showing chapter info and completion status.
class _TaskTile extends ConsumerWidget {
  final StudyTask task;
  final AsyncValue<List<Chapter>> chaptersAsync;
  final VoidCallback onToggle;
  const _TaskTile({
    required this.task,
    required this.chaptersAsync,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title = '複習卡片';
    if (task.type == 'study' && task.chapterId != null) {
      chaptersAsync.whenData((chapters) {
        final ch = chapters.firstWhere((c) => c.id == task.chapterId,
            orElse: () => Chapter(id: task.chapterId!, course: '', title: '未知章節'));
        title = ch.title;
      });
    } else if (task.type == 'review') {
      title = '複習卡片';
    }
    return ListTile(
      leading: Checkbox(
        value: task.status == 'done',
        onChanged: (_) => onToggle(),
      ),
      title: Text(title),
      subtitle: Text('預估 ${task.estMin} 分鐘 · 優先度 ${task.priority}'),
    );
  }
}