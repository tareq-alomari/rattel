import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import '../../../data/models/quran_models.dart';
import '../controllers/quran_controller.dart';
import '../controllers/bookmarks_controller.dart';
import '../../memorization/controllers/memorization_controller.dart';

/// Quran reader view
class QuranReaderView extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  final int? initialPageNumber;

  const QuranReaderView({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
    this.initialPageNumber,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPageNumber != null) {
        controller.loadPageVerses(widget.initialPageNumber!);
      } else {
        controller.loadSurahVerses(widget.surahNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isPageView.value
                ? 'p_${controller.currentPageNumber.value}'
                      .tr // 'Page X'
                : (controller.surahs.isNotEmpty
                      ? controller.getSurahName(widget.surahNumber)
                      : 'سورة ${widget.surahNumber}'),
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isPageView.value ? Icons.list : Icons.menu_book,
              ),
              onPressed: () {
                controller.isPageView.toggle();
                if (controller.isPageView.value) {
                  // If switching to page view, load the page of the first visible verse?
                  // For now, load default or current page
                  controller.loadPageVerses(controller.currentPageNumber.value);
                } else {
                  // Switch to list view - might need to load specific surah
                  controller.loadSurahVerses(widget.surahNumber);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // Ensure controller is available before navigating
              if (!Get.isRegistered<BookmarksController>()) {
                Get.put(BookmarksController());
              }
              Get.toNamed('/bookmarks');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isPageView.value) {
          return _buildPageView();
        } else {
          return _buildListView();
        }
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // For now, prompt for current page? Or just open dashboard
          Get.toNamed('/memorization');
        },
        icon: const Icon(Icons.dashboard),
        label: Text('memorization_dashboard'.tr),
      ),
      bottomNavigationBar: Obx(() {
        if (!controller.isAudioPlaying && controller.audioSurah == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: controller.stopAudio,
                icon: const Icon(Icons.stop),
              ),
              const Spacer(),
              Text(
                'surah_ayah_status'.trParams({
                  'surah': '${controller.audioSurah}',
                  'ayah': '${controller.audioAyah}',
                }),
              ),
              const Spacer(),
              // Add pause/resume logic later if needed
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: PageController(
        initialPage: controller.currentPageNumber.value - 1,
      ),
      itemCount: controller.maxPageNumber.value,
      reverse: true, // Arabic right-to-left
      onPageChanged: (index) {
        controller.updatePageNumber(index + 1);
      },
      itemBuilder: (context, index) {
        return FutureBuilder<List<dynamic>>(
          // List<Ayah>
          future: controller.getVersesForPage(index + 1),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildPageContent(context, snapshot.data as List<dynamic>);
          },
        );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, List<dynamic> verses) {
    // Group verses by Surah
    Map<int, List<dynamic>> versesBySurah = {};
    for (var v in verses) {
      versesBySurah.putIfAbsent(v.surahNumber, () => []).add(v);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBE8), // Warm Papery Color
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/paper_texture.png',
            ), // Will fallback if missing
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
          borderRadius: BorderRadius.circular(2), // Sharp corners like paper
          border: Border.symmetric(
            vertical: BorderSide(
              color: const Color(0xFF2E7D32), // Green inner binding
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          // Inner decorative frame
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFC6A664),
              width: 2,
            ), // Gold Frame
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: versesBySurah.entries.map((entry) {
              int surahNum = entry.key;
              List<dynamic> surahVerses = entry.value;

              bool isStartOfSurah = surahVerses.any((v) => v.ayahNumber == 1);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isStartOfSurah) ...[
                    _buildSurahHeader(controller.getSurahName(surahNum)),
                    if (surahNum != 9) _buildBismillah(),
                  ],

                  // Text Block
                  Obx(() {
                    return Text.rich(
                      TextSpan(
                        children: surahVerses.map((v) {
                          final ayah = v as Ayah;

                          // Check if this verse is currently playing
                          final isPlaying =
                              controller.isAudioPlaying &&
                              controller.audioSurah == surahNum &&
                              controller.audioAyah == ayah.ayahNumber;

                          return TextSpan(
                            children: [
                              TextSpan(
                                text: ayah.ayahText,
                                style: GoogleFonts.amiri(
                                  fontSize: 26,
                                  height: 2.2, // increased from 2.2
                                  color: Colors.black87,
                                  backgroundColor: isPlaying
                                      ? const Color(
                                          0xFFFFE0B2,
                                        ) // Warm highlight
                                      : null,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showAyahOptions(ayah, surahNum);
                                  },
                              ),
                              TextSpan(
                                text: ' \uFD3F${ayah.ayahNumber}\uFD3E ',
                                style: GoogleFonts.amiri(
                                  color: const Color(
                                    0xFFC6A664,
                                  ), // Gold markers
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAyahOptions(Ayah ayah, int surahNum) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Color(0xFF1B5E20)),
              title: Text('play_audio'.tr),
              onTap: () {
                Get.back();
                controller.playAyah(ayah);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF1B5E20)),
              title: Text('tafseer_verse'.tr),
              onTap: () {
                Get.back();
                controller.showTafseer(ayah);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF1B5E20),
              ),
              title: Text('memorized'.tr),
              onTap: () {
                Get.back();
                _showMemorizationDialog(ayah);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bookmark_add, color: Color(0xFF8D6E63)),
              title: Text('bookmark_save'.tr),
              onTap: () {
                Get.back();
                // Ensure controller is available
                final bookmarksCtrl = Get.isRegistered<BookmarksController>()
                    ? Get.find<BookmarksController>()
                    : Get.put(BookmarksController());

                bookmarksCtrl.addBookmark(
                  surah: surahNum,
                  ayah: ayah.ayahNumber,
                  page: controller.currentPageNumber.value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahHeader(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE8),
        image: const DecorationImage(
          // In real app, use an SVG asset for the surah decorative frame
          // For now, simulating with a gradient border container
          image: AssetImage('assets/images/surah_header_pattern.png'),
          fit: BoxFit.fitWidth,
          opacity: 0.1,
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: const Color(0xFFC6A664), width: 2),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC6A664)),
          ),
          child: Text(
            name,
            style: GoogleFonts.amiri(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'tafseer_bismillah'.tr,
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(fontSize: 22),
      ),
    );
  }

  Widget _buildListView() {
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
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
  }

  void _showMemorizationDialog(Ayah ayah) {
    // Lazy load memorization controller if not present
    // Ideally this should be injected, but for brevity we'll find or put it
    // Note: In real app, check if it's registered
    // final memController = Get.put(MemorizationController());
    // BUT efficient way is to rely on bindings.
    // For now, let's assume it's available or put it.

    // Check for active plans first?
    // For simplicity: Show dialog to confirm.

    Get.defaultDialog(
      title: 'memorize_confirm_title'.tr, // "Confirm Memorization"
      content: Column(
        children: [
          Text('memorize_confirm_msg'.trParams({'ayah': '${ayah.ayahNumber}'})),
          const SizedBox(height: 16),
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(Icons.star_border, color: Colors.amber);
            }),
          ),
        ],
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        // Log progress
        try {
          // Ensure controller is available
          final memController = Get.isRegistered<MemorizationController>()
              ? Get.find<MemorizationController>()
              : Get.put(MemorizationController());

          // Create a default plan if none exists for this Surah (MVC simplification)
          // For now, we'll just log to a "General" plan (ID: 1) or warn if no plan.
          // Ideally, we fetch active plans for this Surah.

          // Simple MVP: Log activity with ID 0 or handle in controller
          memController.logProgress(1, 1, 5); // Dummy planId=1, 1 page, 5 stars

          Get.back();
          // Get.snackbar('Success', 'Marked as Memorized'); // Controller already shows snackbar
        } catch (e) {
          Get.snackbar('Error', 'Could not save progress: $e');
        }
      },
    );
  }
}
