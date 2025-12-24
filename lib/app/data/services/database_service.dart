import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../providers/database_helper.dart';
import '../models/quran_models.dart';
import '../models/memorization_model.dart';
import '../models/activity_model.dart';
import '../models/badge_model.dart';
import '../models/settings_model.dart';
import '../models/evaluation_model.dart';
import '../models/dua_model.dart';
import '../models/tajweed_model.dart';

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
        q.surah_number, 
        q.surah_name, 
        q.surah_name_en, 
        COUNT(*) as verses_count,
        COALESCE(cm.type, 'meccan') as revelation_type,
        cm.transliteration
      FROM quran q
      LEFT JOIN chapters_metadata cm ON q.surah_number = cm.chapter_id
      GROUP BY q.surah_number 
      ORDER BY q.surah_number
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

  // ========== TRANSLATION OPERATIONS ==========

  /// Get translations for a specific verse
  Future<Map<String, String>> getVerseTranslations(
    int verseId,
    List<String> languageCodes,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'translations',
      where:
          'verse_id = ? AND language_code IN (${languageCodes.map((_) => '?').join(',')})',
      whereArgs: [verseId, ...languageCodes],
    );

    final Map<String, String> translations = {};
    for (var row in results) {
      translations[row['language_code'] as String] = row['text'] as String;
    }
    return translations;
  }

  /// Get verses with translations for a specific surah
  Future<List<Ayah>> getSurahVersesWithTranslations(
    int surahNumber,
    List<String> languageCodes,
  ) async {
    final verses = await getSurahVerses(surahNumber);

    if (languageCodes.isEmpty) return verses;

    final List<Ayah> versesWithTranslations = [];
    for (var verse in verses) {
      final translations = await getVerseTranslations(
        verse.ayahId,
        languageCodes,
      );
      versesWithTranslations.add(verse.copyWithTranslations(translations));
    }

    return versesWithTranslations;
  }

  /// Search in translations
  Future<List<Ayah>> searchInTranslation(
    String query,
    String languageCode,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT q.* FROM quran q
      INNER JOIN translations t ON q.ayah_id = t.verse_id
      WHERE t.language_code = ? AND t.text LIKE ?
      LIMIT 50
    ''',
      [languageCode, '%$query%'],
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Search in multiple translations
  Future<List<Ayah>> searchInMultipleTranslations(
    String query,
    List<String> languageCodes,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final langPlaceholders = languageCodes.map((_) => '?').join(',');
    final results = await db.rawQuery(
      '''
      SELECT DISTINCT q.* FROM quran q
      INNER JOIN translations t ON q.ayah_id = t.verse_id
      WHERE t.language_code IN ($langPlaceholders) AND t.text LIKE ?
      LIMIT 50
    ''',
      [...languageCodes, '%$query%'],
    );

    return results.map((map) => Ayah.fromMap(map)).toList();
  }

  /// Get chapter metadata
  Future<ChapterMetadata?> getChapterMetadata(int chapterId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'chapters_metadata',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );

    if (results.isEmpty) return null;
    return ChapterMetadata.fromMap(results.first);
  }

  /// Get all chapters metadata
  Future<List<ChapterMetadata>> getAllChaptersMetadata() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('chapters_metadata', orderBy: 'chapter_id');

    return results.map((map) => ChapterMetadata.fromMap(map)).toList();
  }

  /// Get all surahs with metadata
  Future<List<SurahInfo>> getAllSurahsWithMetadata() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        q.surah_number,
        q.surah_name,
        q.surah_name_en,
        COUNT(*) as verses_count,
        cm.type as revelation_type,
        cm.transliteration
      FROM quran q
      LEFT JOIN chapters_metadata cm ON q.surah_number = cm.chapter_id
      GROUP BY q.surah_number
      ORDER BY q.surah_number
    ''');

    return results.map((map) => SurahInfo.fromMap(map)).toList();
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

  // ========== STATISTICS OPERATIONS ==========

  /// Get verses memorized in a specific time period
  Future<int> getVersesInPeriod(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(to_ayah - from_ayah + 1), 0) as total
        FROM memorization
        WHERE user_id = ? 
        AND date >= ? 
        AND date <= ?
        AND type = 'memorization'
      ''',
        [userId, start.toIso8601String(), end.toIso8601String()],
      );

      return (result.first['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('Error getting verses in period: $e');
      return 0;
    }
  }

  /// Get recent memorization logs
  Future<List<Map<String, dynamic>>> getRecentMemorizationLogs(
    int userId, {
    int limit = 10,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.rawQuery(
        '''
        SELECT 
          m.*,
          q.surah_name,
          q.surah_name_en
        FROM memorization m
        LEFT JOIN quran q ON m.surah_number = q.surah_number AND q.ayah_number = 1
        WHERE m.user_id = ?
        ORDER BY m.date DESC
        LIMIT ?
      ''',
        [userId, limit],
      );

      return results;
    } catch (e) {
      debugPrint('Error getting recent logs: $e');
      return [];
    }
  }

  /// Get last activity date for a user
  Future<DateTime?> getLastActivityDate(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'memorization',
        columns: ['date'],
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
        limit: 1,
      );

      if (result.isEmpty) return null;
      return DateTime.parse(result.first['date'] as String);
    } catch (e) {
      debugPrint('Error getting last activity: $e');
      return null;
    }
  }

  /// Get all evaluations with student names
  Future<List<Map<String, dynamic>>> getAllEvaluations() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.rawQuery('''
        SELECT 
          e.*,
          u.name as student_name
        FROM evaluation e
        JOIN memorization m ON e.mem_id = m.mem_id
        JOIN users u ON m.user_id = u.user_id
        ORDER BY e.evaluated_at DESC
      ''');

      return results;
    } catch (e) {
      debugPrint('Error getting all evaluations: $e');
      return [];
    }
  }

  // ========== BOOKMARK & RESUME OPERATIONS ==========

  /// Save resume position
  Future<void> saveResumePosition(
    int userId,
    int surahNumber,
    int ayahNumber,
  ) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('resume_position', {
      'user_id': userId,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get resume position
  Future<Map<String, dynamic>?> getResumePosition(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT rp.*, q.surah_name, q.surah_name_en
      FROM resume_position rp
      JOIN quran q ON rp.surah_number = q.surah_number AND q.ayah_number = 1
      WHERE rp.user_id = ?
    ''',
      [userId],
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  /// Add bookmark
  Future<int> addBookmark(
    int userId,
    int surahNumber,
    int ayahNumber, {
    String? note,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('bookmarks', {
      'user_id': userId,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get user bookmarks
  Future<List<Map<String, dynamic>>> getUserBookmarks(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT b.*, q.surah_name, q.ayah_text 
      FROM bookmarks b
      JOIN quran q ON b.surah_number = q.surah_number AND b.ayah_number = q.ayah_number
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''',
      [userId],
    );

    return results;
  }

  /// Delete bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'bookmarks',
      where: 'bookmark_id = ?',
      whereArgs: [bookmarkId],
    );
  }

  // ========== LEADERBOARD OPERATIONS ==========

  /// Get leaderboard (top students by memorized verses)
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery(
      '''
      SELECT 
        u.user_id,
        u.name,
        COALESCE(SUM(m.to_ayah - m.from_ayah + 1), 0) as total_verses,
        COUNT(DISTINCT b.badge_id) as badges_count
      FROM users u
      LEFT JOIN memorization m ON u.user_id = m.user_id AND m.type = 'memorization'
      LEFT JOIN user_badges b ON u.user_id = b.user_id
      WHERE u.role = 'student'
      GROUP BY u.user_id
      ORDER BY total_verses DESC, badges_count DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  // ========== TEST DATA SEEDING ==========

  /// Seed test data for demonstration
  Future<void> seedTestData() async {
    final db = await DatabaseHelper.instance.database;

    // Check if we already have enough students
    final count = await getStudentCount();
    if (count > 2) {
      debugPrint('⚠️ Test data likely already exists (students: $count)');
      return;
    }

    debugPrint('🌱 Seeding test data...');

    final testStudents = [
      {'name': 'أحمد محمد', 'email': 'student1@test.com'},
      {'name': 'سارة علي', 'email': 'student2@test.com'},
      {'name': 'عمر خالد', 'email': 'student3@test.com'},
      {'name': 'فاطمة حسن', 'email': 'student4@test.com'},
      {'name': 'يوسف ابراهيم', 'email': 'student5@test.com'},
      {'name': 'مريم عبدالله', 'email': 'student6@test.com'},
      {'name': 'عبدالرحمن سعيد', 'email': 'student7@test.com'},
    ];

    final random = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < testStudents.length; i++) {
      final s = testStudents[i];

      // 1. Create User
      final userId = await db.insert('users', {
        'name': s['name'],
        'email': s['email'],
        'password': 'password123', // Dummy password
        'role': 'student',
        'points': (i + 1) * 50 + (random % 100), // Random points
      });

      // 2. Add Memorization Logs (Random amount based on index to create rank diff)
      // Top students get more verses
      final versesCount = (testStudents.length - i) * 200 + (random % 50);

      // Add a bulk memorization record
      await db.insert('memorization', {
        'user_id': userId,
        'surah_number': 2, // Al-Baqarah
        'from_ayah': 1,
        'to_ayah': versesCount,
        'type': 'memorization',
        'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      });

      // 3. Award Random Badges
      if (i < 3) {
        // Top 3 get common badges
        await awardBadge(userId, 1); // First Verse
        await awardBadge(userId, 3); // 10 Verses
      }
      if (i == 0) {
        // Top 1 gets a special badge
        await awardBadge(userId, 4); // 50 Verses (or similar based on ID)
      }
    }

    debugPrint('✅ Test data seeded successfully!');
  }

  // ========== DUA & AZKAR OPERATIONS ==========

  /// Get duas by category
  Future<List<DuaModel>> getDuasByCategory(String category) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'duas',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id',
    );

    return results.map((map) => DuaModel.fromMap(map)).toList();
  }

  /// Log azkar progress
  Future<void> logAzkarProgress(int userId, int duaId, int count) async {
    final db = await DatabaseHelper.instance.database;
    final date = DateTime.now().toIso8601String().split('T')[0];

    await db.rawInsert(
      '''
      INSERT INTO azkar_logs (user_id, dua_id, count, date)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(user_id, dua_id, date) DO UPDATE SET
        count = count + ?
    ''',
      [userId, duaId, count, date, count],
    );
  }

  /// Get total azkar count for today
  Future<int> getDailyAzkarCount(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final date = DateTime.now().toIso8601String().split('T')[0];

    final result = await db.rawQuery(
      '''
      SELECT SUM(count) as total 
      FROM azkar_logs 
      WHERE user_id = ? AND date = ?
    ''',
      [userId, date],
    );

    return (result.first['total'] as int?) ?? 0;
  }

  /// Get weekly azkar stats
  Future<List<Map<String, dynamic>>> getWeeklyAzkarStats(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final startDate = weekAgo.toIso8601String().split('T')[0];

    return await db.rawQuery(
      '''
      SELECT date, SUM(count) as total
      FROM azkar_logs
      WHERE user_id = ? AND date >= ?
      GROUP BY date
      ORDER BY date ASC
    ''',
      [userId, startDate],
    );
  }

  /// Seed initial Azkar data
  Future<void> seedDuas() async {
    final db = await DatabaseHelper.instance.database;
    debugPrint('🌱 Seeding Azkar data...');

    // Morning Azkar
    final morningAzkar = [
      {
        'category': 'morning',
        'title_ar': 'آية الكرسي',
        'dua_text':
            'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'count': 1,
        'source': 'سورة البقرة: 255',
        'translation':
            'Allah! There is none worthy of worship but He, the Ever-Living, the One Who sustains and protects all that exists...',
      },
      {
        'category': 'morning',
        'title_ar': 'المعوذات',
        'dua_text':
            'قُلْ هُوَ اللَّهُ أَحَدٌ... (3 مرات)\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... (3 مرات)\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ... (3 مرات)',
        'count': 3,
        'source': 'القرآن الكريم',
        'translation': 'Surah Al-Ikhlas, Al-Falaq, An-Nas',
      },
      {
        'category': 'morning',
        'title_ar': 'أصبحنا وأصبح الملك لله',
        'dua_text':
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
        'count': 1,
        'source': 'رواه مسلم',
      },
      {
        'category': 'morning',
        'title_ar': 'اللهم بك أصبحنا',
        'dua_text':
            'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ.',
        'count': 1,
        'source': 'الترمذي',
      },
      {
        'category': 'morning',
        'title_ar': 'سيد الاستغفار',
        'dua_text':
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
        'count': 1,
        'source': 'البخاري',
      },
      {
        'category': 'morning',
        'title_ar': 'اللهم إني أصبحت أشهدك',
        'dua_text':
            'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتِكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ.',
        'count': 4,
        'source': 'أبو داود',
      },
      {
        'category': 'morning',
        'title_ar': 'ما أصبح بي من نعمة',
        'dua_text':
            'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ.',
        'count': 1,
        'source': 'أبو داود',
      },
      {
        'category': 'morning',
        'title_ar': 'اللهم عافني في بدني',
        'dua_text':
            'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ، وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ.',
        'count': 3,
        'source': 'أبو داود',
      },
      {
        'category': 'morning',
        'title_ar': 'حسبي الله',
        'dua_text':
            'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.',
        'count': 7,
        'source': 'أبو داود',
      },
      {
        'category': 'morning',
        'title_ar': 'بسم الله الذي لا يضر',
        'dua_text':
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
        'count': 3,
        'source': 'الترمذي',
      },
      {
        'category': 'morning',
        'title_ar': 'رضيت بالله ربا',
        'dua_text':
            'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا.',
        'count': 3,
        'source': 'الترمذي',
      },
      {
        'category': 'morning',
        'title_ar': 'يا حي يا قيوم',
        'dua_text':
            'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
        'count': 1,
        'source': 'الحاكم',
      },
      {
        'category': 'morning',
        'title_ar': 'سبحان الله وبحمده',
        'dua_text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
        'count': 100,
        'source': 'مسلم',
      },
    ];

    // Evening Azkar
    final eveningAzkar = [
      {
        'category': 'evening',
        'title_ar': 'آية الكرسي',
        'dua_text': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        'count': 1,
        'source': 'سورة البقرة: 255',
      },
      {
        'category': 'evening',
        'title_ar': 'المعوذات',
        'dua_text':
            'قُلْ هُوَ اللَّهُ أَحَدٌ... (3 مرات)\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... (3 مرات)\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ... (3 مرات)',
        'count': 3,
        'source': 'القرآن الكريم',
      },
      {
        'category': 'evening',
        'title_ar': 'أمسينا وأمسى الملك لله',
        'dua_text':
            'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
        'count': 1,
        'source': 'مسلم',
      },
      {
        'category': 'evening',
        'title_ar': 'اللهم بك أمسينا',
        'dua_text':
            'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ.',
        'count': 1,
        'source': 'الترمذي',
      },
      {
        'category': 'evening',
        'title_ar': 'سيد الاستغفار',
        'dua_text':
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
        'count': 1,
        'source': 'البخاري',
      },
      {
        'category': 'evening',
        'title_ar': 'اللهم إني أمسيت أشهدك',
        'dua_text':
            'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتِكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ.',
        'count': 4,
        'source': 'أبو داود',
      },
      {
        'category': 'evening',
        'title_ar': 'ما أمسى بي من نعمة',
        'dua_text':
            'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ.',
        'count': 1,
        'source': 'أبو داود',
      },
      {
        'category': 'evening',
        'title_ar': 'أعوذ بكلمات الله التامات',
        'dua_text':
            'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
        'count': 3,
        'source': 'مسلم',
      },
      {
        'category': 'evening',
        'title_ar': 'حسبي الله',
        'dua_text':
            'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.',
        'count': 7,
        'source': 'أبو داود',
      },
      {
        'category': 'evening',
        'title_ar': 'بسم الله الذي لا يضر',
        'dua_text':
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
        'count': 3,
        'source': 'الترمذي',
      },
    ];

    // Prayer Azkar
    final prayerAzkar = [
      {
        'category': 'prayer',
        'title_ar': 'الاستغفار',
        'dua_text':
            'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ.',
        'count': 3,
        'source': 'مسلم',
      },
      {
        'category': 'prayer',
        'title_ar': 'اللهم أنت السلام',
        'dua_text':
            'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.',
        'count': 1,
        'source': 'مسلم',
      },
      {
        'category': 'prayer',
        'title_ar': 'لا إله إلا الله وحده',
        'dua_text':
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ.',
        'count': 1,
        'source': 'البخاري ومسلم',
      },
      {
        'category': 'prayer',
        'title_ar': 'التسبيح',
        'dua_text': 'سُبْحَانَ اللَّهِ',
        'count': 33,
        'source': 'متفق عليه',
      },
      {
        'category': 'prayer',
        'title_ar': 'التحميد',
        'dua_text': 'الْحَمْدُ لِلَّهِ',
        'count': 33,
        'source': 'متفق عليه',
      },
      {
        'category': 'prayer',
        'title_ar': 'التكبير',
        'dua_text': 'اللَّهُ أَكْبَرُ',
        'count': 33,
        'source': 'متفق عليه',
      },
      {
        'category': 'prayer',
        'title_ar': 'تمام المئة',
        'dua_text':
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
        'count': 1,
        'source': 'مسلم',
      },
      {
        'category': 'prayer',
        'title_ar': 'آية الكرسي',
        'dua_text': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        'count': 1,
        'source': 'النسائي',
      },
    ];

    // Sleep Azkar
    final sleepAzkar = [
      {
        'category': 'sleep',
        'title_ar': 'يجمع كفيه وينفث فيهما',
        'dua_text':
            'يجمع كفيه ثم ينفث فيهما ويقرأ: قُلْ هُوَ اللَّهُ أَحَدٌ، وقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، وقُلْ أَعُوذُ بِرَبِّ النَّاسِ، ثم يمسح بهما ما استطاع من جسده...',
        'count': 3,
        'source': 'لبخاري ومسلم',
      },
      {
        'category': 'sleep',
        'title_ar': 'باسمك ربي وضعت جنبي',
        'dua_text':
            'بِاسْمِكَ رَبِّـي وَضَعْـتُ جَنْـبي، وَبِكَ أَرْفَعُـه، إِنْ أَمْسَـكْتَ نَفْسـي فَارْحَـمْها، وَإِنْ أَرْسَلْتَـها فَاحْفَـظْها بِمـا تَحْفَـظُ بِه عِبـادَكَ الصّـالِحـين.',
        'count': 1,
        'source': 'البخاري ومسلم',
      },
      {
        'category': 'sleep',
        'title_ar': 'اللهم قني عذابك',
        'dua_text': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.',
        'count': 3,
        'source': 'أبو داود',
      },
      {
        'category': 'sleep',
        'title_ar': 'باسمك اللهم أموت وأحيا',
        'dua_text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
        'count': 1,
        'source': 'البخاري',
      },
      {
        'category': 'sleep',
        'title_ar': 'آية الكرسي',
        'dua_text': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        'count': 1,
        'source': 'البخاري',
      },
    ];

    // Waking Up Azkar
    final wakingAzkar = [
      {
        'category': 'waking_up',
        'title_ar': 'الحمد لله الذي أحيانا',
        'dua_text':
            'الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.',
        'count': 1,
        'source': 'البخاري',
      },
      {
        'category': 'waking_up',
        'title_ar': 'الحمد لله الذي عافاني',
        'dua_text':
            'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ.',
        'count': 1,
        'source': 'الترمذي',
      },
      {
        'category': 'waking_up',
        'title_ar': 'لا إله إلا الله',
        'dua_text':
            'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلاَ إِلَهَ إِلاَّ اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ الْعَلِيِّ الْعَظِيمِ، رَبِّ اغْفِرْ لِي.',
        'count': 1,
        'source': 'البخاري',
      },
    ];

    // Food Azkar
    final foodAzkar = [
      {
        'category': 'food',
        'title_ar': 'قبل الطعام',
        'dua_text': 'بِسْمِ اللَّهِ.',
        'count': 1,
        'source': 'أبو داود',
      },
      {
        'category': 'food',
        'title_ar': 'إذا نسي التسمية',
        'dua_text': 'بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ.',
        'count': 1,
        'source': 'أبو داود',
      },
      {
        'category': 'food',
        'title_ar': 'بعد الطعام',
        'dua_text':
            'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ.',
        'count': 1,
        'source': 'الترمذي',
      },
      {
        'category': 'food',
        'title_ar': 'دعاء لمن أطعمك',
        'dua_text':
            'اللَّهُمَّ بَارِكْ لَهُمْ فِيمَا رَزَقْتَهُمْ، وَاغْفِرْ لَهُمْ وَارْحَمْهُمْ.',
        'count': 1,
        'source': 'مسلم',
      },
    ];

    final allAzkar = [
      ...morningAzkar,
      ...eveningAzkar,
      ...prayerAzkar,
      ...sleepAzkar,
      ...wakingAzkar,
      ...foodAzkar,
    ];

    for (var dua in allAzkar) {
      final exists = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM duas WHERE category = ? AND title_ar = ?',
          [dua['category'], dua['title_ar']],
        ),
      );

      if ((exists ?? 0) == 0) {
        await db.insert('duas', dua);
      }
    }
    debugPrint('✅ Azkar seeded successfully!');
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

  // ========== TAJWEED OPERATIONS ==========

  /// Get Tajweed rules by category
  Future<List<TajweedModel>> getTajweedRules(String category) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'tajweed_rules',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id',
    );

    return results.map((map) => TajweedModel.fromMap(map)).toList();
  }

  /// Seed Tajweed data
  Future<void> seedTajweedData() async {
    final db = await DatabaseHelper.instance.database;
    // We don't return early anymore, we check duplicates per rule
    // final count = Sqflite.firstIntValue(
    //   await db.rawQuery('SELECT COUNT(*) FROM tajweed_rules'),
    // );
    // if ((count ?? 0) > 0) return;

    debugPrint('🌱 Seeding Tajweed data...');

    final rules = [
      // Noon Saakin Types
      {
        'category': 'noon_saakin',
        'title': 'الإظهار الحلقي',
        'content':
            'هو نطق النون الساكنة أو التنوين بوضوح دون غنة إذا جاء بعدها أحد أحرف الإظهار (الهمزة، الهاء، العين، الحاء، الغين، الخاء).',
        'examples': 'مَنْ آمَنَ|عَذَابٌ أَلِيمٌ|مِنْ هَادٍ',
      },
      {
        'category': 'noon_saakin',
        'title': 'الإدغام',
        'content':
            'هو دمج النون الساكنة أو التنوين في الحرف الذي يليها. ينقسم إلى إدغام بغنة (ينمو) وإدغام بغير غنة (لر).',
        'examples': 'مَن يَقُولُ|مِن رَّبِّهِمْ|يَوْمَئِذٍ نَّاعِمَةٌ',
      },
      {
        'category': 'noon_saakin',
        'title': 'الإقلاب',
        'content':
            'هو قلب النون الساكنة أو التنوين ميماً عند الباء مع مراعاة الغنة.',
        'examples': 'مِن بَعْدِ|سَمِيعٌ بَصِيرٌ',
      },
      {
        'category': 'noon_saakin',
        'title': 'الإخفاء الحقيقي',
        'content':
            'هو نطق النون الساكنة أو التنوين بصفة بين الإظهار والإدغام مع بقاء الغنة، وذلك عند باقي الحروف.',
        'examples': 'مِن دُونِ|أَنفُسَهُمْ|رِيحاً صَرْصَراً',
      },

      // Meem Saakin
      {
        'category': 'meem_saakin',
        'title': 'الإخفاء الشفوي',
        'content': 'إذا جاءت الميم الساكنة وبعدها باء، تخفى الميم مع الغنة.',
        'examples': 'يَعْتَصِم بِاللَّهِ|تَرْمِيهِم بِحِجَارَةٍ',
      },
      {
        'category': 'meem_saakin',
        'title': 'إدغام المثلين الصغير',
        'content':
            'إذا جاءت ميم ساكنة وبعدها ميم متحركة، تدغم الميم الأولى في الثانية مع الغنة.',
        'examples': 'لَهُم مَّا يَشَاءُونَ|أَم مَّنْ',
      },
      {
        'category': 'meem_saakin',
        'title': 'الإظهار الشفوي',
        'content':
            'هو نطق الميم الساكنة بوضوح عند باقي الحروف، ويكون أشد إظهاراً عند الواو والفاء.',
        'examples': 'أَمْ لَمْ تُنذِرْهُمْ|هُمْ فِيهَا',
      },

      // Madd (Elongation)
      {
        'category': 'madd',
        'title': 'المد الطبيعي',
        'content':
            'هو ما لا تقوم ذات الحرف إلا به، ولا يتوقف على سبب، ومقداره حركتان.',
        'examples': 'قَالَ|يَقُولُ|قِيلَ',
      },
      {
        'category': 'madd',
        'title': 'المد المتصل',
        'content':
            'أن يأتي حرف المد والهمزة في كلمة واحدة. حكمه الوجوب ومقداره 4 أو 5 حركات.',
        'examples': 'السَّمَاء|جَاءَ|سِيئَتْ',
      },
      {
        'category': 'madd',
        'title': 'المد المنفصل',
        'content':
            'أن يأتي حرف المد في آخر الكلمة والهمزة في أول الكلمة التي تليها. حكمه الجواز (2، 4، 5).',
        'examples': 'يَا أَيُّهَا|فِي أَنفُسِكُمْ',
      },
      {
        'category': 'madd',
        'title': 'المد اللازم',
        'content':
            'أن يأتي بعد حرف المد سكون أصلي (ثابت وصلاً ووقفاً). يمد بمقدار 6 حركات لزوماً.',
        'examples': 'الضَّالِّينَ|الحَاقَّةُ',
      },

      // Qalqalah
      {
        'category': 'qalqalah',
        'title': 'حروف القلقلة',
        'content':
            'القلقلة هي اضطراب في مخرج الحرف عند النطق به ساكناً حتى يسمع له نبرة قوية. وحروفها خمسة مجموعة في: (قطب جد).',
        'examples': 'الفَلَقْ|مُحِيطْ|كَسَبْ',
      },
      {
        'category': 'qalqalah',
        'title': 'أنواع القلقلة',
        'content':
            '1. قلقلة صغرى: إذا كان الحرف في وسط الكلمة.\n2. قلقلة كبرى: إذا كان الحرف في آخر الكلمة موقوفاً عليه.',
        'examples': 'يَطْمَعُ|أَحَدٌ',
      },

      // Madd Rules
      {
        'category': 'madd',
        'title': 'المد الطبيعي (الأصلي)',
        'content':
            'هو الذي لا تقوم ذات الحرف إلا به، ولا يتوقف على سبب وتكون مدته حركتان. حروفه: (الألف، والواو، والياء).',
        'examples': 'قَالَ|يَقُولُ|قِيلَ',
      },
      {
        'category': 'madd',
        'title': 'المد الواجب المتصل',
        'content': 'أن يقع بعد حرف المد همز في كلمة واحدة، ويمد 4 أو 5 حركات.',
        'examples': 'جَاءَ|السَّمَاءِ|سُوءَ',
      },
      {
        'category': 'madd',
        'title': 'المد الجائز المنفصل',
        'content':
            'أن يقع حرف المد في آخر الكلمة والهمز في أول الكلمة التي تليها، ويمد 4 أو 5 حركات.',
        'examples': 'يَا أَيُّهَا|تُوبُوا إِلَى اللَّهِ',
      },
      {
        'category': 'madd',
        'title': 'المد اللازم',
        'content':
            'أن يأتي بعد حرف المد سكون أصلي وصلاً ووقفاً، ويمد 6 حركات لزوماً.',
        'examples': 'الْحَاقَّةُ|الضَّالِّينَ|آلْآنَ',
      },
      {
        'category': 'madd',
        'title': 'المد العارض للسكون',
        'content':
            'أن يأتي بعد حرف المد حرف متحرك يسكن لأجل الوقف. يجوز مده 2 أو 4 أو 6 حركات.',
        'examples': 'الْعَالَمِينَ|الرَّحِيمِ|تَعْلَمُونَ',
      },

      // Makharij Al-Huroof
      {
        'category': 'makharij',
        'title': 'الجوف',
        'content':
            'وهو الخلاء الداخل في الفم والحلق، وتخرج منه حروف المد الثلاثة (الألف، والواو، والياء).',
        'examples': 'نُوحِيهَا',
      },
      {
        'category': 'makharij',
        'title': 'الحلق',
        'content':
            'وفيه ثلاثة مخارج لستة أحرف: أقصى الحلق (الهمزة والهاء)، وسط الحلق (العين والحاء)، وأدنى الحلق (الغين والخاء).',
        'examples': 'أَعُوذُ|اهْدِنَا',
      },
      {
        'category': 'makharij',
        'title': 'اللسان',
        'content':
            'أكبر المخارج وفيه عشرة مخارج لثمانية عشر حرفاً، منها: القاف والكاف (أقصى اللسان)، والشين والياء والجيـم (وسط اللسان)، والضاد (إحدى حافتي اللسان)، واللام (أدنى حافتي اللسان)، والنون (طرف اللسان تحت مخرج اللام)، والراء (طرف اللسان مع ظهره)، والطاء والدال والتاء (طرف اللسان مع أصول الثنايا العليا)، والصاد والسين والزاي (طرف اللسان مع ما بين الثنايا العليا والسفلى)، والظاء والذال والثاء (طرف اللسان مع أطراف الثنايا العليا).',
        'examples':
            'الْحَقُّ|شَاكِرًا|الْجِبَالَ|الْأَرْضِ|الْفَضْلِ|الْقَمَرِ|الْجَنَّةِ|الصَّالِحَاتِ|الظَّالِمِينَ',
      },
      {
        'category': 'makharij',
        'title': 'الشفتان',
        'content':
            'وتخرج منهما أربعة أحرف: الفاء (من بطن الشفة السفلى مع أطراف الثنايا العليا)، والميم والباء والواو (من الشفتين معاً).',
        'examples': 'أَفْوَاجًا|رَبَّهُمْ|أَمْوَاتًا|وُجُوهٌ',
      },
      {
        'category': 'makharij',
        'title': 'الخيشوم',
        'content':
            'أقصى الأنف من الداخل، وتخرج منه صفة الغنة المصاحبة للنون والميم.',
        'examples': 'إِنَّ|أَنفُسَهُمْ',
      },

      // Sifaat Al-Huroof (Attributes)
      {
        'category': 'sifaat',
        'title': 'الهمس والجهر',
        'content':
            'الهمس: جريان النفس عند النطق بالحرف (فحثه شخص سكت). الجهر: انحباس النفس عند النطق بالحرف (باقي الحروف).',
        'examples': 'الشَّمْسُ|الصُّبْحِ|الْقَمَرُ',
      },
      {
        'category': 'sifaat',
        'title': 'الشدة والتوسط والرخاوة',
        'content':
            'الشدة: انحباس الصوت (أجد قط بكت). التوسط (البينية): اعتدال الصوت (لن عمر). الرخاوة: جريان الصوت (باقي الحروف).',
        'examples': 'الْكُبْرَى|يَعْمَلُونَ|الْفَجْرِ',
      },
      {
        'category': 'sifaat',
        'title': 'الاستعلاء والاستفال',
        'content':
            'الاستعلاء: تفخيم الصوت وارتفاع أقصى اللسان عند النطق بالحرف (خص ضغط قظ). الاستفال: ترقيق الصوت وانخفاض اللسان (باقي الحروف).',
        'examples': 'غَافِرٍ|ضَلَالٍ|الْقَارِعَةُ',
      },
      {
        'category': 'sifaat',
        'title': 'الإطباق والانفتاح',
        'content':
            'الإطباق: انحصار الصوت بين اللسان والحنك الأعلى (ص، ض، ط، ظ). الانفتاح: عدم انحصار الصوت (باقي الحروف).',
        'examples': 'الصَّادِقِينَ|الضَّالِّينَ|الطَّيِّبَاتِ',
      },
      {
        'category': 'sifaat',
        'title': 'الإذلاق والإصمات',
        'content':
            'الإذلاق: خروج الحرف بسهولة من طرف اللسان أو الشفتين (فر من لب). الإصمات: صعوبة خروج الحرف (باقي الحروف).',
        'examples': 'فَمَنْ|مِنْهُمْ|لَبِثْتُمْ',
      },
      {
        'category': 'sifaat',
        'title': 'صفات ليس لها ضد',
        'content':
            'الصفير (ص، س، ز)، القلقلة (قطب جد)، اللين (و، ي الساكنتان المفتوح ما قبلهما)، الانحراف (ل، ر)، التكرير (ر)، التفشي (ش)، الاستطالة (ض).',
        'examples':
            'الصَّافَّاتِ|الْفَلَقِ|خَوْفٍ|الْقَمَرِ|الرَّحْمَنِ|الشَّيْطَانِ|الْأَرْضِ',
      },

      // Raa Rules
      {
        'category': 'raa_rules',
        'title': 'تفخيم الراء',
        'content':
            'تفخم الراء في سبع حالات: إذا كانت مفتوحة أو مضمومة، أو ساكنة وقبلها فتح أو ضم، أو ساكنة وقبلها كسر عارض، أو ساكنة وقبلها كسر وبعدها حرف استعلاء غير مكسور في كلمة واحدة، أو ساكنة للوقف وقبلها ساكن غير الياء وقبله فتح أو ضم.',
        'examples': 'رَبُّكُمْ|رُوحُ|قِرْطَاسٍ|مِرْصَادًا|الْفَجْرِ',
      },
      {
        'category': 'raa_rules',
        'title': 'ترقيق الراء',
        'content':
            'ترقق الراء في أربع حالات: إذا كانت مكسورة، أو ساكنة وقبلها كسر أصلي وليس بعدها حرف استعلاء، أو ساكنة للوقف وقبلها ياء ساكنة، أو ساكنة للوقف وقبلها ساكن وقبله كسر.',
        'examples': 'رِجَالٌ|فِرْعَوْنَ|خَبِيرٌ|السِّحْرِ',
      },
      {
        'category': 'raa_rules',
        'title': 'جواز الوجهين في الراء',
        'content':
            'يجوز تفخيمها وترقيقها في حالتين: إذا كانت ساكنة وقبلها كسر وبعدها حرف استعلاء مكسور (في كلمة فرق)، أو إذا كانت ساكنة للوقف وقبلها حرف استعلاء ساكن وقبله كسر (في كلمات مثل مصر، القطر).',
        'examples': 'فِرْقٍ|مِصْرَ|الْقِطْرِ',
      },

      // Lam Rules (Allah)
      {
        'category': 'lam_rules',
        'title': 'لام لفظ الجلالة',
        'content': 'تفخم لام (الله) إذا سبقت بفتح أو ضم، وترقق إذا سبقت بكسر.',
        'examples': 'قَالَ اللَّهُ|عَبْدُ اللَّهِ|بِسْمِ اللَّهِ',
      },

      // Hamzat Al-Wasl
      {
        'category': 'hamzat_wasl',
        'title': 'همزة الوصل',
        'content':
            'هي همزة تثبت في ابتداء الكلام وتسقط في وصله. تكون في الأفعال (ابدأ بضم أو كسر حسب ثالث الفعل)، وفي الأسماء (ابن، ابنة، اسم، امرؤ، امرأة، اثنان، اثنتان، ايمن)، وفي الحروف (ال التعريف).',
        'examples': 'ادْعُ|اسْتَغْفِرْ|الرَّحْمَٰنُ|ابْنُ',
      },

      // Stopping Signs
      {
        'category': 'stopping',
        'title': 'الوقف اللازم (مـ)',
        'content': 'يجب الوقف عنده، ولو وصل لغير المعنى.',
        'examples':
            'إِنَّمَا يَسْتَجِيبُ الَّذِينَ يَسْمَعُونَ ۘ وَالْمَوْتَىٰ يَبْعَثُهُمُ اللَّهُ',
      },
      {
        'category': 'stopping',
        'title': 'الوقف الممنوع (لا)',
        'content': 'لا يجوز الوقف عنده إلا لضرورة، ويجب العودة لما قبله.',
        'examples':
            'الَّذِينَ تَتَوَفَّاهُمُ الْمَلَائِكَةُ طَيِّبِينَ ۙ يَقُولُونَ سَلَامٌ عَلَيْكُمُ',
      },
      {
        'category': 'stopping',
        'title': 'الوقف الجائز (ج)',
        'content': 'يجوز الوقف ويجوز الوصل، والوجهان متساويان.',
        'examples':
            'نَحْنُ نَقُصُّ عَلَيْكَ نَبَأَهُم بِالْحَقِّ ۚ إِنَّهُمْ فِتْيَةٌ',
      },
      {
        'category': 'stopping',
        'title': 'الوقف الأولى (قلى)',
        'content': 'يجوز الوصل ولكن الوقف أولى وأفضل.',
        'examples':
            'قُل رَّبِّي أَعْلَمُ بِعِدَّتِهِم مَّا يَعْلَمُهُمْ إِلَّا قَلِيلٌ ۗ فَلَا تُمَارِ',
      },
      {
        'category': 'stopping',
        'title': 'الوصل الأولى (صلى)',
        'content': 'يجوز الوقف ولكن الوصل أولى وأفضل.',
        'examples':
            'وَإِن يَمْسَسْكَ اللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُ إِلَّا هُوَ ۖ وَإِن يَمْسَسْكَ بِخَيْرٍ',
      },
    ];

    for (var rule in rules) {
      final exists = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM tajweed_rules WHERE category = ? AND title = ?',
          [rule['category'], rule['title']],
        ),
      );

      if ((exists ?? 0) == 0) {
        await db.insert('tajweed_rules', rule);
      }
    }

    debugPrint('✅ Tajweed data seeded/updated successfully!');
  }
}
