import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TafseerService extends GetxService {
  static TafseerService get to => Get.find();

  // Cache for loaded tafseer data
  List<dynamic> _tafseerData = [];
  bool _isLoading = false;
  String _currentSource = '';

  // Categorized Tafseers & Translations
  final Map<String, String> quranMeanings = {
    'ar_ma3any.json': 'tafseer_ma3any',
    'e3rab.json': 'tafseer_e3rab',
  };

  final Map<String, String> arabicTafseers = {
    'ar_muyassar.json': 'tafseer_muyassar',
    'baghawy.json': 'tafseer_baghawy',
    'katheer.json': 'tafseer_katheer',
    'sa3dy.json': 'tafseer_sa3dy',
    'tabary.json': 'tafseer_tabary',
    'qortoby.json': 'tafseer_qortoby',
    'waseet.json': 'tafseer_waseet',
  };

  final Map<String, String> translations = {
    'en_sahih.json': 'tafseer_english_sahih',
    'fr_hamidullah.json': 'tafseer_french',
    'de_bubenheim.json': 'tafseer_german',
    'es_navio.json': 'tafseer_spanish',
    'it_piccardo.json': 'tafseer_italian',
    'pt_elhayek.json': 'tafseer_portuguese',
    'ru_kuliev.json': 'tafseer_russian',
    'nl_siregar.json': 'tafseer_dutch',
    'sv_bernstrom.json': 'tafseer_swedish',
    'sq_nahi.json': 'tafseer_albanian',
    'bs_korkut.json': 'tafseer_bosnian',
    'ur_jalandhry.json': 'tafseer_urdu',
    'bn_bengali.json': 'tafseer_bengali',
    'id_indonesian.json': 'tafseer_indonesian',
    'ms_basmeih.json': 'tafseer_malay',
    'th_thai.json': 'tafseer_thai',
    'zh_jian.json': 'tafseer_chinese',
    'tr_diyanet.json': 'tafseer_turkish',
    'uz_sodik.json': 'tafseer_uzbek',
    'pr_tagi.json': 'tafseer_persian',
    'ku_asan.json': 'tafseer_kurdish',
    'ml_abdulhameed.json': 'tafseer_malayalam',
    'ta_tamil.json': 'tafseer_tamil',
    'ha_gumi.json': 'tafseer_hausa',
    'sw_barwani.json': 'tafseer_swahili',
    'so_abduh.json': 'tafseer_somali',
  };

  // Combined Getter for convenience if needed, but UI should use specific maps
  Map<String, String> get allTafseers => {
    ...quranMeanings,
    ...arabicTafseers,
    ...translations,
  };

  /// Load Tafseer data from JSON assets
  Future<void> loadTafseer({String source = 'ar_muyassar.json'}) async {
    // If already loaded same source, return
    if (_tafseerData.isNotEmpty && _currentSource == source) return;

    _isLoading = true;
    _currentSource = source;
    _tafseerData = []; // Clear previous data

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/Quran-App-Data/Tafaseer/$source',
      );
      _tafseerData = json.decode(jsonString);
    } catch (e) {
      print('Error loading tafseer ($source): $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Get Tafseer text for a specific ayah
  String getTafseer(int surah, int ayah) {
    if (_isLoading) return 'Loading tafseer data...';
    if (_tafseerData.isEmpty) {
      return 'Tafseer data not loaded.';
    }

    final entry = _tafseerData.firstWhereOrNull(
      (e) => e['sura'] == surah && e['aya'] == ayah,
    );

    final text = entry?['text'] ?? '';

    if (text.isEmpty) {
      if (_currentSource == 'ar_ma3any.json' ||
          _currentSource == 'tafseer_ma3any') {
        return 'لا توجد كلمات صعبة في هذه الآية.'; // "No difficult words in this verse"
      }
      return 'No tafseer available for this verse.'.tr;
    }

    return _cleanHtml(text);
  }

  /// Clean HTML tags from text
  String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<br\s*/?>'), '\n') // Replace <br> with newline
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove other HTML tags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&');
  }
}
