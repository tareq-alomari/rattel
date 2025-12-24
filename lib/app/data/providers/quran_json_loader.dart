import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../models/quran_models.dart';
import 'database_helper.dart';

/// Loads Quran data from local quran-json files
class QuranJsonLoader {
  /// Available translation languages
  static const List<String> availableLanguages = [
    'en', // English
    'id', // Indonesian
    'ur', // Urdu
    'bn', // Bengali
    'zh', // Chinese
    'es', // Spanish
    'fr', // French
    'ru', // Russian
    'sv', // Swedish
    'tr', // Turkish
  ];

  /// Check if Quran data is already loaded
  static Future<bool> isQuranDataLoaded() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quran');
    final count = result.first['count'] as int;
    return count >= 6236; // Should have exactly 6236 verses
  }

  /// Check if translations are loaded
  static Future<bool> areTranslationsLoaded() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM translations',
    );
    final count = result.first['count'] as int;
    return count > 0;
  }

  /// Load all Quran data (text, translations, metadata)
  static Future<void> loadAllQuranData({
    List<String>? languages,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Loading chapter metadata...');
      await loadChapterMetadata();

      onProgress?.call('Loading Arabic text...');
      await loadArabicText();

      onProgress?.call('Loading transliteration...');
      await loadTransliteration();

      // Load translations for specified languages
      final langsToLoad = languages ?? ['en', 'id', 'ur'];
      for (var lang in langsToLoad) {
        onProgress?.call('Loading $lang translation...');
        await loadTranslation(lang);
      }

      debugPrint('✅ All Quran data loaded successfully!');
    } catch (e) {
      debugPrint('❌ Error loading Quran data: $e');
      rethrow;
    }
  }

  /// Load chapter metadata from chapters/en.json
  static Future<void> loadChapterMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran-json/data/chapters/en.json',
      );
      final List<dynamic> chapters = json.decode(jsonString);

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      for (var chapter in chapters) {
        final metadata = ChapterMetadata.fromJson(chapter);
        batch.insert(
          'chapters_metadata',
          metadata.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      debugPrint('✅ Loaded ${chapters.length} chapter metadata');
    } catch (e) {
      debugPrint('❌ Error loading chapter metadata: $e');
      rethrow;
    }
  }

  /// Load Arabic text from quran.json
  static Future<void> loadArabicText() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran-json/data/quran.json',
      );
      final Map<String, dynamic> quranData = json.decode(jsonString);

      final db = await DatabaseHelper.instance.database;

      // Get chapter metadata for names
      final chaptersResult = await db.query('chapters_metadata');
      final Map<int, ChapterMetadata> chaptersMap = {};
      for (var row in chaptersResult) {
        final metadata = ChapterMetadata.fromMap(row);
        chaptersMap[metadata.id] = metadata;
      }

      // Clear existing Quran data
      await db.delete('quran');

      int ayahId = 1;
      final batch = db.batch();

      // Parse and insert verses
      for (var chapterEntry in quranData.entries) {
        final chapterNumber = int.parse(chapterEntry.key);
        final verses = chapterEntry.value as List<dynamic>;
        final chapterMeta = chaptersMap[chapterNumber];

        for (var verseData in verses) {
          final verse = verseData as Map<String, dynamic>;
          final verseNumber = verse['verse'] as int;
          final text = verse['text'] as String;

          batch.insert('quran', {
            'ayah_id': ayahId,
            'surah_number': chapterNumber,
            'surah_name': chapterMeta?.nameArabic ?? 'سورة $chapterNumber',
            'surah_name_en':
                chapterMeta?.translationEn ?? 'Chapter $chapterNumber',
            'ayah_number': verseNumber,
            'ayah_text': text,
            'clean_text': _cleanArabicText(text),
            'page_number': null, // Not available in quran-json
            'juz_number': null, // Not available in quran-json
          });

          ayahId++;
        }
      }

      await batch.commit(noResult: true);
      debugPrint('✅ Loaded ${ayahId - 1} Arabic verses');
    } catch (e) {
      debugPrint('❌ Error loading Arabic text: $e');
      rethrow;
    }
  }

  /// Load transliteration from editions/transliteration.json
  static Future<void> loadTransliteration() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran-json/data/editions/transliteration.json',
      );
      final Map<String, dynamic> translitData = json.decode(jsonString);

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      int ayahId = 1;

      for (var chapterEntry in translitData.entries) {
        final verses = chapterEntry.value as List<dynamic>;

        for (var verseData in verses) {
          final verse = verseData as Map<String, dynamic>;
          final text = verse['text'] as String;

          batch.update(
            'quran',
            {'transliteration': text},
            where: 'ayah_id = ?',
            whereArgs: [ayahId],
          );

          ayahId++;
        }
      }

      await batch.commit(noResult: true);
      debugPrint('✅ Loaded transliteration for ${ayahId - 1} verses');
    } catch (e) {
      debugPrint('❌ Error loading transliteration: $e');
      rethrow;
    }
  }

  /// Load translation for a specific language
  static Future<void> loadTranslation(String languageCode) async {
    if (!availableLanguages.contains(languageCode)) {
      debugPrint('⚠️ Language $languageCode not available');
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran-json/data/editions/$languageCode.json',
      );
      final Map<String, dynamic> translationData = json.decode(jsonString);

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      int ayahId = 1;

      for (var chapterEntry in translationData.entries) {
        final verses = chapterEntry.value as List<dynamic>;

        for (var verseData in verses) {
          final verse = verseData as Map<String, dynamic>;
          final text = verse['text'] as String;

          batch.insert('translations', {
            'verse_id': ayahId,
            'language_code': languageCode,
            'text': text,
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          ayahId++;
        }
      }

      await batch.commit(noResult: true);
      debugPrint('✅ Loaded $languageCode translation for ${ayahId - 1} verses');
    } catch (e) {
      debugPrint('❌ Error loading $languageCode translation: $e');
      rethrow;
    }
  }

  /// Remove diacritics from Arabic text for search
  static String _cleanArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // Remove tashkeel
        .replaceAll(RegExp(r'[\u0610-\u061A]'), '') // Remove extra marks
        .replaceAll('ٱ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  /// Get language name from code
  static String getLanguageName(String code) {
    const Map<String, String> languageNames = {
      'en': 'English',
      'id': 'Indonesian',
      'ur': 'Urdu',
      'bn': 'Bengali',
      'zh': 'Chinese',
      'es': 'Spanish',
      'fr': 'French',
      'ru': 'Russian',
      'sv': 'Swedish',
      'tr': 'Turkish',
    };
    return languageNames[code] ?? code.toUpperCase();
  }
}
