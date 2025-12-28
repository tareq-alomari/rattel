import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/memorization_models.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/services/gamification_service.dart';

class MemorizationController extends GetxController {
  final RxList<MemorizationPlan> activePlans = <MemorizationPlan>[].obs;
  final RxList<QuizResult> recentQuizzes = <QuizResult>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
    loadRecentQuizzes();
  }

  Future<void> loadRecentQuizzes() async {
    // Placeholder for loading quizzes from DB
    // recentQuizzes.value = await DatabaseHelper.instance.getRecentQuizzes();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    try {
      final plansData = await DatabaseHelper.instance.getMemorizationPlans();
      activePlans.value = plansData
          .map((data) => MemorizationPlan.fromMap(data))
          .where((p) => p.status == 'active')
          .toList();
    } catch (e) {
      debugPrint('Error loading plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlan(MemorizationPlan plan) async {
    try {
      await DatabaseHelper.instance.createMemorizationPlan(plan.toMap());
      await loadPlans();
      Get.back(); // Close dialog/screen
      Get.snackbar('Success', 'Memorization plan created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create plan: $e');
    }
  }

  // Calculate daily target (simple logic for now)
  String getDailyTarget(MemorizationPlan plan) {
    return "${plan.dailyAmountPages} Pages";
  }

  Future<void> logProgress(int planId, int pages, int rating) async {
    try {
      await DatabaseHelper.instance.logDailyActivity({
        'plan_id': planId,
        'date': DateTime.now().toIso8601String(),
        'pages_memorized': pages,
        'pages_reviewed': 0, // Separate or combined logic
        'rating': rating,
      });

      // Award points: 10 points per page
      final points = pages * 10;
      if (Get.isRegistered<GamificationService>()) {
        GamificationService.to.awardPoints(
          amount: points,
          reason: 'Memorized $pages page(s)',
        );
      }

      Get.snackbar('Success', 'Progress recorded!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log progress: $e');
    }
  }

  // Quiz Logic
  void startQuiz(int planId, String type) {
    // Navigate to Quiz View with generated questions
    // For now, we'll generate dummy questions based on the plan's range
    final plan = activePlans.firstWhere((p) => p.id == planId);

    // Logic to generate questions would go here
    // For MVP, passing dummy data
    Get.toNamed('/memorization/quiz', arguments: {'plan': plan, 'type': type});
  }

  Future<void> saveQuizResult(QuizResult result) async {
    try {
      // await DatabaseHelper.instance.createQuizResult(result.toMap());
      // recentQuizzes.add(result);
      Get.back();
      Get.snackbar('Success', 'Quiz completed! Score: ${result.score}%');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save quiz: $e');
    }
  }
}
