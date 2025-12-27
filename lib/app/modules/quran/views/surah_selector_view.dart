import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_drawer.dart';
import '../controllers/quran_controller.dart';
import 'quran_reader_view.dart';

/// Modern Surah selector view
class SurahSelectorView extends GetView<QuranController> {
  const SurahSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => QuranController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FDF4),
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'القرآن الكريم',
            style: GoogleFonts.cairo(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'صفحة 1 من 604',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                labelColor: const Color(0xFF059669),
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'السور'),
                  Tab(text: 'الأجزاء'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [_buildSurahList(context), _buildJuzList(context)],
        ),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.surahs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.surahs.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.surahs.length,
        itemBuilder: (context, index) {
          final surah = controller.surahs[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7), // Beige color
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${surah.surahNumber}',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                surah.surahName,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown.shade900,
                ),
              ),
              subtitle: Text(
                '${surah.versesCount} آية',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.brown.shade700,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.brown.shade700,
              ),
              onTap: () => Get.to(
                () => QuranReaderView(surahNumber: surah.surahNumber),
                transition: Transition.cupertino,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildJuzList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.juzInfo.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.juzInfo.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.juzInfo.length,
        itemBuilder: (context, index) {
          final info = controller.juzInfo[index];
          final juzNum = info['juz'];
          final startPage = info['page'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF059669), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$juzNum',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                'الجزء $juzNum',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'صفحة $startPage',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF059669),
              ),
              onTap: () => Get.to(
                () => QuranReaderView(
                  surahNumber: 1,
                  initialPageNumber: startPage,
                ),
                transition: Transition.cupertino,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text('لا توجد بيانات', style: GoogleFonts.cairo(fontSize: 16)),
        ],
      ),
    );
  }
}
