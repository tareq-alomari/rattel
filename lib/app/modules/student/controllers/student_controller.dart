import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../auth/controllers/auth_controller.dart';

/// Student controller for managing student dashboard and statistics
class StudentController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Observable states
  final RxInt totalVersesMemorized = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt totalBadges = 0.obs;
  final RxDouble completionPercentage = 0.0.obs;
  final RxList<Map<String, dynamic>> recentLogs = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> lastReadPosition = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool isLoading = false.obs;

  // Statistics by time period
  final RxInt versesToday = 0.obs;
  final RxInt versesThisWeek = 0.obs;
  final RxInt versesThisMonth = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  /// Load all student statistics
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      final userId = _authController.userId;

      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return;
      }

      // Load basic statistics
      final totalVerses = await _dbService.getTotalVersesMemorized(userId);
      totalVersesMemorized.value = totalVerses;

      final streak = await _dbService.getCurrentStreak(userId);
      currentStreak.value = streak;
      longestStreak.value = streak; // Simplified

      // Calculate completion percentage (out of 6236 verses)
      completionPercentage.value = (totalVersesMemorized.value / 6236 * 100);

      // Calculate badges
      totalBadges.value = await _calculateBadges();

      // Load time-based statistics
      await _loadTimeBasedStats(userId);

      // Load recent activity
      await _loadRecentLogs(userId);

      // Load last read position
      final lastRead = await _dbService.getResumePosition(userId);
      lastReadPosition.value = lastRead;

      debugPrint('✅ Statistics loaded for user $userId');
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate badges based on achievements
  Future<int> _calculateBadges() async {
    int badges = 0;

    // Verse badges
    if (totalVersesMemorized.value >= 1) badges++;
    if (totalVersesMemorized.value >= 10) badges++;
    if (totalVersesMemorized.value >= 50) badges++;
    if (totalVersesMemorized.value >= 100) badges++;

    // Streak badges
    if (currentStreak.value >= 7) badges++;
    if (currentStreak.value >= 30) badges++;

    // Completion badges
    if (completionPercentage.value >= 3.3) badges++; // First Juz
    if (completionPercentage.value >= 50) badges++; // Half Quran
    if (completionPercentage.value >= 100) badges++; // Full Quran

    return badges;
  }

  /// Load time-based statistics
  Future<void> _loadTimeBasedStats(int userId) async {
    try {
      final now = DateTime.now();

      // Today
      final todayStart = DateTime(now.year, now.month, now.day);
      versesToday.value = await _dbService.getVersesInPeriod(
        userId,
        todayStart,
        now,
      );

      // This week
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );
      versesThisWeek.value = await _dbService.getVersesInPeriod(
        userId,
        weekStartDay,
        now,
      );

      // This month
      final monthStart = DateTime(now.year, now.month, 1);
      versesThisMonth.value = await _dbService.getVersesInPeriod(
        userId,
        monthStart,
        now,
      );
    } catch (e) {
      debugPrint('❌ Error loading time-based stats: $e');
    }
  }

  /// Load recent activity logs
  Future<void> _loadRecentLogs(int userId) async {
    try {
      final logs = await _dbService.getRecentMemorizationLogs(
        userId,
        limit: 10,
      );
      recentLogs.value = logs;
    } catch (e) {
      debugPrint('❌ Error loading recent logs: $e');
    }
  }

  /// Refresh all statistics
  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get progress message based on completion
  String get progressMessage {
    if (completionPercentage.value < 10) {
      return 'keep_going'.tr;
    } else if (completionPercentage.value < 50) {
      return 'great_progress'.tr;
    } else if (completionPercentage.value < 90) {
      return 'almost_there'.tr;
    } else {
      return 'excellent_work'.tr;
    }
  }

  /// Get streak message
  String get streakMessage {
    if (currentStreak.value == 0) {
      return 'start_your_streak'.tr;
    } else if (currentStreak.value < 7) {
      return 'keep_it_up'.tr;
    } else if (currentStreak.value < 30) {
      return 'amazing_streak'.tr;
    } else {
      return 'legendary_streak'.tr;
    }
  }

  /// Check if user memorized today
  bool get hasMemorizedToday => versesToday.value > 0;

  /// Get average verses per day this week
  double get averageVersesPerDay {
    return versesThisWeek.value / 7;
  }

  /// Get weekly goal progress (assuming 50 verses per week)
  double get weeklyGoalProgress {
    return (versesThisWeek.value / 50 * 100).clamp(0, 100);
  }
}
