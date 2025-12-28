import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/memorization_controller.dart';
import '../../../data/models/memorization_models.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final MemorizationController controller = Get.find();
  late MemorizationPlan plan;
  late String type;

  // Dummy questions for MVP
  // In real app, these would come from the controller based on Quran data
  final List<QuizQuestion> questions = [
    QuizQuestion(
      questionText: 'أكمل الآية: الحمد لله رب __________',
      correctAnswer: 'العالمين',
      metadata: '{"surah": 1, "ayah": 2}',
    ),
    QuizQuestion(
      questionText: 'في أي سورة تقع آية الكرسي؟',
      correctAnswer: 'البقرة',
    ),
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    plan = args['plan'];
    type = args['type'];
  }

  void submitAnswer() {
    final question = questions[currentQuestionIndex];
    final userAnswer = answerController.text.trim();

    if (userAnswer == question.correctAnswer) {
      score++;
      question.isCorrect = true;
      Get.snackbar(
        'Correct!',
        'Well done',
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green[100],
      );
    } else {
      question.isCorrect = false;
      Get.snackbar(
        'Incorrect',
        'Correct answer: ${question.correctAnswer}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
      );
    }
    question.userAnswer = userAnswer;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answerController.clear();
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    setState(() {
      showResult = true;
    });

    final result = QuizResult(
      planId: plan.id,
      score: (score / questions.length) * 100,
      totalQuestions: questions.length,
      correctAnswers: score,
      type: type,
      createdAt: DateTime.now(),
    );

    controller.saveQuizResult(result);
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $score / ${questions.length}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${plan.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            const SizedBox(height: 24),
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Answer',
                hintText: 'Type answer here...',
              ),
              textDirection: TextDirection.rtl,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: submitAnswer,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Submit Answer', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
