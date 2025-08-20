import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'repo.dart';

/// Expose a list of study tasks for the current day.
///
/// The caller can refresh this provider after modifying a task to
/// re‑fetch the latest list.
final tasksProvider = FutureProvider<List<StudyTask>>((ref) async {
  final repo = ref.watch(repoProvider);
  return repo.getTasks();
});

/// Provide a list of cards that are due for review.
final dueCardsProvider = FutureProvider<List<CardItem>>((ref) async {
  final repo = ref.watch(repoProvider);
  return repo.getDueCards();
});

/// Provide all wellness logs (used on the dashboard).
final wellnessLogsProvider = FutureProvider<List<WellnessLog>>((ref) async {
  final repo = ref.watch(repoProvider);
  return repo.getWellnessLogs();
});

/// Provide the list of upcoming exams.
final examsProvider = FutureProvider<List<Exam>>((ref) async {
  final repo = ref.watch(repoProvider);
  return repo.getExams();
});

/// Provide the list of chapters.
final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final repo = ref.watch(repoProvider);
  return repo.getChapters();
});