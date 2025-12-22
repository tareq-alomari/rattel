import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/memorization_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/badge_model.dart';

/// Student controller for dashboard
class StudentController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthService _authService = AuthService.instance;

  final RxList<MemorizationModel> recentMemorizations = <MemorizationModel>[].obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<BadgeModel> earnedBadges = <BadgeModel>[].obs;

  int get earnedBadgesCount => earnedBadges.where((b) => b.isEarned).length;

  final RxInt totalVersesMemorized = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudentData();
  }

  /// Load all student data
  Future<void> loadStudentData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.userId;

      if (userId == null) return;

      // Load recent memorizations
      final mems = await _dbService.getUserMemorizations(userId);
      recentMemorizations.value = mems.take(5).toList();

      // Load total verses
      totalVersesMemorized.value = await _dbService.getTotalVersesMemorized(userId);

      // Load current streak
      currentStreak.value = await _dbService.getCurrentStreak(userId);

      // Load activities for heatmap
      activities.value = await _dbService.getUserActivities(userId);

      // Load earned badges
      earnedBadges.value = await _dbService.getUserBadges(userId);
    } catch (e) {
      debugPrint('Error loading student data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get activity level for a specific date
  int getActivityLevel(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    final activity = activities.firstWhereOrNull((a) => a.date == dateStr);
    return activity?.heatmapLevel ?? 0;
  }

  /// Get verses count for a specific date
  int getVersesCount(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    final activity = activities.firstWhereOrNull((a) => a.date == dateStr);
    return activity?.versesCount ?? 0;
  }
}
