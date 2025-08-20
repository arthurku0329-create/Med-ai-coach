/// Domain models used throughout the application.

/// Represents an upcoming examination for a course.
class Exam {
  final String id;
  final String title;
  final DateTime date;
  final double weight;
  final String course;

  Exam({
    required this.id,
    required this.title,
    required this.date,
    this.weight = 1.0,
    required this.course,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'weight': weight,
        'course': course,
      };

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'],
        title: j['title'],
        date: DateTime.parse(j['date']),
        weight: (j['weight'] as num?)?.toDouble() ?? 1.0,
        course: j['course'],
      );
}

/// Represents a chapter or section within a course.
class Chapter {
  final String id;
  final String course;
  final String title;
  final int pages;
  final int difficulty; // 1–5
  int donePages;
  DateTime? lastReview;

  Chapter({
    required this.id,
    required this.course,
    required this.title,
    this.pages = 10,
    this.difficulty = 3,
    this.donePages = 0,
    this.lastReview,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'title': title,
        'pages': pages,
        'difficulty': difficulty,
        'donePages': donePages,
        'lastReview': lastReview?.toIso8601String(),
      };

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
        id: j['id'],
        course: j['course'],
        title: j['title'],
        pages: j['pages'] ?? 10,
        difficulty: j['difficulty'] ?? 3,
        donePages: j['donePages'] ?? 0,
        lastReview: j['lastReview'] == null
            ? null
            : DateTime.parse(j['lastReview']),
      );
}

/// Represents an individual study task scheduled for a day.
class StudyTask {
  final String id;
  final String? chapterId;
  final DateTime due;
  final int estMin;
  final int priority; // 0–100
  String status; // 'todo' or 'done'
  final String type; // 'study' or 'review'

  StudyTask({
    required this.id,
    this.chapterId,
    required this.due,
    required this.estMin,
    required this.priority,
    this.status = 'todo',
    this.type = 'study',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'due': due.toIso8601String(),
        'estMin': estMin,
        'priority': priority,
        'status': status,
        'type': type,
      };

  factory StudyTask.fromJson(Map<String, dynamic> j) => StudyTask(
        id: j['id'],
        chapterId: j['chapterId'],
        due: DateTime.parse(j['due']),
        estMin: j['estMin'],
        priority: j['priority'],
        status: j['status'],
        type: j['type'],
      );
}

/// Represents a flashcard used for spaced repetition.
class CardItem {
  final String id;
  final String course;
  final String front;
  final String back;
  String chapterId;
  int reps;
  double ef; // Ease factor
  int intervalDays;
  DateTime due;

  CardItem({
    required this.id,
    required this.course,
    required this.front,
    required this.back,
    required this.chapterId,
    this.reps = 0,
    this.ef = 2.5,
    this.intervalDays = 0,
    DateTime? due,
  }) : due = due ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'front': front,
        'back': back,
        'chapterId': chapterId,
        'reps': reps,
        'ef': ef,
        'intervalDays': intervalDays,
        'due': due.toIso8601String(),
      };

  factory CardItem.fromJson(Map<String, dynamic> j) => CardItem(
        id: j['id'],
        course: j['course'],
        front: j['front'],
        back: j['back'],
        chapterId: j['chapterId'],
        reps: j['reps'] ?? 0,
        ef: (j['ef'] as num?)?.toDouble() ?? 2.5,
        intervalDays: j['intervalDays'] ?? 0,
        due: DateTime.parse(j['due']),
      );
}

/// Represents a daily log capturing sleep, exercise, mood and stress.
class WellnessLog {
  final DateTime date;
  double sleepHours;
  int exerciseMin;
  int mood; // 1–5
  int stress; // 1–10

  WellnessLog({
    required this.date,
    this.sleepHours = 0,
    this.exerciseMin = 0,
    this.mood = 3,
    this.stress = 3,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'sleepHours': sleepHours,
        'exerciseMin': exerciseMin,
        'mood': mood,
        'stress': stress,
      };

  factory WellnessLog.fromJson(Map<String, dynamic> j) => WellnessLog(
        date: DateTime.parse(j['date']),
        sleepHours: (j['sleepHours'] as num?)?.toDouble() ?? 0,
        exerciseMin: j['exerciseMin'] ?? 0,
        mood: j['mood'] ?? 3,
        stress: j['stress'] ?? 3,
      );
}