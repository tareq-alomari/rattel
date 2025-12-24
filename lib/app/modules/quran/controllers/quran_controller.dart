import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/quran_models.dart';
import '../../../data/models/quran_settings_model.dart';
import '../../../data/providers/quran_data_loader.dart';

/// Quran controller for surah and ayah management with translation support
class QuranController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<SurahInfo> surahs = <SurahInfo>[].obs;
  final RxList<Ayah> currentSurahVerses = <Ayah>[].obs;
  final RxInt currentSurahNumber = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingData = false.obs;

  // Translation & Settings
  final Rx<QuranSettings> settings = QuranSettings().obs;
  final RxList<String> availableLanguages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadAvailableLanguages();
    loadSurahs();
    _checkAndLoadQuranData();
  }

  /// Load user settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final arabicFontSize = prefs.getDouble('arabic_font_size') ?? 24.0;
      final translationFontSize =
          prefs.getDouble('translation_font_size') ?? 16.0;
      final showTranslation = prefs.getBool('show_translation') ?? true;
      final selectedLanguages =
          prefs.getStringList('selected_languages') ?? ['ar'];
      final showTransliteration =
          prefs.getBool('show_transliteration') ?? false;
      final arabicFont = prefs.getString('arabic_font') ?? 'Amiri';
      final theme = prefs.getString('quran_theme') ?? 'light';

      settings.value = QuranSettings(
        arabicFontSize: arabicFontSize,
        translationFontSize: translationFontSize,
        showTranslation: showTranslation,
        selectedLanguages: selectedLanguages,
        showTransliteration: showTransliteration,
        arabicFont: arabicFont,
        theme: theme,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('arabic_font_size', settings.value.arabicFontSize);
      await prefs.setDouble(
        'translation_font_size',
        settings.value.translationFontSize,
      );
      await prefs.setBool('show_translation', settings.value.showTranslation);
      await prefs.setStringList(
        'selected_languages',
        settings.value.selectedLanguages,
      );
      await prefs.setBool(
        'show_transliteration',
        settings.value.showTransliteration,
      );
      await prefs.setString('arabic_font', settings.value.arabicFont);
      await prefs.setString('quran_theme', settings.value.theme);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Load available translation languages
  void _loadAvailableLanguages() {
    availableLanguages.value = QuranDataLoader.availableLanguages;
  }

  /// Check and load Quran data if not loaded
  Future<void> _checkAndLoadQuranData() async {
    try {
      final isLoaded = await QuranDataLoader.isQuranDataLoaded();
      if (!isLoaded) {
        isLoadingData.value = true;
        await QuranDataLoader.loadQuranData(
          languages: settings.value.selectedLanguages,
          onProgress: (message) {
            debugPrint('📖 $message');
          },
        );
        isLoadingData.value = false;
        // Reload surahs after data is loaded
        await loadSurahs();
      }
    } catch (e) {
      debugPrint('Error loading Quran data: $e');
      isLoadingData.value = false;
    }
  }

  /// Load all surahs
  Future<void> loadSurahs() async {
    try {
      isLoading.value = true;
      surahs.value = await _dbService.getAllSurahs();
      debugPrint('✅ Loaded ${surahs.length} surahs');
    } catch (e) {
      debugPrint('Error loading surahs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load verses for a specific surah with translations
  Future<void> loadSurahVerses(int surahNumber) async {
    try {
      isLoading.value = true;
      currentSurahNumber.value = surahNumber;

      debugPrint('📖 Loading verses for surah $surahNumber...');

      // Always load basic verses first
      currentSurahVerses.value = await _dbService.getSurahVerses(surahNumber);
      debugPrint('✅ Loaded ${currentSurahVerses.length} verses');

      // Then try to load translations if enabled
      if (settings.value.showTranslation &&
          settings.value.selectedLanguages.isNotEmpty &&
          currentSurahVerses.isNotEmpty) {
        try {
          debugPrint(
            '🌐 Loading translations for ${settings.value.selectedLanguages}...',
          );
          currentSurahVerses.value = await _dbService
              .getSurahVersesWithTranslations(
                surahNumber,
                settings.value.selectedLanguages,
              );
          debugPrint('✅ Loaded verses with translations');
        } catch (e) {
          debugPrint('⚠️ Translation loading failed, showing Arabic only: $e');
          // Keep the Arabic verses we already loaded
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading surah verses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get surah name by number
  String getSurahName(int surahNumber) {
    final surah = surahs.firstWhereOrNull((s) => s.surahNumber == surahNumber);
    return surah?.surahName ?? 'سورة $surahNumber';
  }

  /// Get surah info by number
  SurahInfo? getSurahInfo(int surahNumber) {
    return surahs.firstWhereOrNull((s) => s.surahNumber == surahNumber);
  }

  // ========== SETTINGS MANAGEMENT ==========

  /// Toggle translation display
  void toggleTranslation() {
    settings.value = settings.value.copyWith(
      showTranslation: !settings.value.showTranslation,
    );
    _saveSettings();
    // Reload current surah if open
    if (currentSurahNumber.value > 0) {
      loadSurahVerses(currentSurahNumber.value);
    }
  }

  /// Toggle transliteration display
  void toggleTransliteration() {
    settings.value = settings.value.copyWith(
      showTransliteration: !settings.value.showTransliteration,
    );
    _saveSettings();
  }

  /// Toggle language selection
  void toggleLanguage(String languageCode) async {
    final currentLangs = List<String>.from(settings.value.selectedLanguages);

    if (currentLangs.contains(languageCode)) {
      // Remove language
      currentLangs.remove(languageCode);
    } else {
      // Add language - try to load it first if not already loaded
      try {
        debugPrint('🌐 Loading $languageCode translation...');
        await QuranDataLoader.loadTranslation(languageCode);
        debugPrint('✅ $languageCode translation loaded');
      } catch (e) {
        debugPrint('⚠️ Translation might already be loaded or error: $e');
      }
      currentLangs.add(languageCode);
    }

    settings.value = settings.value.copyWith(selectedLanguages: currentLangs);
    _saveSettings();

    // Reload current surah if open
    if (currentSurahNumber.value > 0) {
      loadSurahVerses(currentSurahNumber.value);
    }
  }

  /// Update Arabic font size
  void updateArabicFontSize(double size) {
    settings.value = settings.value.copyWith(arabicFontSize: size);
    _saveSettings();
  }

  /// Update translation font size
  void updateTranslationFontSize(double size) {
    settings.value = settings.value.copyWith(translationFontSize: size);
    _saveSettings();
  }

  /// Change theme
  void changeTheme(String theme) {
    settings.value = settings.value.copyWith(theme: theme);
    _saveSettings();
  }

  /// Get language name from code
  String getLanguageName(String code) {
    return QuranDataLoader.getLanguageName(code);
  }

  /// Load additional translation
  Future<void> loadAdditionalTranslation(String languageCode) async {
    try {
      isLoading.value = true;
      await QuranDataLoader.loadTranslation(languageCode);

      // Add to selected languages if not already there
      if (!settings.value.selectedLanguages.contains(languageCode)) {
        toggleLanguage(languageCode);
      }
    } catch (e) {
      debugPrint('Error loading translation: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
