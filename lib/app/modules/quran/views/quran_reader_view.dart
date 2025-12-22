import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quran_controller.dart';
import 'memorization_log_view.dart';

/// Quran reader view
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(QuranController());
    controller.loadSurahVerses(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.surahs.isNotEmpty
                ? controller.getSurahName(widget.surahNumber)
                : 'سورة ${widget.surahNumber}',
          ),
        ),
      ),
      body: Obx(() {
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
              ],
            ),
          );
        }

        return Container(
          color: const Color(0xFFFAF8F5),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Surah Header
                Container(
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Verses
                ...controller.currentSurahVerses.map((ayah) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ayah.ayahText,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.amiri(fontSize: 24, height: 2),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMemorizationLog,
        icon: const Icon(Icons.add),
        label: const Text('تسجيل الحفظ'),
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
