import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'services_scheduler.dart';
import 'services_sm2.dart';

/// Provider for accessing the single instance of [AppRepo].
final repoProvider = Provider<AppRepo>((ref) => throw UnimplementedError());

/// A simple repository that persists application data using
/// [SharedPreferences]. In a real application you would swap this
/// implementation for a local database or remote API.
class AppRepo {
  AppRepo(this._sp);
  final SharedPreferences _sp;

  static const _kExams = 'exams';
  static const _kChapters = 'chapters';
  static const _kTasks = 'tasks';
  static const _kCards = 'cards';
  static const _kWellness = 'wellness';

  /// Factory that creates the repository and initialises defaults on first run.
  static Future<AppRepo> create() async {
    final sp = await SharedPreferences.getInstance();
    final repo = AppRepo(sp);
    await repo._initDefaults();
    return repo;
  }

  /// Initialise some sample data if nothing exists in storage.
  Future<void> _initDefaults() async {
    if (!_sp.containsKey(_kExams)) {
      final today = DateTime.now();
      final sampleExams = [
        Exam(
          id: 'ex1',
          title: '藥理期中',
          date: today.add(const Duration(days: 12)),
          weight: 1.0,
          course: '藥理',
        ),
        Exam(
          id: 'ex2',
          title: '內科期末',
          date: today.add(const Duration(days: 20)),
          weight: 1.0,
          course: '內科',
        ),
      ];
      await saveExams(sampleExams);
    }
    if (!_sp.containsKey(_kChapters)) {
      final sampleChapters = [
        Chapter(id: 'ch1', course: '藥理', title: '自律神經藥物', pages: 15, difficulty: 3),
        Chapter(id: 'ch2', course: '藥理', title: '心血管藥物', pages: 20, difficulty: 4),
        Chapter(id: 'ch3', course: '內科', title: '心衰竭診療', pages: 18, difficulty: 3),
      ];
      await saveChapters(sampleChapters);
    }
    if (!_sp.containsKey(_kCards)) {
      final sampleCards = [
        CardItem(
          id: 'c1',
          course: '藥理',
          front: 'β阻斷劑臨床用途？',
          back: '高血壓、心律不整、心絞痛等',
          chapterId: 'ch2',
        ),
        CardItem(
          id: 'c2',
          course: '藥理',
          front: 'ACE抑制劑副作用？',
          back: '乾咳、高血鉀、腎功能惡化',
          chapterId: 'ch2',
        ),
        CardItem(
          id: 'c3',
          course: '內科',
          front: '心衰竭治療藥物有哪些？',
          back: 'ACEI/ARB、β阻斷劑、利尿劑等',
          chapterId: 'ch3',
        ),
      ];
      await saveCards(sampleCards);
    }
    // Generate today's tasks if none exist for today.
    final today = DateTime.now();
    final tasks = await getTasks();
    final hasToday = tasks.any((t) =>
        t.due.year == today.year &&
        t.due.month == today.month &&
        t.due.day == today.day);
    if (!hasToday) {
      await generateAndSaveTodayTasks();
    }
  }

  /// Decode a JSON list from preferences.
  List<T> _getList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final str = _sp.getString(key);
    if (str == null || str.isEmpty) return [];
    final decoded = json.decode(str) as List;
    return decoded.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// Persist a list of objects as JSON.
  Future<void> _saveList<T>(String key, List<T> list,
      Map<String, dynamic> Function(T) toJson) async {
    final encoded = json.encode(list.map((e) => toJson(e)).toList());
    await _sp.setString(key, encoded);
  }

  Future<List<Exam>> getExams() async => _getList(_kExams, Exam.fromJson);
  Future<void> saveExams(List<Exam> exams) async =>
      _saveList(_kExams, exams, (e) => e.toJson());

  Future<List<Chapter>> getChapters() async =>
      _getList(_kChapters, Chapter.fromJson);
  Future<void> saveChapters(List<Chapter> chapters) async =>
      _saveList(_kChapters, chapters, (c) => c.toJson());

  Future<List<StudyTask>> getTasks() async =>
      _getList(_kTasks, StudyTask.fromJson);
  Future<void> saveTasks(List<StudyTask> tasks) async =>
      _saveList(_kTasks, tasks, (t) => t.toJson());

  Future<List<CardItem>> getCards() async =>
      _getList(_kCards, CardItem.fromJson);
  Future<void> saveCards(List<CardItem> cards) async =>
      _saveList(_kCards, cards, (c) => c.toJson());

  Future<List<WellnessLog>> getWellnessLogs() async =>
      _getList(_kWellness, WellnessLog.fromJson);
  Future<void> saveWellnessLogs(List<WellnessLog> logs) async =>
      _saveList(_kWellness, logs, (l) => l.toJson());

  /// Create study tasks for the current day based on exams, chapters
  /// and recent wellness logs.
  Future<void> generateAndSaveTodayTasks() async {
    final exams = await getExams();
    final chapters = await getChapters();
    final wellness = await getWellnessLogs();
    double avgSleep = 7;
    double avgStress = 3;
    if (wellness.isNotEmpty) {
      // Compute the average over the last three logs.
      final reversed = wellness.reversed.take(3).toList();
      avgSleep =
          reversed.map((e) => e.sleepHours).reduce((a, b) => a + b) /
              reversed.length;
      avgStress =
          reversed.map((e) => e.stress).reduce((a, b) => a + b) /
              reversed.length;
    }
    final today = DateTime.now();
    final tasks = generateTodayTasks(
      today: today,
      exams: exams,
      chapters: chapters,
      avgSleepH: avgSleep,
      avgStress: avgStress,
    );
    await saveTasks(tasks);
  }

  /// Toggle the completion status of a task and persist the change.
  Future<void> toggleTask(String taskId) async {
    final tasks = await getTasks();
    for (final t in tasks) {
      if (t.id == taskId) {
        t.status = t.status == 'todo' ? 'done' : 'todo';
        break;
      }
    }
    await saveTasks(tasks);
  }

  /// Update a flashcard after the user grades it.
  Future<void> gradeCard(CardItem card, int quality) async {
    final cards = await getCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index < 0) return;
    final c = cards[index];
    final result = sm2Update(
      quality: quality,
      reps: c.reps,
      intervalDays: c.intervalDays,
      ef: c.ef,
    );
    c.reps = result.nextReps;
    c.ef = result.nextEf;
    c.intervalDays = result.nextIntervalDays;
    c.due = DateTime.now().add(Duration(days: c.intervalDays));
    await saveCards(cards);
  }

  /// Save or update a wellness log for a specific date.
  Future<void> saveWellnessLog(WellnessLog log) async {
    final logs = await getWellnessLogs();
    final idx = logs.indexWhere((l) =>
        l.date.year == log.date.year &&
        l.date.month == log.date.month &&
        l.date.day == log.date.day);
    if (idx >= 0) {
      logs[idx] = log;
    } else {
      logs.add(log);
    }
    await saveWellnessLogs(logs);
  }

  /// Fetch cards that are due for review (due date not after now).
  Future<List<CardItem>> getDueCards() async {
    final cards = await getCards();
    final now = DateTime.now();
    return cards.where((c) => !c.due.isAfter(now)).toList();
  }
}