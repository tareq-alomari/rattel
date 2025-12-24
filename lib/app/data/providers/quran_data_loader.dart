import 'package:flutter/foundation.dart';
import 'quran_json_loader.dart';

/// Loads Quran data into the database
/// This is a wrapper around QuranJsonLoader for backward compatibility
class QuranDataLoader {
  /// Check if Quran data is already loaded
  static Future<bool> isQuranDataLoaded() async {
    return await QuranJsonLoader.isQuranDataLoaded();
  }

  /// Load Quran data from local JSON files
  static Future<void> loadQuranData({
    List<String>? languages,
    Function(String)? onProgress,
  }) async {
    try {
      debugPrint('🕌 Loading Quran data from local files...');

      // Load all data with progress callback
      await QuranJsonLoader.loadAllQuranData(
        languages: languages ?? ['en', 'id', 'ur'],
        onProgress: onProgress,
      );

      debugPrint('✅ Quran data loaded successfully!');
    } catch (e) {
      debugPrint('❌ Error loading Quran data: $e');
      rethrow;
    }
  }

  /// Load additional translation language
  static Future<void> loadTranslation(String languageCode) async {
    try {
      debugPrint('📖 Loading $languageCode translation...');
      await QuranJsonLoader.loadTranslation(languageCode);
      debugPrint('✅ $languageCode translation loaded!');
    } catch (e) {
      debugPrint('❌ Error loading $languageCode translation: $e');
      rethrow;
    }
  }

  /// Get available translation languages
  static List<String> get availableLanguages {
    return QuranJsonLoader.availableLanguages;
  }

  /// Get language name from code
  static String getLanguageName(String code) {
    return QuranJsonLoader.getLanguageName(code);
  }
}
