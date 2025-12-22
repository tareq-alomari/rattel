import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/evaluation_model.dart';
import '../../auth/controllers/auth_controller.dart';

/// Evaluation controller
class EvaluationController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Map<String, dynamic>> pendingMemorizations =
      <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedMemorization =
      Rx<Map<String, dynamic>?>(null);
  final RxDouble score = 80.0.obs;
  final TextEditingController notesController = TextEditingController();
  final RxBool isLoading = false.obs;

  int? studentId;

  @override
  void onInit() {
    super.onInit();
    final idParam = Get.parameters['id'];
    if (idParam != null) {
      studentId = int.tryParse(idParam);
      if (studentId != null) {
        loadPendingMemorizations(studentId!);
      }
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadPendingMemorizations(int userId) async {
    try {
      isLoading.value = true;
      final results = await _dbService.getStudentPendingMemorizations(userId);
      pendingMemorizations.value = results;

      if (results.isNotEmpty) {
        selectedMemorization.value = results.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load pending activities');
    } finally {
      isLoading.value = false;
    }
  }

  void setScore(double value) {
    score.value = value;
  }

  void selectMemorization(Map<String, dynamic> mem) {
    selectedMemorization.value = mem;
  }

  Future<void> submitEvaluation() async {
    if (selectedMemorization.value == null) {
      Get.snackbar('تنبيه', 'الرجاء اختيار نشاط للتقييم');
      return;
    }

    if (studentId == null) {
      Get.snackbar('Error', 'Student ID missing');
      return;
    }

    try {
      isLoading.value = true;
      final memId = selectedMemorization.value!['mem_id'] as int;
      final currentScore = score.value;

      String status = 'needs_improvement';
      if (currentScore >= 90) {
        status = 'excellent';
      } else if (currentScore >= 70) {
        status = 'good';
      }

      final evaluation = EvaluationModel(
        memId: memId,
        teacherId: _authController.currentUser.value!.userId!,
        score: currentScore,
        notes: notesController.text.trim(),
        status: status,
        evaluatedAt: DateTime.now().toIso8601String(),
      );

      await _dbService.addEvaluation(evaluation);

      Get.back(result: true);
      Get.snackbar('تم بنجاح', 'تم إضافة التقييم بنجاح');
    } catch (e) {
      debugPrint('Error submitting evaluation: $e');
      Get.snackbar('خطأ', 'فشل حفظ التقييم');
    } finally {
      isLoading.value = false;
    }
  }
}
