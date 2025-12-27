import '../models/memorization_models.dart';

/// Spaced Repetition Service using SM-2 Algorithm
/// Based on SuperMemo 2 algorithm for optimal review scheduling
class ReviewService {
  /// Calculate next review date based on SM-2 algorithm
  ///
  /// Parameters:
  /// - lastReviewDate: Date of last review
  /// - quality: Quality of recall (0-5)
  ///   - 0: Complete blackout
  ///   - 1: Incorrect response, but correct one remembered
  ///   - 2: Incorrect response, correct one seemed easy to recall
  ///   - 3: Correct response, but required significant difficulty
  ///   - 4: Correct response, after some hesitation
  ///   - 5: Perfect response
  /// - easinessFactor: Current easiness factor (default 2.5)
  /// - interval: Current interval in days (default 1)
  /// - repetitions: Number of consecutive correct responses
  static DateTime calculateNextReview({
    required DateTime lastReviewDate,
    required int quality,
    double easinessFactor = 2.5,
    int interval = 1,
    int repetitions = 0,
  }) {
    // Calculate new easiness factor
    double newEF =
        easinessFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ensure EF doesn't go below 1.3
    if (newEF < 1.3) newEF = 1.3;

    int newInterval;
    int newRepetitions;

    if (quality < 3) {
      // Incorrect response - restart
      newRepetitions = 0;
      newInterval = 1;
    } else {
      // Correct response
      newRepetitions = repetitions + 1;

      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (interval * newEF).round();
      }
    }

    return lastReviewDate.add(Duration(days: newInterval));
  }

  /// Get review priority score (0-100)
  /// Higher score = more urgent to review
  static int getReviewPriority({
    required DateTime nextReviewDate,
    required double easinessFactor,
    required int daysSinceLastReview,
  }) {
    final now = DateTime.now();
    final daysOverdue = now.difference(nextReviewDate).inDays;

    // Base priority on how overdue the review is
    int priority = 50;

    if (daysOverdue > 0) {
      // Overdue - increase priority
      priority += (daysOverdue * 10).clamp(0, 40);
    } else {
      // Not yet due - decrease priority
      priority -= (daysOverdue.abs() * 5).clamp(0, 30);
    }

    // Adjust based on easiness factor
    // Lower EF = harder material = higher priority
    if (easinessFactor < 2.0) {
      priority += 10;
    } else if (easinessFactor > 2.8) {
      priority -= 10;
    }

    return priority.clamp(0, 100);
  }

  /// Generate daily review list based on user's memorization history
  static List<ReviewItem> generateDailyReviewList({
    required List<DailyLog> logs,
    int maxItems = 20,
  }) {
    final now = DateTime.now();
    final reviewItems = <ReviewItem>[];

    // Group logs by plan ID
    final Map<String, List<DailyLog>> groupedLogs = {};

    for (final log in logs) {
      final key = '${log.planId}';
      groupedLogs.putIfAbsent(key, () => []).add(log);
    }

    // Calculate review priority for each group
    for (final entry in groupedLogs.entries) {
      final logList = entry.value;
      if (logList.isEmpty) continue;

      final latestLog = logList.reduce(
        (a, b) => a.date.isAfter(b.date) ? a : b,
      );

      // Calculate average rating
      final avgRating =
          logList.fold<double>(0, (sum, log) => sum + log.rating) /
          logList.length;

      // Estimate easiness factor from rating (1-5 scale to 0-5 quality)
      final quality = (avgRating - 1).round();
      final daysSince = now.difference(latestLog.date).inDays;

      // Simple interval estimation
      final interval = _estimateInterval(logList.length, avgRating);
      final nextReview = calculateNextReview(
        lastReviewDate: latestLog.date,
        quality: quality,
        interval: interval,
        repetitions: logList.length,
      );

      final priority = getReviewPriority(
        nextReviewDate: nextReview,
        easinessFactor: 1.3 + (avgRating / 5) * 1.7,
        daysSinceLastReview: daysSince,
      );

      reviewItems.add(
        ReviewItem(
          planId: latestLog.planId,
          nextReviewDate: nextReview,
          priority: priority,
          averageRating: avgRating,
          reviewCount: logList.length,
          lastReviewDate: latestLog.date,
        ),
      );
    }

    // Sort by priority (highest first) and limit to maxItems
    reviewItems.sort((a, b) => b.priority.compareTo(a.priority));
    return reviewItems.take(maxItems).toList();
  }

  static int _estimateInterval(int reviewCount, double avgRating) {
    if (reviewCount == 0) return 1;
    if (reviewCount == 1) return 1;
    if (reviewCount == 2) return 6;

    // Exponential growth based on rating
    final base = 1.3 + (avgRating / 5) * 1.7;
    return (6 * (base * (reviewCount - 2))).round();
  }
}

/// Review item for daily review list
class ReviewItem {
  final int planId;
  final DateTime nextReviewDate;
  final int priority; // 0-100
  final double averageRating;
  final int reviewCount;
  final DateTime lastReviewDate;

  ReviewItem({
    required this.planId,
    required this.nextReviewDate,
    required this.priority,
    required this.averageRating,
    required this.reviewCount,
    required this.lastReviewDate,
  });

  bool get isOverdue => DateTime.now().isAfter(nextReviewDate);

  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(nextReviewDate).inDays : 0;

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'priority': priority,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'lastReviewDate': lastReviewDate.toIso8601String(),
    };
  }
}
