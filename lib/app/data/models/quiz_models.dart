enum QuizType {
  fillInBlank, // إكمال الآية
  multipleChoice, // اختيار الكلمة الصحيحة
  ordering, // ترتيب الآيات
}

class QuizQuestion {
  final int id;
  final QuizType type;
  final String question;
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final int surahNumber;
  final int ayahNumber;
  final String? ayahText; // Full ayah text for reference

  QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.surahNumber,
    required this.ayahNumber,
    this.ayahText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'question': question,
      'options': options.join('|||'),
      'correctAnswer': correctAnswer,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      type: QuizType.values[map['type']],
      question: map['question'],
      options: (map['options'] as String).split('|||'),
      correctAnswer: map['correctAnswer'],
      surahNumber: map['surahNumber'],
      ayahNumber: map['ayahNumber'],
      ayahText: map['ayahText'],
    );
  }
}

class QuizAnswer {
  final int questionId;
  final String userAnswer;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeSpentSeconds;

  QuizAnswer({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpentSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect ? 1 : 0,
      'answeredAt': answeredAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }
}

class QuizResult {
  final int quizId;
  final int userId;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double scorePercentage;
  final int totalTimeSeconds;
  final DateTime completedAt;
  final List<QuizAnswer> answers;

  QuizResult({
    required this.quizId,
    required this.userId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.scorePercentage,
    required this.totalTimeSeconds,
    required this.completedAt,
    required this.answers,
  });

  String get grade {
    if (scorePercentage >= 90) return 'ممتاز';
    if (scorePercentage >= 80) return 'جيد جداً';
    if (scorePercentage >= 70) return 'جيد';
    if (scorePercentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'userId': userId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'scorePercentage': scorePercentage,
      'totalTimeSeconds': totalTimeSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
