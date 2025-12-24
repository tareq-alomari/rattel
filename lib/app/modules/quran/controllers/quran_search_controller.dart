import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/quran_models.dart';

/// Search controller for Quran search functionality
class QuranSearchController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxString searchQuery = ''.obs;
  final RxList<Ayah> searchResults = <Ayah>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchMode = 'arabic'.obs; // 'arabic', 'translation', 'all'
  final RxString selectedLanguage = 'en'.obs;
  final RxInt filterSurah = 0.obs; // 0 = all surahs
  final RxList<String> searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }

  /// Load search history from preferences
  Future<void> _loadSearchHistory() async {
    // TODO: Load from SharedPreferences
    searchHistory.value = [];
  }

  /// Save search to history
  Future<void> _saveToHistory(String query) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    searchHistory.remove(query);
    // Add to beginning
    searchHistory.insert(0, query);
    // Keep only last 10
    if (searchHistory.length > 10) {
      searchHistory.removeRange(10, searchHistory.length);
    }

    // TODO: Save to SharedPreferences
  }

  /// Clear search history
  void clearHistory() {
    searchHistory.clear();
    // TODO: Clear from SharedPreferences
  }

  /// Search in Quran
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      searchQuery.value = query;

      List<Ayah> results = [];

      switch (searchMode.value) {
        case 'arabic':
          results = await _searchArabic(query);
          break;
        case 'translation':
          results = await _searchTranslation(query);
          break;
        case 'all':
          results = await _searchAll(query);
          break;
      }

      // Apply surah filter if set
      if (filterSurah.value > 0) {
        results = results
            .where((ayah) => ayah.surahNumber == filterSurah.value)
            .toList();
      }

      searchResults.value = results;
      await _saveToHistory(query);
    } catch (e) {
      debugPrint('Error searching: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Search in Arabic text
  Future<List<Ayah>> _searchArabic(String query) async {
    if (filterSurah.value > 0) {
      return await _dbService.searchInSurah(filterSurah.value, query);
    }
    return await _dbService.searchQuran(query);
  }

  /// Search in translation
  Future<List<Ayah>> _searchTranslation(String query) async {
    return await _dbService.searchInTranslation(query, selectedLanguage.value);
  }

  /// Search in both Arabic and translations
  Future<List<Ayah>> _searchAll(String query) async {
    final arabicResults = await _searchArabic(query);
    final translationResults = await _searchTranslation(query);

    // Combine and remove duplicates
    final Map<int, Ayah> uniqueResults = {};
    for (var ayah in arabicResults) {
      uniqueResults[ayah.ayahId] = ayah;
    }
    for (var ayah in translationResults) {
      uniqueResults[ayah.ayahId] = ayah;
    }

    return uniqueResults.values.toList();
  }

  /// Change search mode
  void changeSearchMode(String mode) {
    searchMode.value = mode;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  /// Change selected language for translation search
  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    if (searchMode.value == 'translation' && searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  /// Set surah filter
  void setSurahFilter(int surahNumber) {
    filterSurah.value = surahNumber;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  /// Get result count text
  String getResultCountText() {
    if (searchResults.isEmpty) {
      return 'No results found';
    }
    return '${searchResults.length} result${searchResults.length > 1 ? 's' : ''} found';
  }
}
