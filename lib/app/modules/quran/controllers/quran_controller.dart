import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/tafseer_service.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/models/quran_models.dart';

/// Quran controller for surah and ayah management
class QuranController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<SurahInfo> surahs = <SurahInfo>[].obs;

  // Surah View State
  final RxList<Ayah> currentSurahVerses = <Ayah>[].obs;
  final RxInt currentSurahNumber = 0.obs;

  // Page View State
  final RxList<Ayah> currentPageVerses = <Ayah>[].obs;
  final RxInt currentPageNumber = 1.obs;
  final RxInt maxPageNumber = 604.obs;
  final RxBool isPageView = true.obs;
  final RxList<Map<String, int>> juzInfo = <Map<String, int>>[].obs;

  final RxBool isLoading = false.obs;

  // Image Mode State
  final RxBool isImageMode = false.obs;

  // PDF State
  final List<Map<String, String>> pdfFiles = [
    {
      'name': 'القرآن الكريم (نسخة 1)',
      'path': 'assets/data/Islamic-and-quran-data/quran_pdf/quran.pdf',
    },
    {
      'name': 'مصحف المدينة المنورة',
      'path':
          'assets/data/Islamic-and-quran-data/quran_pdf/Saudi-Quran-PDF.pdf',
    },
    {
      'name': 'القرآن الكريم (نسخة إلكترونية)',
      'path': 'assets/data/Islamic-and-quran-data/quran_pdf/E-Quran-00003.pdf',
    },
    {
      'name': 'رواية الدوري',
      'path': 'assets/data/Islamic-and-quran-data/quran_pdf/rewayat_aldory.pdf',
    },
  ];

  // Filter and Search State
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Tafseer State
  final RxString selectedTafseer = 'ar_muyassar.json'.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to audio completion
    AudioService.to.playbackCompleted.listen((_) => _playNextAyah());

    loadSurahs();
    loadPageVerses(1); // Load first page by default
  }

  /// Load all surahs
  Future<void> loadSurahs() async {
    try {
      isLoading.value = true;
      surahs.value = await _dbService.getAllSurahs();
      maxPageNumber.value = await _dbService.getMaxPageNumber();
      juzInfo.value = await _dbService.getJuzStartPages();
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
      isPageView.value = false; // Switch to list view
    } catch (e) {
      debugPrint('Error loading surah verses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load verses for a specific page
  Future<void> loadPageVerses(int pageNumber, {bool showLoading = true}) async {
    try {
      if (pageNumber < 1 || pageNumber > maxPageNumber.value) return;

      if (showLoading) isLoading.value = true;
      currentPageNumber.value = pageNumber;

      // We only strictly need this for the "List View" or if we want to validata data availability
      // But for PageView's FutureBuilder, this is redundant.
      // However, keeping it for now to ensure state consistency.
      currentPageVerses.value = await _dbService.getVersesByPage(pageNumber);
      isPageView.value = true;
    } catch (e) {
      debugPrint('Error loading page verses: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// Update current page number without reloading data (for PageView scroll)
  void updatePageNumber(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= maxPageNumber.value) {
      currentPageNumber.value = pageNumber;
    }
  }

  /// Jump to specific page
  Future<void> jumpToPage(int pageNumber) async {
    await loadPageVerses(pageNumber);
  }

  /// Get verses for a specific page (helper for PageView builder)
  Future<List<Ayah>> getVersesForPage(int pageNumber) {
    return _dbService.getVersesByPage(pageNumber);
  }

  /// Change Tafseer source
  Future<void> changeTafseer(String filename) async {
    selectedTafseer.value = filename;
    await TafseerService.to.loadTafseer(source: filename);
    update(); // Force UI update
  }

  /// Toggle Image Mode
  void toggleImageMode() {
    isImageMode.value = !isImageMode.value;
    if (isImageMode.value) {
      // Ensure we are in page view logic if we switch to images
      isPageView.value = true;
      // If we were in Surah list view, we need to map current verse to page?
      // Logic: if currentSurahVerses is populated, take first verse and find its page?
      // For now, let's assume currentPageNumber is reasonably accurate or synced.
    }
  }

  /// Show Tafseer for a specific ayah
  void showTafseer(Ayah ayah) {
    // Determine initially loaded tafseer
    TafseerService.to.loadTafseer(source: selectedTafseer.value);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7, // Increased height
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
                // Tafseer Selector
                DropdownButton<String>(
                  value: selectedTafseer.value,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: [
                    // Meanings Group
                    _buildHeaderItem('Meanings'),
                    ...TafseerService.to.quranMeanings.entries.map(
                      (e) => _buildItem(e),
                    ),

                    // Tafseer Group
                    _buildHeaderItem('Tafseer'),
                    ...TafseerService.to.arabicTafseers.entries.map(
                      (e) => _buildItem(e),
                    ),

                    // Translations Group
                    _buildHeaderItem('Translations'),
                    ...TafseerService.to.translations.entries.map(
                      (e) => _buildItem(e),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      changeTafseer(val);
                      Get.back(); // Close existing sheet
                      // Re-open sheet with new data (simplest way to refresh async content)
                      Future.delayed(const Duration(milliseconds: 100), () {
                        showTafseer(ayah);
                      });
                    }
                  },
                ),
                const SizedBox(width: 48),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      ayah.ayahText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${getSurahName(ayah.surahNumber)} - الآية ${ayah.ayahNumber}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder(
                      future: TafseerService.to.loadTafseer(
                        source: selectedTafseer.value,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final text = TafseerService.to.getTafseer(
                          ayah.surahNumber,
                          ayah.ayahNumber,
                        );

                        return Text(
                          text,
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  /// Go to next page
  void nextPage() {
    if (currentPageNumber.value < maxPageNumber.value) {
      loadPageVerses(currentPageNumber.value + 1);
    }
  }

  /// Go to previous page
  void previousPage() {
    if (currentPageNumber.value > 1) {
      loadPageVerses(currentPageNumber.value - 1);
    }
  }

  /// Get surah name by number
  String getSurahName(int surahNumber) {
    final surah = surahs.firstWhereOrNull((s) => s.surahNumber == surahNumber);
    return surah?.surahName ?? 'سورة $surahNumber';
  }

  /// Get filtered surahs based on search and selected filter
  List<SurahInfo> getFilteredSurahs() {
    var result = surahs.toList();
    final filter = selectedFilter.value;
    final query = searchQuery.value.trim();

    // Apply search filter first
    if (query.isNotEmpty) {
      result = result.where((s) => s.surahName.contains(query)).toList();
    }

    // Apply category filter
    if (filter == 'all') return result;

    if (filter == 'meccan') {
      return result.where((s) => s.revelationType == 'Meccan').toList();
    }

    if (filter == 'medinan') {
      return result.where((s) => s.revelationType == 'Medinan').toList();
    }

    if (filter == 'short') {
      return result.where((s) => s.versesCount < 50).toList();
    }

    if (filter == 'long') {
      return result.where((s) => s.versesCount >= 50).toList();
    }

    return result;
  }

  /// Audio: Play specific ayah
  Future<void> playAyah(Ayah ayah) async {
    await AudioService.to.playAyah(ayah.surahNumber, ayah.ayahNumber);
  }

  /// Audio: Stop playback
  Future<void> stopAudio() async {
    await AudioService.to.stop();
  }

  // Audio State Getters
  int get audioSurah => AudioService.to.currentSurah.value;
  int get audioAyah => AudioService.to.currentAyah.value;
  bool get isAudioPlaying => AudioService.to.isPlaying.value;

  void _playNextAyah() {
    int currentS = AudioService.to.currentSurah.value;
    int currentA = AudioService.to.currentAyah.value;

    // Logic to find next ayah
    // We need to know max verses for currentS
    final surah = surahs.firstWhereOrNull((s) => s.surahNumber == currentS);
    if (surah == null) return;

    if (currentA < surah.versesCount) {
      // Next ayah in same surah
      playAyah(
        Ayah(
          surahNumber: currentS,
          ayahNumber: currentA + 1,
          ayahText: '',
          ayahId: 0,
          surahName: surah.surahName,
          surahNameEn: surah.surahNameEn,
        ),
      );
    } else {
      // Next surah?
      if (currentS < 114) {
        final nextSurah = surahs.firstWhereOrNull(
          (s) => s.surahNumber == currentS + 1,
        );
        playAyah(
          Ayah(
            surahNumber: currentS + 1,
            ayahNumber: 1,
            ayahText: '',
            ayahId: 0,
            surahName: nextSurah?.surahName ?? '',
            surahNameEn: nextSurah?.surahNameEn ?? '',
          ),
        );
      } else {
        // End of Quran
        stopAudio();
      }
    }
  }

  /// Helper: Build a non-selectable header item
  DropdownMenuItem<String> _buildHeaderItem(String title) {
    return DropdownMenuItem<String>(
      enabled: false,
      value: null,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          title.tr,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Show Reciter Selector
  void showReciterSelector() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'select_reciter'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                // Ensure AudioService has loaded reciters
                if (AudioService.to.availableReciters.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: AudioService.to.availableReciters.length,
                  itemBuilder: (context, index) {
                    final reciter = AudioService.to.availableReciters[index];
                    final isSelected =
                        AudioService.to.currentReciterId.value == reciter.id;

                    return ListTile(
                      title: Text(reciter.name),
                      subtitle: Text(
                        reciter.arabicName,
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        AudioService.to.changeReciter(reciter.id);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Helper: Build a selectable tafseer item
  DropdownMenuItem<String> _buildItem(MapEntry<String, String> entry) {
    return DropdownMenuItem<String>(
      value: entry.key,
      child: Text(
        entry.value.tr,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
