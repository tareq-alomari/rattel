import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

/// Loader for Azkar (Daily Remembrance) data
class AzkarDataLoader {
  static const String _isLoadedKey = 'azkar_data_loaded_v1';

  /// Check if Azkar data is loaded
  static Future<bool> isAzkarDataLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoadedKey) ?? false;
  }

  /// Load Azkar data from JSON
  static Future<void> loadAzkarData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoaded = prefs.getBool(_isLoadedKey) ?? false;

    if (isLoaded) {
      debugPrint('✅ Azkar data already loaded');
      return;
    }

    try {
      debugPrint('⏳ Loading Azkar data...');
      final db = await DatabaseHelper.instance.database;

      // Create azkar table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS azkar (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          zekr TEXT NOT NULL,
          description TEXT,
          reference TEXT,
          count TEXT
        )
      ''');

      // Load JSON
      final String jsonString = await rootBundle.loadString(
        'assets/data/Quran-App-Data/azkar.json',
      );
      final List<dynamic> azkarList = json.decode(jsonString);

      // Batch insert
      final batch = db.batch();
      for (var item in azkarList) {
        batch.insert('azkar', {
          'category': item['category'] ?? '',
          'zekr': item['zekr'] ?? '',
          'description': item['description'] ?? '',
          'reference': item['reference'] ?? '',
          'count': item['count'] ?? '1',
        });
      }

      await batch.commit(noResult: true);
      await prefs.setBool(_isLoadedKey, true);

      debugPrint('✅ Loaded ${azkarList.length} azkar successfully');
    } catch (e) {
      debugPrint('❌ Error loading Azkar data: $e');
      rethrow;
    }
  }
}

/// Loader for Allah's Names data
class AllahNamesDataLoader {
  static const String _isLoadedKey = 'allah_names_loaded_v1';

  /// Check if Allah's names are loaded
  static Future<bool> isAllahNamesLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoadedKey) ?? false;
  }

  /// Load Allah's names from JSON
  static Future<void> loadAllahNamesData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoaded = prefs.getBool(_isLoadedKey) ?? false;

    if (isLoaded) {
      debugPrint('✅ Allah names already loaded');
      return;
    }

    try {
      debugPrint('⏳ Loading Allah names...');
      final db = await DatabaseHelper.instance.database;

      // Create table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS allah_names (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          transliteration TEXT,
          number INTEGER,
          en_meaning TEXT,
          found TEXT
        )
      ''');

      // Load JSON
      final String jsonString = await rootBundle.loadString(
        'assets/data/Quran-App-Data/names_of_allah.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> namesList = jsonData['data'] as List<dynamic>;

      // Batch insert
      final batch = db.batch();
      int number = 1;
      for (var item in namesList) {
        batch.insert('allah_names', {
          'name': item['name'] ?? '',
          'transliteration': item['transliteration'] ?? '',
          'number': number++,
          'en_meaning': item['en.meaning'] ?? item['en_meaning'] ?? '',
          'found': item['found'] ?? '',
        });
      }

      await batch.commit(noResult: true);
      await prefs.setBool(_isLoadedKey, true);

      debugPrint('✅ Loaded ${namesList.length} Allah names successfully');
    } catch (e) {
      debugPrint('❌ Error loading Allah names: $e');
      rethrow;
    }
  }
}
