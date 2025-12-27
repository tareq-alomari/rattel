import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith_book.dart';
import '../models/hadith.dart';
import 'database_helper.dart';

class SunnahDataLoader {
  static const String _isLoadedKey = 'sunnah_data_loaded_v1';

  static final Map<String, Map<String, String>> _books = {
    'bukhari.json': {
      'name': 'bukhari',
      'title_ar': 'صحيح البخاري',
      'author': 'Imam Bukhari',
    },
    'muslim.json': {
      'name': 'muslim',
      'title_ar': 'صحيح مسلم',
      'author': 'Imam Muslim',
    },
    'abi_daud.json': {
      'name': 'abi_daud',
      'title_ar': 'سنن أبي داود',
      'author': 'Imam Abu Dawood',
    },
    'trmizi.json': {
      'name': 'trmizi',
      'title_ar': 'جامع الترمذي',
      'author': 'Imam Tirmidhi',
    },
    'nasai.json': {
      'name': 'nasai',
      'title_ar': 'سنن النسائي',
      'author': 'Imam Al-Nasai',
    },
    'ibn_maja.json': {
      'name': 'ibn_majah',
      'title_ar': 'سنن ابن ماجه',
      'author': 'Imam Ibn Majah',
    },
    'malik.json': {
      'name': 'malik',
      'title_ar': 'موطأ مالك',
      'author': 'Imam Malik',
    },
    'ahmed.json': {
      'name': 'ahmed',
      'title_ar': 'مسند أحمد',
      'author': 'Imam Ahmed',
    },
    'darimi.json': {
      'name': 'darimi',
      'title_ar': 'سنن الدارمي',
      'author': 'Imam Al-Darimi',
    },
  };

  /// Loads Sunnah data from JSON files into the SQLite database.
  /// This operation is heavy and should be run in a separate isolate or with careful UI feedback.
  static Future<void> loadSunnahData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoaded = prefs.getBool(_isLoadedKey) ?? false;

    // Check if database actually has data
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM hadith_books',
    );
    final booksCount = result.isNotEmpty
        ? (result.first['count'] as int?) ?? 0
        : 0;

    if (isLoaded && booksCount > 0) {
      debugPrint('✅ Sunnah data already loaded.');
      return;
    }

    // If marked as loaded but no data, clear the flag and reload
    if (isLoaded && booksCount == 0) {
      debugPrint(
        '⚠️ Sunnah data marked as loaded but database is empty. Reloading...',
      );
      await prefs.setBool(_isLoadedKey, false);
    }

    try {
      debugPrint('⏳ Starting to load Sunnah data...');

      // Clear existing data
      await db.delete('hadiths');
      await db.delete('hadith_books');

      for (var entry in _books.entries) {
        final filename = entry.key;
        final metadata = entry.value;

        await _loadBook(db, filename, metadata);
      }

      await prefs.setBool(_isLoadedKey, true);
      debugPrint('🎉 Sunnah data loaded successfully!');

      // Notify listeners if needed (e.g. via a controller)
    } catch (e) {
      debugPrint('❌ Error loading Sunnah data: $e');
      // We do NOT set the loaded flag to true so it retries on next launch
      rethrow;
    }
  }

  static Future<void> _loadBook(
    Database db,
    String filename,
    Map<String, String> metadata,
  ) async {
    debugPrint('📖 Loading book: ${metadata['title_ar']} ($filename)...');

    // 1. Read and parse JSON
    final String jsonString = await rootBundle.loadString(
      'assets/data/Quran-App-Data/Hadith Books Json/$filename',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    // 2. Insert Book Record
    final book = HadithBook(
      name: metadata['name']!,
      titleAr: metadata['title_ar']!,
      author: metadata['author']!,
      hadithCount: jsonList.length,
    );

    // Check if book exists to avoid duplicates if partial load happened
    final existingBooks = await db.query(
      'hadith_books',
      where: 'name = ?',
      whereArgs: [book.name],
    );

    int bookId;
    if (existingBooks.isNotEmpty) {
      bookId = existingBooks.first['id'] as int;
      // Should we clear hadiths for this book? Maybe yes to be safe.
      await db.delete('hadiths', where: 'book_id = ?', whereArgs: [bookId]);
    } else {
      bookId = await db.insert('hadith_books', book.toMap());
    }

    // 3. Batch Insert Hadiths
    final batch = db.batch();

    for (var item in jsonList) {
      // Ensure fields exist and are of correct type
      final hadithNumber = item['number'] is int
          ? item['number'] as int
          : int.tryParse(item['number'].toString()) ?? 0;

      final hadith = Hadith(
        bookId: bookId,
        hadithNumber: hadithNumber,
        text: item['hadith'] ?? '',
        explanation: item['description'] ?? '',
        searchTerm: item['searchTerm'] ?? '',
      );

      batch.insert('hadiths', hadith.toMap());
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Loaded ${jsonList.length} hadiths for ${metadata['name']}');
  }
}
