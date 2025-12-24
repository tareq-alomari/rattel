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
      version: 12,
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
      debugPrint('➕ Adding translations and chapters_metadata tables...');

      // Add transliteration column to quran table
      try {
        await db.execute('ALTER TABLE quran ADD COLUMN transliteration TEXT');
      } catch (e) {
        debugPrint('⚠️ transliteration column might already exist: $e');
      }

      // Create translations table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS translations (
          translation_id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          language_code TEXT NOT NULL,
          text TEXT NOT NULL,
          UNIQUE(verse_id, language_code),
          FOREIGN KEY (verse_id) REFERENCES quran(ayah_id)
        )
      ''');

      // Create chapters_metadata table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chapters_metadata (
          chapter_id INTEGER PRIMARY KEY,
          name_arabic TEXT NOT NULL,
          transliteration TEXT NOT NULL,
          translation_en TEXT NOT NULL,
          type TEXT NOT NULL,
          total_verses INTEGER NOT NULL
        )
      ''');

      // Create indexes for faster search
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_translations_verse ON translations(verse_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_translations_lang ON translations(language_code)',
      );
    }

    if (oldVersion < 8) {
      debugPrint('➕ Adding memorization_logs table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS memorization_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          surah_number INTEGER NOT NULL,
          from_ayah INTEGER NOT NULL,
          to_ayah INTEGER NOT NULL,
          type TEXT NOT NULL CHECK(type IN ('memorization', 'revision')),
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(user_id)
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_memorization_logs_user ON memorization_logs(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_memorization_logs_date ON memorization_logs(created_at)',
      );
    }

    if (oldVersion < 9) {
      debugPrint('➕ Adding duas table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS duas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          title_ar TEXT NOT NULL,
          title_en TEXT,
          dua_text TEXT NOT NULL,
          transliteration TEXT,
          translation TEXT,
          count INTEGER DEFAULT 1,
          source TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_duas_category ON duas(category)',
      );
    }

    if (oldVersion < 10) {
      debugPrint('➕ Adding azkar_logs table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS azkar_logs (
          log_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          dua_id INTEGER NOT NULL,
          count INTEGER DEFAULT 0,
          date TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(user_id),
          FOREIGN KEY (dua_id) REFERENCES duas(id),
          UNIQUE(user_id, dua_id, date)
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_azkar_logs_date ON azkar_logs(date)',
      );
    }

    if (oldVersion < 11) {
      debugPrint('➕ Adding tajweed_rules table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tajweed_rules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          examples TEXT
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tajweed_category ON tajweed_rules(category)',
      );
    }

    if (oldVersion < 12) {
      debugPrint('🔧 Fixing missing tables for v11...');
      // Ensure duas table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS duas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          title_ar TEXT NOT NULL,
          title_en TEXT,
          dua_text TEXT NOT NULL,
          transliteration TEXT,
          translation TEXT,
          count INTEGER DEFAULT 1,
          source TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_duas_category ON duas(category)',
      );

      // Ensure azkar_logs table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS azkar_logs (
          log_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          dua_id INTEGER NOT NULL,
          count INTEGER DEFAULT 0,
          date TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(user_id),
          FOREIGN KEY (dua_id) REFERENCES duas(id),
          UNIQUE(user_id, dua_id, date)
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_azkar_logs_date ON azkar_logs(date)',
      );

      // Ensure tajweed_rules table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tajweed_rules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          examples TEXT
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tajweed_category ON tajweed_rules(category)',
      );
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
        ayah_id INTEGER PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        surah_name_en TEXT NOT NULL,
        ayah_number INTEGER NOT NULL,
        ayah_text TEXT NOT NULL,
        clean_text TEXT,
        transliteration TEXT,
        page_number INTEGER,
        juz_number INTEGER
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

    // Translations table
    await db.execute('''
      CREATE TABLE translations (
        translation_id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        language_code TEXT NOT NULL,
        text TEXT NOT NULL,
        UNIQUE(verse_id, language_code),
        FOREIGN KEY (verse_id) REFERENCES quran(ayah_id)
      )
    ''');

    // Chapters metadata table
    await db.execute('''
      CREATE TABLE chapters_metadata (
        chapter_id INTEGER PRIMARY KEY,
        name_arabic TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        translation_en TEXT NOT NULL,
        type TEXT NOT NULL,
        total_verses INTEGER NOT NULL
      )
    ''');

    // Create indexes for faster search
    await db.execute(
      'CREATE INDEX idx_translations_verse ON translations(verse_id)',
    );
    await db.execute(
      'CREATE INDEX idx_translations_lang ON translations(language_code)',
    );

    // Duas table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS duas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title_ar TEXT NOT NULL,
        title_en TEXT,
        dua_text TEXT NOT NULL,
        transliteration TEXT,
        translation TEXT,
        count INTEGER DEFAULT 1,
        source TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_duas_category ON duas(category)',
    );

    // Azkar logs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS azkar_logs (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        dua_id INTEGER NOT NULL,
        count INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (dua_id) REFERENCES duas(id),
        UNIQUE(user_id, dua_id, date)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_azkar_logs_date ON azkar_logs(date)',
    );

    // Tajweed rules table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tajweed_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        examples TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tajweed_category ON tajweed_rules(category)',
    );

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
}
