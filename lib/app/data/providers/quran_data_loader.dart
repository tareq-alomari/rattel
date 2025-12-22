import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';

/// Loads Quran data into the database
class QuranDataLoader {
  static const String quranJsonUrl =
      'https://raw.githubusercontent.com/semarketir/quranjson/master/source/quran.json';

  /// Check if Quran data is already loaded
  static Future<bool> isQuranDataLoaded() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quran');
    final count = result.first['count'] as int;
    return count > 100; // Should have 6236 verses
  }

  /// Load Quran data from remote JSON
  static Future<void> loadQuranData() async {
    try {
      debugPrint('🕌 Fetching Quran data from API...');
      final response = await http.get(Uri.parse(quranJsonUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        await _insertQuranData(jsonData);
        debugPrint('✅ Quran data loaded successfully!');
      } else {
        debugPrint('❌ Failed to fetch Quran data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error loading Quran data from network: $e');

      // Try to load from bundled asset as a fallback
      try {
        debugPrint('📦 Attempting to load Quran data from local asset...');
        final assetString = await rootBundle.loadString('assets/data/quran.json');
        final jsonData = json.decode(assetString) as Map<String, dynamic>;
        await _insertQuranData(jsonData);
        debugPrint('✅ Quran data loaded from local asset successfully!');
        return;
      } catch (assetErr) {
        debugPrint('❌ Failed to load Quran data from local asset: $assetErr');
      }

      debugPrint('❌ Error loading Quran data: $e');
    }
  }

  /// Insert parsed Quran data into database
  static Future<void> _insertQuranData(Map<String, dynamic> jsonData) async {
    final db = await DatabaseHelper.instance.database;

    // Clear existing data
    await db.delete('quran');

    int ayahId = 1;
    final batch = db.batch();

    for (var surahEntry in jsonData.entries) {
      final surahNumber = int.parse(surahEntry.key);
      final surahData = surahEntry.value as List<dynamic>;

      String surahName = '';
      String surahNameEn = '';

      for (var ayah in surahData) {
        final ayahData = ayah as Map<String, dynamic>;
        surahName = ayahData['surah_name'] ?? 'سورة $surahNumber';
        surahNameEn = ayahData['surah_name_en'] ?? 'Surah $surahNumber';

        batch.insert('quran', {
          'ayah_id': ayahId,
          'surah_number': surahNumber,
          'surah_name': surahName,
          'surah_name_en': surahNameEn,
          'ayah_number': ayahData['aya_number'] ?? ayahId,
          'ayah_text': ayahData['aya_text'] ?? '',
          'clean_text': _cleanArabicText(ayahData['aya_text'] ?? ''),
          'page_number': ayahData['page'] ?? 1,
          'juz_number': ayahData['juz'] ?? 1,
        });

        ayahId++;
      }
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Inserted ${ayahId - 1} verses into database');
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
}
