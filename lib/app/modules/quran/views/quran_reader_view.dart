import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../controllers/quran_controller.dart';
import '../../../data/models/quran_models.dart';
import 'memorization_log_view.dart';
import 'quran_settings_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/database_service.dart';
import '../../student/controllers/student_controller.dart';

/// Enhanced Quran reader view with translation support and auto-save position
class QuranReaderView extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const QuranReaderView({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
  });

  @override
  State<QuranReaderView> createState() => _QuranReaderViewState();
}

class _QuranReaderViewState extends State<QuranReaderView> {
  late final QuranController controller;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final AuthController _authController = Get.find<AuthController>();

  // Track last visible ayah
  int _lastVisibleAyah = 1;

  @override
  void initState() {
    super.initState();
    controller = Get.put(QuranController());

    // Listen to scroll positions to track reading progress
    itemPositionsListener.itemPositions.addListener(_onPositionChanged);

    // Load verses after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSurahVerses(widget.surahNumber).then((_) {
        // Jump to initial ayah if provided
        if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 0) {
          // Add delay to ensure list is rendered
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              itemScrollController.jumpTo(index: widget.initialAyahNumber!);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    // Save reading position on exit
    _saveReadingPosition();
    itemPositionsListener.itemPositions.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // Get the first visible item
      final firstVisible = positions
          .where((item) => item.itemLeadingEdge < 1)
          .reduce(
            (max, item) =>
                item.itemLeadingEdge > max.itemLeadingEdge ? item : max,
          );

      // Index 0 is Bismillah, so Ayah 1 is Index 1
      // If index is 0, we can say ayah 1
      int ayahNum = firstVisible.index;
      if (ayahNum == 0) ayahNum = 1;

      if (ayahNum != _lastVisibleAyah) {
        _lastVisibleAyah = ayahNum;
      }
    }
  }

  Future<void> _saveReadingPosition() async {
    final userId = _authController.userId;
    if (userId != null) {
      debugPrint(
        'Saving reading position: Surah ${widget.surahNumber}, Ayah $_lastVisibleAyah',
      );
      await DatabaseService.instance.saveResumePosition(
        userId,
        widget.surahNumber,
        _lastVisibleAyah,
      );
      // Refresh student stats to show updated "Continue Reading"
      if (Get.isRegistered<StudentController>()) {
        Get.find<StudentController>().refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.getSurahName(widget.surahNumber)),
        actions: [
          // Translation toggle
          Obx(
            () => IconButton(
              icon: Icon(
                controller.settings.value.showTranslation
                    ? Icons.translate
                    : Icons.translate_outlined,
              ),
              onPressed: controller.toggleTranslation,
              tooltip: 'Toggle Translation',
            ),
          ),
          // Language selector
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
            tooltip: 'Select Languages',
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const QuranSettingsView()),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Quran data...'),
              ],
            ),
          );
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentSurahVerses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text('no_quran_data'.tr),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      controller.loadSurahVerses(widget.surahNumber),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ScrollablePositionedList.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.currentSurahVerses.length + 1,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, index) {
            // Bismillah header
            if (index == 0) {
              if (widget.surahNumber != 1 && widget.surahNumber != 9) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: GoogleFonts.amiri(
                        fontSize: controller.settings.value.arabicFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            // Verses
            final ayah = controller.currentSurahVerses[index - 1];
            return _buildVerseCard(ayah);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMemorizationLog,
        icon: const Icon(Icons.add),
        label: const Text('تسجيل الحفظ'),
      ),
    );
  }

  Widget _buildVerseCard(Ayah ayah) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse number
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ayah.ayahNumber}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Arabic text
            Text(
              ayah.ayahText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: GoogleFonts.amiri(
                fontSize: controller.settings.value.arabicFontSize,
                height: 2,
              ),
            ),

            // Transliteration
            if (controller.settings.value.showTransliteration &&
                ayah.transliteration != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  ayah.transliteration!,
                  style: TextStyle(
                    fontSize: controller.settings.value.translationFontSize,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Translations
            if (controller.settings.value.showTranslation &&
                ayah.translations != null &&
                ayah.translations!.isNotEmpty)
              ...ayah.translations!.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.getLanguageName(entry.key),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize:
                              controller.settings.value.translationFontSize,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Translation Languages'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(
            () => ListView(
              shrinkWrap: true,
              children: controller.availableLanguages.map((lang) {
                final isSelected = controller.settings.value.selectedLanguages
                    .contains(lang);
                return CheckboxListTile(
                  title: Text(controller.getLanguageName(lang)),
                  subtitle: Text(lang.toUpperCase()),
                  value: isSelected,
                  onChanged: (_) => controller.toggleLanguage(lang),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openMemorizationLog() {
    final surahInfo = controller.surahs.firstWhereOrNull(
      (s) => s.surahNumber == widget.surahNumber,
    );
    Get.to(
      () => MemorizationLogView(
        surahNumber: widget.surahNumber,
        surahName: surahInfo?.surahName ?? 'سورة ${widget.surahNumber}',
        totalVerses:
            surahInfo?.versesCount ?? controller.currentSurahVerses.length,
      ),
      transition: Transition.cupertino,
    );
  }
}
