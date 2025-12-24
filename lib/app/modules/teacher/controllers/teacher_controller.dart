import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

/// Teacher controller for managing students and evaluations
class TeacherController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Observable states
  final RxList<UserModel> students = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> recentEvaluations =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentActivity =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Statistics
  final RxInt totalStudents = 0.obs;
  final RxInt activeStudents = 0.obs;
  final RxInt totalEvaluations = 0.obs;
  final RxInt pendingEvaluations = 0.obs;
  final RxDouble averageScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
  }

  /// Load all teacher data
  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      final teacherId = _authController.userId;

      if (teacherId == null) {
        debugPrint('⚠️ No teacher logged in');
        return;
      }

      // Load students
      await _loadStudents();

      // Load evaluations
      await _loadEvaluations();

      // Load recent activity
      await _loadRecentActivity();

      debugPrint('✅ Teacher data loaded');
    } catch (e) {
      debugPrint('❌ Error loading teacher data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all students and calculate active students
  Future<void> _loadStudents() async {
    try {
      final allStudentsData = await _dbService.getAllStudents();
      totalStudents.value = allStudentsData.length;

      // Populate students list
      students.value = allStudentsData
          .map((data) => UserModel.fromMap(data))
          .toList();

      // Calculate active students (active in last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      int activeCount = 0;

      for (var student in allStudentsData) {
        final studentId = student['user_id'] as int; // Correct key
        final lastActivity = await _dbService.getLastActivityDate(studentId);
        if (lastActivity != null && lastActivity.isAfter(weekAgo)) {
          activeCount++;
        }
      }

      activeStudents.value = activeCount;
    } catch (e) {
      debugPrint('❌ Error loading students: $e');
    }
  }

  /// Load evaluations and calculate statistics
  Future<void> _loadEvaluations() async {
    try {
      final allEvals = await _dbService.getAllEvaluations();
      totalEvaluations.value = allEvals.length;

      // Get recent evaluations (last 5)
      recentEvaluations.value = allEvals.take(5).toList();

      // Calculate average score
      if (allEvals.isNotEmpty) {
        final totalScore = allEvals.fold<double>(
          0,
          (sum, e) => sum + ((e['score'] as num?)?.toDouble() ?? 0),
        );
        averageScore.value = totalScore / allEvals.length;
      } else {
        averageScore.value = 0.0;
      }

      // Count pending evaluations (score = 0 or null)
      pendingEvaluations.value = await _dbService.getPendingEvaluationsCount();
    } catch (e) {
      debugPrint('❌ Error loading evaluations: $e');
    }
  }

  /// Load recent system activity
  Future<void> _loadRecentActivity() async {
    try {
      final activity = await _dbService.getRecentSystemActivity();
      recentActivity.value = activity;
    } catch (e) {
      debugPrint('❌ Error loading recent activity: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadDashboardStats();
  }

  /// Get performance summary
  String get performanceSummary {
    return 'welcome_message'.tr;
  }

  /// Get activity rate
  double get activityRate {
    if (totalStudents.value == 0) return 0.0;
    return (activeStudents.value / totalStudents.value) * 100;
  }

  /// Logout
  void logout() {
    _authController.logout();
  }
}
