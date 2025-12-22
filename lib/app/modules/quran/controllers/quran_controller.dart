import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/quran_models.dart';

/// Quran controller for surah and ayah management
class QuranController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<SurahInfo> surahs = <SurahInfo>[].obs;
  final RxList<Ayah> currentSurahVerses = <Ayah>[].obs;
  final RxInt currentSurahNumber = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSurahs();
  }

  /// Load all surahs
  Future<void> loadSurahs() async {
    try {
      isLoading.value = true;
      surahs.value = await _dbService.getAllSurahs();
    } catch (e) {
      debugPrint('Error loading surahs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load verses for a specific surah
  Future<void> loadSurahVerses(int surahNumber) async {
    try {
      isLoading.value = true;
      currentSurahNumber.value = surahNumber;
      currentSurahVerses.value = await _dbService.getSurahVerses(surahNumber);
    } catch (e) {
      debugPrint('Error loading surah verses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get surah name by number
  String getSurahName(int surahNumber) {
    final surah = surahs.firstWhereOrNull((s) => s.surahNumber == surahNumber);
    return surah?.surahName ?? 'سورة $surahNumber';
  }
}
