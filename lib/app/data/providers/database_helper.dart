import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' show Platform;

/// SQLite database helper for Rattel app
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Initialize database factory for desktop platforms
  static void initialize() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rattel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 11,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('📦 Upgrading database from $oldVersion to $newVersion');

    if (oldVersion < 3) {
      debugPrint('🗑️ Dropping quran table...');
      await db.execute('DROP TABLE IF EXISTS quran');
      debugPrint('✨ Recreating quran table...');
      await db.execute('''
        CREATE TABLE quran (
          ayah_id INTEGER PRIMARY KEY,
          surah_number INTEGER NOT NULL,
          surah_name TEXT NOT NULL,
          surah_name_en TEXT NOT NULL,
          ayah_number INTEGER NOT NULL,
          ayah_text TEXT NOT NULL,
          clean_text TEXT,
          page_number INTEGER,
          juz_number INTEGER
        )
      ''');
    }

    if (oldVersion < 5) {
      debugPrint('⚙️ Updating settings table...');
      try {
        await db.execute(
          'ALTER TABLE settings ADD COLUMN daily_reminder_enabled INTEGER DEFAULT 1',
        );
        await db.execute(
          'ALTER TABLE settings ADD COLUMN quran_font_size REAL DEFAULT 28.0',
        );
        await db.execute(
          'ALTER TABLE settings ADD COLUMN reading_mode INTEGER DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE settings ADD COLUMN highlight_color TEXT DEFAULT "#4CAF50"',
        );
      } catch (e) {
        debugPrint(
          '⚠️ Error updating settings table (might already exist): $e',
        );
      }
    }

    if (oldVersion < 6) {
      debugPrint('➕ Adding bookmarks and resume_position tables...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          note TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(user_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS resume_position (
          user_id INTEGER PRIMARY KEY,
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(user_id)
        )
      ''');
    }

    if (oldVersion < 7) {
      debugPrint('↻ Recreating quran table with new schema (v7)...');
      await db.execute('DROP TABLE IF EXISTS quran');
      await db.execute('''
        CREATE TABLE quran (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          surah_number INTEGER,
          surah_name TEXT,
          surah_name_en TEXT,
          ayah_number INTEGER,
          ayah_text TEXT,
          clean_text TEXT,
          page_number INTEGER,
          juz_number INTEGER,
          hizb_quarter INTEGER
        )
      ''');
    }

    if (oldVersion < 8) {
      debugPrint('📅 Adding memorization_plans and daily_logs tables...');
      await db.execute('''
        CREATE TABLE memorization_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          name TEXT NOT NULL,
          start_date TEXT NOT NULL,
          target_date TEXT NOT NULL,
          start_surah INTEGER NOT NULL,
          start_ayah INTEGER NOT NULL,
          end_surah INTEGER NOT NULL,
          end_ayah INTEGER NOT NULL,
          daily_amount_pages INTEGER NOT NULL,
          status TEXT DEFAULT 'active'
        )
      ''');

      await db.execute('''
        CREATE TABLE daily_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plan_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          pages_reviewed INTEGER DEFAULT 0,
          pages_memorized INTEGER DEFAULT 0,
          rating INTEGER DEFAULT 0,
          FOREIGN KEY (plan_id) REFERENCES memorization_plans(id)
        )
      ''');
    }

    if (oldVersion < 9) {
      debugPrint('🔑 Adding user_id to memorization_plans...');
      try {
        await db.execute(
          'ALTER TABLE memorization_plans ADD COLUMN user_id INTEGER',
        );
      } catch (e) {
        debugPrint('Error adding user_id: $e');
      }
    }

    if (oldVersion < 10) {
      debugPrint('🔖 Adding bookmarks table...');
      await db.execute('DROP TABLE IF EXISTS bookmarks');
      await db.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          surah INTEGER NOT NULL,
          ayah INTEGER NOT NULL,
          page INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 11) {
      debugPrint('🕌 Adding Halaqat (Quran Circles) tables...');

      // Halaqat table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS halaqat (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          teacher_id INTEGER NOT NULL,
          schedule TEXT,
          description TEXT,
          created_at TEXT NOT NULL,
          status TEXT DEFAULT 'active',
          FOREIGN KEY (teacher_id) REFERENCES users(user_id)
        )
      ''');

      // Halaqah Students table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS halaqah_students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          halaqah_id INTEGER NOT NULL,
          student_id INTEGER NOT NULL,
          joined_at TEXT NOT NULL,
          status TEXT DEFAULT 'active',
          FOREIGN KEY (halaqah_id) REFERENCES halaqat(id),
          FOREIGN KEY (student_id) REFERENCES users(user_id),
          UNIQUE(halaqah_id, student_id)
        )
      ''');

      // Halaqah Sessions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS halaqah_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          halaqah_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          topic TEXT,
          notes TEXT,
          attended_students TEXT,
          FOREIGN KEY (halaqah_id) REFERENCES halaqat(id)
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('student', 'teacher')),
        points INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Quran table
    await db.execute('''
      CREATE TABLE quran (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER,
        surah_name TEXT,
        surah_name_en TEXT,
        ayah_number INTEGER,
        ayah_text TEXT,
        clean_text TEXT,
        page_number INTEGER,
        juz_number INTEGER,
        hizb_quarter INTEGER
      )
    ''');

    // Memorization table
    await db.execute('''
      CREATE TABLE memorization (
        mem_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        surah_number INTEGER NOT NULL,
        from_ayah INTEGER NOT NULL,
        to_ayah INTEGER NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('memorization', 'revision')),
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Evaluation table
    await db.execute('''
      CREATE TABLE evaluation (
        eval_id INTEGER PRIMARY KEY AUTOINCREMENT,
        mem_id INTEGER NOT NULL,
        teacher_id INTEGER NOT NULL,
        score REAL,
        notes TEXT,
        status TEXT CHECK(status IN ('excellent', 'good', 'needs_improvement')),
        evaluated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (mem_id) REFERENCES memorization(mem_id),
        FOREIGN KEY (teacher_id) REFERENCES users(user_id)
      )
    ''');

    // Daily activity table
    await db.execute('''
      CREATE TABLE daily_activity (
        activity_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        verses_count INTEGER DEFAULT 0,
        UNIQUE(user_id, date),
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Badges table
    await db.execute('''
      CREATE TABLE badges (
        badge_id INTEGER PRIMARY KEY AUTOINCREMENT,
        badge_name TEXT NOT NULL,
        badge_name_en TEXT NOT NULL,
        description TEXT,
        icon_path TEXT,
        criteria_type TEXT,
        criteria_value INTEGER
      )
    ''');

    // User badges table
    await db.execute('''
      CREATE TABLE user_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        badge_id INTEGER NOT NULL,
        earned_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (badge_id) REFERENCES badges(badge_id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        language TEXT DEFAULT 'ar',
        theme TEXT DEFAULT 'light',
        notifications_enabled INTEGER DEFAULT 1,
        daily_reminder_enabled INTEGER DEFAULT 1,
        quran_font_size REAL DEFAULT 28.0,
        reading_mode INTEGER DEFAULT 0,
        highlight_color TEXT DEFAULT "#4CAF50",
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Resume position (last ayah) per user
    await db.execute('''
      CREATE TABLE resume_position (
        user_id INTEGER PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Halaqat (Quran Circles) tables
    await db.execute('''
      CREATE TABLE halaqat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacher_id INTEGER NOT NULL,
        schedule TEXT,
        description TEXT,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        FOREIGN KEY (teacher_id) REFERENCES users(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE halaqah_students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        halaqah_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        joined_at TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        FOREIGN KEY (halaqah_id) REFERENCES halaqat(id),
        FOREIGN KEY (student_id) REFERENCES users(user_id),
        UNIQUE(halaqah_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE halaqah_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        halaqah_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        topic TEXT,
        notes TEXT,
        attended_students TEXT,
        FOREIGN KEY (halaqah_id) REFERENCES halaqat(id)
      )
    ''');

    // Initialize default badges
    await _initializeDefaultBadges(db);
  }

  /// Initialize default badges
  Future<void> _initializeDefaultBadges(Database db) async {
    final badges = [
      {
        'badge_name': 'حارس الفاتحة',
        'badge_name_en': 'Guardian of Al-Fatiha',
        'description': 'أتم حفظ سورة الفاتحة',
        'criteria_type': 'surah_complete',
        'criteria_value': 1,
      },
      {
        'badge_name': 'المثابر',
        'badge_name_en': 'Persistent',
        'description': 'حفظ لمدة 7 أيام متتالية',
        'criteria_type': 'streak_days',
        'criteria_value': 7,
      },
      {
        'badge_name': 'البداية',
        'badge_name_en': 'First Steps',
        'description': 'حفظ 10 آيات',
        'criteria_type': 'total_verses',
        'criteria_value': 10,
      },
      {
        'badge_name': 'المئوية',
        'badge_name_en': 'Century',
        'description': 'حفظ 100 آية',
        'criteria_type': 'total_verses',
        'criteria_value': 100,
      },
    ];

    for (var badge in badges) {
      await db.insert('badges', badge);
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  /// Delete database (for testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rattel.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // ---------------------------------------------------------------------------
  // Memorization CRUD
  // ---------------------------------------------------------------------------

  Future<int> createMemorizationRecord(Map<String, dynamic> record) async {
    final db = await instance.database;
    return await db.insert('memorization', record);
  }

  Future<int> createMemorizationPlan(Map<String, dynamic> plan) async {
    final db = await instance.database;
    return await db.insert('memorization_plans', plan);
  }

  Future<List<Map<String, dynamic>>> getMemorizationPlans() async {
    final db = await instance.database;
    return await db.query('memorization_plans', orderBy: 'id DESC');
  }

  Future<int> updateMemorizationPlan(int id, Map<String, dynamic> plan) async {
    final db = await instance.database;
    return await db.update(
      'memorization_plans',
      plan,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> logDailyActivity(Map<String, dynamic> log) async {
    final db = await instance.database;
    return await db.insert('daily_logs', log);
  }

  Future<List<Map<String, dynamic>>> getDailyLogs(int planId) async {
    final db = await instance.database;
    return await db.query(
      'daily_logs',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'date DESC',
    );
  }

  // ---------------------------------------------------------------------------
  // Evaluation CRUD
  // ---------------------------------------------------------------------------

  Future<int> createEvaluation(Map<String, dynamic> evaluation) async {
    final db = await instance.database;
    return await db.insert('evaluation', evaluation);
  }

  Future<List<Map<String, dynamic>>> getStudentEvaluations(
    int studentId,
  ) async {
    // Note: Evaluations are linked to mem_id or directly to student actions
    // For MVP phase, we might query by teacher_id or mem_id.
    // If we want all evaluations for a student, we need to join or assume logic.
    // The current schema links evaluation -> memorization(mem_id) -> user(user_id)
    // Or we will add user_id directly to evaluation for simplicity later if needed.

    // For now, let's assuming we pass the evaluation map directly.
    final db = await instance.database;
    // Join not implemented yet, simple query on table
    return await db.query('evaluation');
  }

  // ---------------------------------------------------------------------------
  // Bookmarks CRUD
  // ---------------------------------------------------------------------------

  Future<int> addBookmark(Map<String, dynamic> bookmark) async {
    final db = await instance.database;
    return await db.insert('bookmarks', bookmark);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await instance.database;
    return await db.query('bookmarks', orderBy: 'created_at DESC');
  }

  Future<int> deleteBookmark(int id) async {
    final db = await instance.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // User Management
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['student'],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'user_id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
