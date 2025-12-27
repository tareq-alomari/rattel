import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EvaluationController extends GetxController {
  final isLoading = false.obs;
  final score = 10.0.obs;
  final notesController = TextEditingController();
  final pendingMemorizations = <Map<String, dynamic>>[].obs; // Mock data

  @override
  void onInit() {
    super.onInit();
    loadPendingEvaluations();
  }

  void loadPendingEvaluations() {
    // Mock data for UI demonstration
    pendingMemorizations.value = [
      {'studentId': 1, 'name': 'Ahmed', 'surah': 'Al-Fatiha', 'date': 'Today'},
      {
        'studentId': 2,
        'name': 'Sarah',
        'surah': 'Al-Baqarah (1-5)',
        'date': 'Yesterday',
      },
    ];
  }

  void setScore(double value) {
    score.value = value;
  }

  Future<void> submitEvaluation({
    required int studentId,
    required double score,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      // Simulate API/DB call
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, we would insert an evaluation record here
      // final db = DatabaseHelper.instance;
      // await db.createEvaluation(...);

      // Remove from pending list
      pendingMemorizations.removeWhere((m) => m['studentId'] == studentId);

      Get.back(); // Close dialog or screen
      Get.snackbar('Success', 'Evaluation submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit evaluation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
