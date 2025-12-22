import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';

/// Student detail controller
class StudentDetailController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxMap<String, dynamic> student = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> evaluations = <Map<String, dynamic>>[].obs;
  final RxMap<String, int> activityHeatmap = <String, int>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final idParam = Get.parameters['id'];
    if (idParam != null) {
      final studentId = int.tryParse(idParam);
      if (studentId != null) {
        loadStudentDetails(studentId);
      }
    }
  }

  Future<void> loadStudentDetails(int studentId) async {
    try {
      isLoading.value = true;

      // Load student info
      final students = await _dbService.getAllStudents();
      final studentData = students.firstWhereOrNull(
        (s) => s['user_id'] == studentId,
      );
      if (studentData != null) {
        student.value = studentData;
      }

      // Load activities for heatmap
      final activities = await _dbService.getUserActivities(studentId);
      activityHeatmap.value = {for (var a in activities) a.date: a.versesCount};
    } catch (e) {
      debugPrint('Error loading student details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
