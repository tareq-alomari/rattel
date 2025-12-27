import 'dart:math';
import 'package:get/get.dart';
import '../models/quiz_models.dart';
import '../models/quran_models.dart';
import 'database_service.dart';

class QuizService extends GetxService {
  static QuizService get to => Get.find();

  final _random = Random();

  /// Generate fill-in-the-blank question
  /// Removes a word from the ayah and asks user to complete it
  QuizQuestion generateFillInBlankQuestion(Ayah ayah, int questionId) {
    final words = ayah.ayahText.split(' ');
    if (words.length < 3) {
      // Too short, skip
      throw Exception('Ayah too short for fill-in-blank');
    }

    // Remove a random word (not the first or last)
    final wordIndex = _random.nextInt(words.length - 2) + 1;
    final correctWord = words[wordIndex];
    final blankedWords = List<String>.from(words);
    blankedWords[wordIndex] = '_____';

    final question = blankedWords.join(' ');

    // Generate distractors (wrong options) from nearby ayahs
    final options = [correctWord];
    // In real implementation, fetch similar words from database
    // For now, using placeholder
    options.addAll(['كلمة1', 'كلمة2', 'كلمة3']);
    options.shuffle(_random);

    return QuizQuestion(
      id: questionId,
      type: QuizType.fillInBlank,
      question: question,
      options: options,
      correctAnswer: correctWord,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      ayahText: ayah.ayahText,
    );
  }

  /// Generate multiple choice question
  /// Shows part of ayah and asks for the next word
  QuizQuestion generateMultipleChoiceQuestion(Ayah ayah, int questionId) {
    final words = ayah.ayahText.split(' ');
    if (words.length < 4) {
      throw Exception('Ayah too short for multiple choice');
    }

    // Show first half, ask for a word in second half
    final splitPoint = words.length ~/ 2;
    final questionWords = words.sublist(0, splitPoint);
    final answerIndex = splitPoint + _random.nextInt(words.length - splitPoint);
    final correctAnswer = words[answerIndex];

    final question =
        '${questionWords.join(' ')} ... ما هي الكلمة في الموضع ${answerIndex + 1}؟';

    // Generate options
    final options = [correctAnswer];
    // Add distractors from same ayah or nearby ayahs
    for (var i = 0; i < words.length && options.length < 4; i++) {
      if (i != answerIndex && !options.contains(words[i])) {
        options.add(words[i]);
      }
    }

    // Fill remaining with placeholders if needed
    while (options.length < 4) {
      options.add('خيار${options.length}');
    }

    options.shuffle(_random);

    return QuizQuestion(
      id: questionId,
      type: QuizType.multipleChoice,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      ayahText: ayah.ayahText,
    );
  }

  /// Generate ordering question
  /// Shuffles words or ayahs and asks user to order them
  QuizQuestion generateOrderingQuestion(List<Ayah> ayahs, int questionId) {
    if (ayahs.length < 2) {
      throw Exception('Need at least 2 ayahs for ordering');
    }

    // Take up to 4 ayahs
    final selectedAyahs = ayahs.take(4).toList();
    final correctOrder = selectedAyahs
        .map(
          (a) =>
              '${a.ayahNumber}: ${a.ayahText.substring(0, min(30, a.ayahText.length))}...',
        )
        .toList();

    final shuffled = List<String>.from(correctOrder)..shuffle(_random);

    return QuizQuestion(
      id: questionId,
      type: QuizType.ordering,
      question: 'رتب الآيات التالية بالترتيب الصحيح:',
      options: shuffled,
      correctAnswer: correctOrder.join('|||'),
      surahNumber: selectedAyahs.first.surahNumber,
      ayahNumber: selectedAyahs.first.ayahNumber,
      ayahText: selectedAyahs.map((a) => a.ayahText).join(' '),
    );
  }

  /// Generate a quiz with mixed question types
  Future<List<QuizQuestion>> generateQuiz({
    required int surahNumber,
    int? startAyah,
    int? endAyah,
    int questionCount = 10,
  }) async {
    try {
      // Fetch ayahs from database
      final db = DatabaseService.instance;
      final ayahsData = await db.getSurahVerses(surahNumber);

      if (ayahsData.isEmpty) {
        throw Exception('No ayahs found for surah $surahNumber');
      }

      // Convert to Ayah objects
      List<Ayah> ayahs = ayahsData;

      // Filter by range if specified
      if (startAyah != null && endAyah != null) {
        ayahs = ayahs
            .where((a) => a.ayahNumber >= startAyah && a.ayahNumber <= endAyah)
            .toList();
      }

      if (ayahs.isEmpty) {
        throw Exception('No ayahs in specified range');
      }

      final questions = <QuizQuestion>[];
      final questionTypes = [
        QuizType.fillInBlank,
        QuizType.multipleChoice,
        QuizType.ordering,
      ];

      for (var i = 0; i < questionCount && ayahs.isNotEmpty; i++) {
        final type = questionTypes[i % questionTypes.length];

        try {
          QuizQuestion question;

          switch (type) {
            case QuizType.fillInBlank:
              final ayah = ayahs[_random.nextInt(ayahs.length)];
              question = generateFillInBlankQuestion(ayah, i + 1);
              break;

            case QuizType.multipleChoice:
              final ayah = ayahs[_random.nextInt(ayahs.length)];
              question = generateMultipleChoiceQuestion(ayah, i + 1);
              break;

            case QuizType.ordering:
              final startIdx = _random.nextInt(max(1, ayahs.length - 3));
              final selectedAyahs = ayahs.sublist(
                startIdx,
                min(startIdx + 4, ayahs.length),
              );
              question = generateOrderingQuestion(selectedAyahs, i + 1);
              break;
          }

          questions.add(question);
        } catch (e) {
          // Skip this question if generation fails
          continue;
        }
      }

      return questions;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إنشاء الاختبار: $e');
      return [];
    }
  }

  /// Evaluate user's answer
  bool evaluateAnswer(QuizQuestion question, String userAnswer) {
    switch (question.type) {
      case QuizType.fillInBlank:
      case QuizType.multipleChoice:
        return userAnswer.trim() == question.correctAnswer.trim();

      case QuizType.ordering:
        return userAnswer == question.correctAnswer;
    }
  }

  /// Calculate quiz result
  QuizResult calculateResult({
    required int quizId,
    required int userId,
    required List<QuizQuestion> questions,
    required List<QuizAnswer> answers,
    required int totalTimeSeconds,
  }) {
    final correctAnswers = answers.where((a) => a.isCorrect).length;
    final wrongAnswers = answers.where((a) => !a.isCorrect).length;
    final skipped = questions.length - answers.length;

    final scorePercentage = questions.isEmpty
        ? 0.0
        : (correctAnswers / questions.length) * 100;

    return QuizResult(
      quizId: quizId,
      userId: userId,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      skippedQuestions: skipped,
      scorePercentage: scorePercentage,
      totalTimeSeconds: totalTimeSeconds,
      completedAt: DateTime.now(),
      answers: answers,
    );
  }
}
