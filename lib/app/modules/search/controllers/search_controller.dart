import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/quran_models.dart';
import '../../quran/views/quran_reader_view.dart';

/// Controller for Quran search
class SearchController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<Ayah> searchResults = <Ayah>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedSurah = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search
    debounce(
      searchQuery,
      (query) => _performSearch(query),
      time: const Duration(milliseconds: 500),
    );
  }

  /// Search Quran verses (updates query to trigger debounce)
  void searchQuran(String query) {
    searchQuery.value = query;
  }

  /// Internal search execution
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      List<Ayah> results;
      if (selectedSurah.value == 0) {
        results = await _dbService.searchQuran(query);
      } else {
        results = await _dbService.searchInSurah(selectedSurah.value, query);
      }
      searchResults.value = results;
    } catch (e) {
      debugPrint('Error searching Quran: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear search
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
  }

  /// Navigate to verse in Quran reader
  void navigateToVerse(int surahNumber, int ayahNumber) {
    Get.to(
      () => QuranReaderView(
        surahNumber: surahNumber,
        initialAyahNumber: ayahNumber,
      ),
      transition: Transition.cupertino,
    );
  }

  /// Change surah filter
  void changeSurahFilter(int surahNumber) {
    selectedSurah.value = surahNumber;
    if (searchQuery.value.isNotEmpty) {
      searchQuran(searchQuery.value);
    }
  }
}
