import 'dart:convert';
import 'package:flutter/material.dart'; // for debugPrint
import 'package:flutter/services.dart';
import 'package:rattel/app/data/providers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class QuranDataLoader {
  static Future<bool> isQuranDataLoaded() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM quran'),
    );
    // Ensure we have all 6236 verses (or close to it)
    return count != null && count >= 6236;
  }

  static Future<void> loadQuranData() async {
    try {
      if (await isQuranDataLoaded()) {
        return;
      }

      final db = await DatabaseHelper.instance.database;
      debugPrint('Loading Quran data from assets...');

      // Clear partial data if any
      await db.delete('quran');

      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/quran-api/data/quran.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Handle the specific structure of quran-api/data/quran.json
      // It has a 'data' field which is a List of Surahs
      final List<dynamic> surahs = jsonData['data'];

      final batch = db.batch();

      for (var surah in surahs) {
        final int surahNumber = surah['number'];
        final String surahName = surah['name']['short'];
        final String surahNameEn = surah['name']['transliteration']['en'];
        final List<dynamic> verses = surah['verses'];

        for (var verse in verses) {
          final int ayahNumber = verse['number']['inSurah'];
          final String ayahText = verse['text']['arab'];
          final String cleanText = _removeDiacritics(ayahText);

          final meta = verse['meta'];
          final int pageNumber = meta['page'];
          final int juzNumber = meta['juz'];
          final int hizbQuarter = meta['hizbQuarter'];

          batch.insert('quran', {
            'surah_number': surahNumber,
            'surah_name': surahName,
            'surah_name_en': surahNameEn,
            'ayah_number': ayahNumber,
            'ayah_text': ayahText,
            'clean_text': cleanText,
            'page_number': pageNumber,
            'juz_number': juzNumber,
            'hizb_quarter': hizbQuarter,
          });
        }
      }

      await batch.commit(noResult: true);
      debugPrint('Quran data loaded successfully.');
    } catch (e) {
      debugPrint('Error loading Quran data: $e');
      rethrow;
    }
  }

  static String _removeDiacritics(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // Remove tashkeel
        .replaceAll(RegExp(r'[\u0610-\u061A]'), '') // Remove extra marks
        .replaceAll(RegExp(r'[\u06D6-\u06DC]'), '') // Remove other marks
        .replaceAll(RegExp(r'[\u06DF-\u06E8]'), '')
        .replaceAll(RegExp(r'[\u06EA-\u06ED]'), '')
        .replaceAll('ٱ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
