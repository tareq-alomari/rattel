import 'package:flutter/foundation.dart';
import '../providers/database_helper.dart';

/// Badge service for gamification
class BadgeService {
  static final BadgeService instance = BadgeService._init();
  BadgeService._init();

  /// Initialize default badges
  Future<void> initializeBadges() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM badges');
      final count = result.first['count'] as int;

      if (count == 0) {
        debugPrint('🏆 Initializing default badges...');
        // Badges are initialized in DatabaseHelper._initializeDefaultBadges
      }
    } catch (e) {
      debugPrint('Error initializing badges: $e');
    }
  }

  /// Check and award badges based on user progress
  Future<void> checkAndAwardBadges(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Get user stats
      final totalVersesResult = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(to_ayah - from_ayah + 1), 0) as total
        FROM memorization WHERE user_id = ? AND type = 'memorization'
      ''',
        [userId],
      );
      final totalVerses = (totalVersesResult.first['total'] as int?) ?? 0;

      // Get all badges
      final badges = await db.query('badges');

      for (var badge in badges) {
        final badgeId = badge['badge_id'] as int;
        final criteriaType = badge['criteria_type'] as String?;
        final criteriaValue = badge['criteria_value'] as int?;

        // Check if already earned
        final existing = await db.query(
          'user_badges',
          where: 'user_id = ? AND badge_id = ?',
          whereArgs: [userId, badgeId],
        );
        if (existing.isNotEmpty) continue;

        // Check criteria
        bool shouldAward = false;

        if (criteriaType == 'total_verses' && criteriaValue != null) {
          shouldAward = totalVerses >= criteriaValue;
        }

        if (shouldAward) {
          await db.insert('user_badges', {
            'user_id': userId,
            'badge_id': badgeId,
          });
          debugPrint('🏆 Awarded badge $badgeId to user $userId');
        }
      }
    } catch (e) {
      debugPrint('Error checking badges: $e');
    }
  }
}
