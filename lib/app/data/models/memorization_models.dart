class MemorizationPlan {
  final int? id;
  final int? userId; // Added userId
  final String name;
  final DateTime startDate;
  final DateTime targetDate;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int dailyAmountPages;
  final String status; // active, completed, archived

  MemorizationPlan({
    this.id,
    this.userId,
    required this.name,
    required this.startDate,
    required this.targetDate,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.dailyAmountPages,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'start_surah': startSurah,
      'start_ayah': startAyah,
      'end_surah': endSurah,
      'end_ayah': endAyah,
      'daily_amount_pages': dailyAmountPages,
      'status': status,
    };
  }

  factory MemorizationPlan.fromMap(Map<String, dynamic> map) {
    return MemorizationPlan(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      startDate: DateTime.parse(map['start_date']),
      targetDate: DateTime.parse(map['target_date']),
      startSurah: map['start_surah'],
      startAyah: map['start_ayah'],
      endSurah: map['end_surah'],
      endAyah: map['end_ayah'],
      dailyAmountPages: map['daily_amount_pages'],
      status: map['status'],
    );
  }
}

class DailyLog {
  final int? id;
  final int planId;
  final DateTime date;
  final int pagesReviewed;
  final int pagesMemorized;
  final int rating; // 1-5

  DailyLog({
    this.id,
    required this.planId,
    required this.date,
    required this.pagesReviewed,
    required this.pagesMemorized,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'date': date.toIso8601String(),
      'pages_reviewed': pagesReviewed,
      'pages_memorized': pagesMemorized,
      'rating': rating,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'],
      planId: map['plan_id'],
      date: DateTime.parse(map['date']),
      pagesReviewed: map['pages_reviewed'],
      pagesMemorized: map['pages_memorized'],
      rating: map['rating'],
    );
  }
}

class QuizResult {
  final int? id;
  final int? userId;
  final int? planId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final String type;
  final DateTime createdAt;

  QuizResult({
    this.id,
    this.userId,
    this.planId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      userId: map['user_id'],
      planId: map['plan_id'],
      score: map['score'],
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      type: map['type'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class QuizQuestion {
  final int? id;
  final int? quizId;
  final String questionText;
  final String correctAnswer;
  String? userAnswer;
  bool? isCorrect;
  final String? metadata;

  QuizQuestion({
    this.id,
    this.quizId,
    required this.questionText,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'is_correct': isCorrect == true ? 1 : 0,
      'metadata': metadata,
    };
  }
}
