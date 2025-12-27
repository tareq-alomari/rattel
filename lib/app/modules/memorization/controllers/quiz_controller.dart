import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/quiz_models.dart';
import '../../../data/services/quiz_service.dart';
import 'dart:async';

class QuizController extends GetxController {
  final QuizService _quizService = QuizService.to;

  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxList<QuizAnswer> answers = <QuizAnswer>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool quizCompleted = false.obs;

  // Timer
  final RxInt totalTimeSeconds = 0.obs;
  final RxInt questionTimeSeconds = 0.obs;
  Timer? _timer;
  Timer? _questionTimer;

  // User answer
  final RxString selectedAnswer = ''.obs;
  final RxList<String> orderedAnswers = <String>[].obs;

  QuizQuestion? get currentQuestion =>
      currentQuestionIndex.value < questions.length
      ? questions[currentQuestionIndex.value]
      : null;

  double get progress =>
      questions.isEmpty ? 0.0 : (currentQuestionIndex.value / questions.length);

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _questionTimer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      totalTimeSeconds.value++;
    });
  }

  void _startQuestionTimer() {
    questionTimeSeconds.value = 0;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      questionTimeSeconds.value++;
    });
  }

  Future<void> loadQuiz({
    required int surahNumber,
    int? startAyah,
    int? endAyah,
    int questionCount = 10,
  }) async {
    isLoading.value = true;
    try {
      questions.value = await _quizService.generateQuiz(
        surahNumber: surahNumber,
        startAyah: startAyah,
        endAyah: endAyah,
        questionCount: questionCount,
      );

      if (questions.isEmpty) {
        Get.snackbar('تنبيه', 'لم يتم إنشاء أسئلة');
        Get.back();
        return;
      }

      currentQuestionIndex.value = 0;
      answers.clear();
      quizCompleted.value = false;
      _startQuestionTimer();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الاختبار: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(String answer) {
    selectedAnswer.value = answer;
  }

  void submitAnswer() {
    if (currentQuestion == null) return;

    final question = currentQuestion!;
    String userAnswer;

    switch (question.type) {
      case QuizType.ordering:
        userAnswer = orderedAnswers.join('|||');
        break;
      default:
        userAnswer = selectedAnswer.value;
    }

    if (userAnswer.isEmpty && question.type != QuizType.ordering) {
      Get.snackbar('تنبيه', 'الرجاء اختيار إجابة');
      return;
    }

    final isCorrect = _quizService.evaluateAnswer(question, userAnswer);

    answers.add(
      QuizAnswer(
        questionId: question.id,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
        timeSpentSeconds: questionTimeSeconds.value,
      ),
    );

    // Show feedback
    _showAnswerFeedback(isCorrect, question.correctAnswer);

    // Move to next question after delay
    Future.delayed(const Duration(seconds: 2), () {
      nextQuestion();
    });
  }

  void _showAnswerFeedback(bool isCorrect, String correctAnswer) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                isCorrect ? 'إجابة صحيحة! 🎉' : 'إجابة خاطئة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 12),
                Text(
                  'الإجابة الصحيحة:',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  correctAnswer,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void nextQuestion() {
    Get.back(); // Close feedback dialog

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = '';
      orderedAnswers.clear();
      _startQuestionTimer();
    } else {
      completeQuiz();
    }
  }

  void skipQuestion() {
    nextQuestion();
  }

  void completeQuiz() {
    _timer?.cancel();
    _questionTimer?.cancel();
    quizCompleted.value = true;

    final result = _quizService.calculateResult(
      quizId: DateTime.now().millisecondsSinceEpoch,
      userId: 1, // Get from auth service
      questions: questions,
      answers: answers,
      totalTimeSeconds: totalTimeSeconds.value,
    );

    Get.off(() => QuizResultView(result: result));
  }
}

class QuizResultView extends StatelessWidget {
  final QuizResult result;

  const QuizResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نتيجة الاختبار')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.scorePercentage >= 70
                    ? Icons.emoji_events
                    : Icons.sentiment_neutral,
                size: 100,
                color: result.scorePercentage >= 70
                    ? Colors.amber
                    : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                result.grade,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${result.scorePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(
                Icons.check_circle,
                'إجابات صحيحة',
                '${result.correctAnswers}',
                Colors.green,
              ),
              _buildStatRow(
                Icons.cancel,
                'إجابات خاطئة',
                '${result.wrongAnswers}',
                Colors.red,
              ),
              _buildStatRow(
                Icons.skip_next,
                'أسئلة متجاوزة',
                '${result.skippedQuestions}',
                Colors.orange,
              ),
              _buildStatRow(
                Icons.timer,
                'الوقت الإجمالي',
                '${result.totalTimeSeconds ~/ 60}:${(result.totalTimeSeconds % 60).toString().padLeft(2, '0')}',
                Colors.blue,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: Text('إنهاء', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
