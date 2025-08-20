import 'dart:math';

import 'models.dart';

/// Internal scoring function used to prioritise study tasks.
///
/// The score combines exam urgency, forgetting risk, backlog
/// and a wellness penalty (high stress/low sleep reduce score).
int _score({
  required DateTime today,
  required DateTime examDate,
  required double examWeight,
  required int plannedPages,
  required int completedPages,
  required DateTime? lastReview,
  required double stress,
  required double sleepH,
}) {
  final daysLeft = max(1, examDate.difference(today).inDays);
  final urgency = examWeight / daysLeft;
  const optimalInterval = 3;
  final sinceReview = lastReview == null
      ? optimalInterval + 3
      : today.difference(lastReview).inDays;
  final forget = 1 / (1 + exp(-(sinceReview - optimalInterval).toDouble()));
  final backlog = max(0, plannedPages - completedPages) / max(1, plannedPages);
  final penalty = min(0.4, (stress / 10.0) + max(0, (6 - sleepH) / 6.0));
  var p = 0.5 * urgency + 0.3 * forget + 0.2 * backlog;
  p *= (1 - penalty);
  return (p * 100).clamp(0, 100).round();
}

/// Generate a list of study tasks for the given day.
///
/// This function will create a task for each chapter associated with an exam
/// and add a generic review task for spaced repetition. Only the top
/// six tasks by priority are returned.
List<StudyTask> generateTodayTasks({
  required DateTime today,
  required List<Exam> exams,
  required List<Chapter> chapters,
  required double avgSleepH,
  required double avgStress,
}) {
  final tasks = <StudyTask>[];
  String _makeId() =>
      '${DateTime.now().microsecondsSinceEpoch}${tasks.length}';
  for (final ch in chapters) {
    final exam = exams.firstWhere(
      (e) => e.course == ch.course,
      orElse: () => Exam(
        id: 'NA',
        title: 'NA',
        date: today.add(const Duration(days: 7)),
        course: ch.course,
      ),
    );
    final priority = _score(
      today: today,
      examDate: exam.date,
      examWeight: exam.weight,
      plannedPages: ch.pages,
      completedPages: ch.donePages,
      lastReview: ch.lastReview,
      stress: avgStress,
      sleepH: avgSleepH,
    );
    // Estimate minutes roughly based on pages and difficulty.
    final est = max(20, (ch.pages * (5 + ch.difficulty)).clamp(20, 120));
    tasks.add(
      StudyTask(
        id: _makeId(),
        chapterId: ch.id,
        due: DateTime(today.year, today.month, today.day),
        estMin: est,
        priority: priority,
        status: 'todo',
        type: 'study',
      ),
    );
  }
  // Always add a generic review session to handle due flashcards.
  tasks.add(
    StudyTask(
      id: _makeId(),
      chapterId: null,
      due: DateTime(today.year, today.month, today.day),
      estMin: 45,
      priority: 70,
      status: 'todo',
      type: 'review',
    ),
  );
  tasks.sort((a, b) => b.priority.compareTo(a.priority));
  return tasks.take(6).toList();
}