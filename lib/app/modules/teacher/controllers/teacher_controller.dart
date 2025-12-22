import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/database_service.dart';

/// Teacher controller for dashboard
class TeacherController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final DatabaseService _dbService = DatabaseService.instance;

  final RxInt totalStudents = 0.obs;
  final RxInt pendingEvaluations = 0.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;

      totalStudents.value = await _dbService.getStudentCount();
      final activities = await _dbService.getRecentSystemActivity();
      recentActivities.value = activities;
      pendingEvaluations.value = await _dbService.getPendingEvaluationsCount();
    } catch (e) {
      debugPrint('Error loading teacher stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authController.logout();
  }
}
