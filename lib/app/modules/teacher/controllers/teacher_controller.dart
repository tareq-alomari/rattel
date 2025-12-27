import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/halaqah_service.dart';

/// Teacher controller for dashboard
class TeacherController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final DatabaseService _dbService = DatabaseService.instance;
  final HalaqahService _halaqahService = HalaqahService.to;

  final RxInt totalStudents = 0.obs;
  final RxInt halaqahCount = 0.obs;
  final RxInt points = 0.obs;
  final RxInt streakDays = 0.obs;
  final RxInt pendingEvaluations = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingSessions =
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
      errorMessage.value = '';

      // Get basic stats
      totalStudents.value = await _dbService.getStudentCount();
      pendingEvaluations.value = await _dbService.getPendingEvaluationsCount();

      // Get current teacher ID and related stats
      final currentUser = _authController.currentUser.value;
      if (currentUser != null) {
        halaqahCount.value = await _halaqahService.getTeacherHalaqahCount(
          currentUser.userId ?? 0,
        );
        points.value = currentUser.points;
        streakDays.value = await _dbService.getCurrentStreak(
          currentUser.userId ?? 0,
        );
        upcomingSessions.value = await _halaqahService
            .getTeacherUpcomingSessions(currentUser.userId ?? 0);
      }

      final activities = await _dbService.getRecentSystemActivity();
      recentActivities.value = activities;
    } catch (e) {
      debugPrint('Error loading teacher stats: $e');
      errorMessage.value = 'failed_to_load_data'
          .tr; // Ensure translation key exists or use generic
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardStats();
  }

  void logout() {
    _authController.logout();
  }
}
