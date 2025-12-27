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

  final RxList<MemorizationModel> recentMemorizations =
      <MemorizationModel>[].obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<BadgeModel> earnedBadges = <BadgeModel>[].obs;

  int get earnedBadgesCount => earnedBadges.where((b) => b.isEarned).length;

  final RxInt totalVersesMemorized = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalPoints = 250.obs; // Total gamification points
  final RxInt reviewedPages = 25.obs; // Pages reviewed
  final RxInt pagesMemorized = 12.obs; // Pages memorized
  final RxInt pagesReviewed = 25.obs; // Pages reviewed
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

      if (userId == null) {
        // Set default values if no user
        totalPoints.value = 0;
        pagesMemorized.value = 0;
        pagesReviewed.value = 0;
        currentStreak.value = 0;
        return;
      }

      // Load recent memorizations
      final mems = await _dbService.getUserMemorizations(userId);
      recentMemorizations.value = mems.take(5).toList();

      // Load total verses
      totalVersesMemorized.value = await _dbService.getTotalVersesMemorized(
        userId,
      );

      // Calculate pages memorized (assuming 20 verses per page average)
      pagesMemorized.value = (totalVersesMemorized.value / 20).ceil();

      // Load current streak
      currentStreak.value = await _dbService.getCurrentStreak(userId);

      // Load activities for heatmap
      activities.value = await _dbService.getUserActivities(userId);

      // Load earned badges
      earnedBadges.value = await _dbService.getUserBadges(userId);

      // Calculate total points from activities and badges
      int activityPoints = activities.fold(
        0,
        (sum, activity) => sum + (activity.versesCount * 10),
      );
      int badgePoints = earnedBadges.where((b) => b.isEarned).length * 50;
      totalPoints.value = activityPoints + badgePoints;

      // Calculate pages reviewed from activities
      int totalReviewedVerses = activities.fold(0, (sum, activity) {
        // Assuming review activities are marked differently
        return sum + activity.versesCount;
      });
      pagesReviewed.value = (totalReviewedVerses / 20).ceil();

      debugPrint(
        '✅ Student data loaded: Points=${totalPoints.value}, Pages=${pagesMemorized.value}',
      );
    } catch (e) {
      debugPrint('❌ Error loading student data: $e');
      // Set default values on error
      totalPoints.value = 0;
      pagesMemorized.value = 0;
      pagesReviewed.value = 0;
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
