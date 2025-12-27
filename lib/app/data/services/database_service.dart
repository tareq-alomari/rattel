import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../providers/database_helper.dart';
import '../models/quran_models.dart';
import '../models/memorization_model.dart';
import '../models/activity_model.dart';
import '../models/badge_model.dart';
import '../models/settings_model.dart';
import '../models/evaluation_model.dart';

/// Database service for all database operations
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  // ========== QURAN OPERATIONS ==========

  /// Get all surahs with verse counts
  Future<List<SurahInfo>> getAllSurahs() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        surah_number, 
        surah_name, 
        surah_name_en, 
        COUNT(*) as verses_count
      FROM quran 
      GROUP BY surah_number 
      ORDER BY surah_number
    ''');

    return results.map((map) => SurahInfo.fromMap(map)).toList();
  }

  /// Get verses for a specific surah
  Future<List<Ayah>> getSurahVerses(int surahNumber) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'quran',
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah_number',
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Get verses for a specific page
  Future<List<Ayah>> getVersesByPage(int pageNumber) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'quran',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      orderBy: 'surah_number, ayah_number',
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Get max page number
  Future<int> getMaxPageNumber() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(page_number) as max_page FROM quran',
    );
    return (result.first['max_page'] as int?) ?? 604;
  }

  /// Get Juz start pages
  Future<List<Map<String, int>>> getJuzStartPages() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT juz_number, MIN(page_number) as start_page
      FROM quran
      GROUP BY juz_number
      ORDER BY juz_number
    ''');

    return results
        .map(
          (row) => {
            'juz': row['juz_number'] as int,
            'page': row['start_page'] as int,
          },
        )
        .toList();
  }

  /// Search Quran verses
  Future<List<Ayah>> searchQuran(String query) async {
    final db = await DatabaseHelper.instance.database;
    final cleanQuery = _cleanArabicText(query);
    final results = await db.query(
      'quran',
      where: 'clean_text LIKE ? OR ayah_text LIKE ?',
      whereArgs: ['%$cleanQuery%', '%$query%'],
      limit: 50,
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Search in specific surah
  Future<List<Ayah>> searchInSurah(int surahNumber, String query) async {
    final db = await DatabaseHelper.instance.database;
    final cleanQuery = _cleanArabicText(query);
    final results = await db.query(
      'quran',
      where: 'surah_number = ? AND (clean_text LIKE ? OR ayah_text LIKE ?)',
      whereArgs: [surahNumber, '%$cleanQuery%', '%$query%'],
      limit: 50,
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Get total Quran verse count
  Future<int> getQuranVerseCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quran');
    return result.first['count'] as int;
  }

  // ========== MEMORIZATION OPERATIONS ==========

  /// Add memorization record
  Future<int> addMemorization(MemorizationModel mem) async {
    final db = await DatabaseHelper.instance.database;
    final memId = await db.insert('memorization', {
      'user_id': mem.userId,
      'surah_number': mem.surahNumber,
      'from_ayah': mem.fromAyah,
      'to_ayah': mem.toAyah,
      'type': mem.type,
      'date': mem.date,
    });

    // Update daily activity
    await _updateDailyActivity(mem.userId, mem.date, mem.versesCount);

    return memId;
  }

  /// Get user memorizations
  Future<List<MemorizationModel>> getUserMemorizations(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'memorization',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map((map) => MemorizationModel.fromMap(map)).toList();
  }

  /// Get total verses memorized by user
  Future<int> getTotalVersesMemorized(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(to_ayah - from_ayah + 1), 0) as total
      FROM memorization
      WHERE user_id = ? AND type = 'memorization'
    ''',
      [userId],
    );

    return (result.first['total'] as int?) ?? 0;
  }

  /// Get current streak
  Future<int> getCurrentStreak(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'daily_activity',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    if (results.isEmpty) return 0;

    int streak = 0;
    DateTime? previousDate;

    for (var result in results) {
      final date = DateTime.parse(result['date'] as String);
      if (previousDate == null) {
        final today = DateTime.now();
        final diff = today.difference(date).inDays;
        if (diff > 1) break;
        streak = 1;
        previousDate = date;
      } else {
        final diff = previousDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          previousDate = date;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // ========== ACTIVITY OPERATIONS ==========

  /// Get user activities
  Future<List<ActivityModel>> getUserActivities(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'daily_activity',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 365,
    );

    return results.map((map) => ActivityModel.fromMap(map)).toList();
  }

  /// Update daily activity
  Future<void> _updateDailyActivity(
    int userId,
    String date,
    int versesCount,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final dateOnly = date.split('T')[0];

    await db.rawInsert(
      '''
      INSERT INTO daily_activity (user_id, date, verses_count)
      VALUES (?, ?, ?)
      ON CONFLICT(user_id, date) DO UPDATE SET
        verses_count = verses_count + ?
    ''',
      [userId, dateOnly, versesCount, versesCount],
    );
  }

  // ========== BADGE OPERATIONS ==========

  /// Get user badges
  Future<List<BadgeModel>> getUserBadges(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT b.*, ub.earned_at as earned_date
      FROM badges b
      LEFT JOIN user_badges ub ON b.badge_id = ub.badge_id AND ub.user_id = ?
    ''',
      [userId],
    );

    return results.map((map) => BadgeModel.fromMap(map)).toList();
  }

  /// Award badge to user
  Future<void> awardBadge(int userId, int badgeId) async {
    final db = await DatabaseHelper.instance.database;
    try {
      await db.insert('user_badges', {'user_id': userId, 'badge_id': badgeId});
    } catch (e) {
      debugPrint('Badge already awarded or error: $e');
    }
  }

  // ========== SETTINGS OPERATIONS ==========

  /// Get user settings
  Future<SettingsModel?> getUserSettings(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;
    return SettingsModel.fromMap(results.first);
  }

  /// Save user settings
  Future<void> saveUserSettings(int userId, SettingsModel settings) async {
    final db = await DatabaseHelper.instance.database;
    final map = settings.toMap();
    map.remove('setting_id');
    map['user_id'] = userId;

    await db.insert(
      'settings',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========== TEACHER OPERATIONS ==========

  /// Get all students
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT 
        u.*,
        (SELECT COUNT(*) FROM user_badges WHERE user_id = u.user_id) as badges_count,
        (SELECT MAX(date) FROM memorization WHERE user_id = u.user_id) as last_activity
      FROM users u
      WHERE u.role = 'student'
      ORDER BY u.name
    ''');
  }

  /// Get student count
  Future<int> getStudentCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM users WHERE role = 'student'",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get pending evaluations count
  Future<int> getPendingEvaluationsCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM memorization m
      WHERE NOT EXISTS (
        SELECT 1 FROM evaluation e WHERE e.mem_id = m.mem_id
      )
    ''');
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get recent system activity
  Future<List<Map<String, dynamic>>> getRecentSystemActivity() async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT m.*, u.name as student_name
      FROM memorization m
      JOIN users u ON m.user_id = u.user_id
      ORDER BY m.date DESC
      LIMIT 10
    ''');
  }

  /// Get student pending memorizations
  Future<List<Map<String, dynamic>>> getStudentPendingMemorizations(
    int userId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery(
      '''
      SELECT m.*, q.surah_name
      FROM memorization m
      LEFT JOIN quran q ON m.surah_number = q.surah_number AND q.ayah_number = 1
      WHERE m.user_id = ?
      AND NOT EXISTS (SELECT 1 FROM evaluation e WHERE e.mem_id = m.mem_id)
      ORDER BY m.date DESC
    ''',
      [userId],
    );
  }

  /// Add evaluation
  Future<int> addEvaluation(EvaluationModel eval) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('evaluation', eval.toMap());
  }

  // ========== GAMIFICATION OPERATIONS ==========

  /// Get user points
  Future<int> getUserPoints(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      columns: ['points'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return (result.first['points'] as int?) ?? 0;
    }
    return 0;
  }

  /// Add points to user
  Future<int> addPoints(int userId, int amount) async {
    final db = await DatabaseHelper.instance.database;

    // Get current points
    final currentPoints = await getUserPoints(userId);
    final newPoints = currentPoints + amount;

    await db.update(
      'users',
      {'points': newPoints},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return newPoints;
  }

  /// Get all available badges (with earned status for specific user)
  Future<List<BadgeModel>> getAllBadges(int userId) async {
    final db = await DatabaseHelper.instance.database;

    // Left join to see if user has earned them
    final results = await db.rawQuery(
      '''
      SELECT b.*, ub.earned_at as earned_date
      FROM badges b
      LEFT JOIN user_badges ub ON b.badge_id = ub.badge_id AND ub.user_id = ?
    ''',
      [userId],
    );

    return results.map((map) => BadgeModel.fromMap(map)).toList();
  }

  /// Check if user has specific badge
  Future<bool> hasBadge(int userId, int badgeId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'user_badges',
      where: 'user_id = ? AND badge_id = ?',
      whereArgs: [userId, badgeId],
    );
    return result.isNotEmpty;
  }

  // ========== HELPERS ==========

  String _cleanArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
        .replaceAll(RegExp(r'[\u0610-\u061A]'), '')
        .replaceAll('ٱ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
