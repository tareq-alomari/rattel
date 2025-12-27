import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../hadith/controllers/hadith_controller.dart';
import '../../../data/models/hadith.dart';

class HadithBookView extends GetView<HadithController> {
  const HadithBookView({super.key});

  @override
  Widget build(BuildContext context) {
    final book = controller.selectedBook.value;
    if (book == null) {
      return Scaffold(
        body: Center(
          child: Text('لم يتم اختيار كتاب', style: GoogleFonts.cairo()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          book.titleAr,
          style: GoogleFonts.amiri(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingHadiths.value && controller.hadiths.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoadingHadiths.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.loadHadiths();
              return true;
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.hadiths.length +
                (controller.isLoadingHadiths.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.hadiths.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildHadithCard(context, controller.hadiths[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHadithCard(BuildContext context, Hadith hadith) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with number and bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'حديث ${hadith.hadithNumber}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      hadith.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: hadith.isFavorite
                          ? const Color(0xFFF59E0B)
                          : Colors.grey,
                    ),
                    onPressed: () => controller.toggleFavorite(hadith),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arabic Text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hadith.text,
              style: GoogleFonts.amiri(
                fontSize: 20,
                height: 2.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          if (hadith.explanation.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Translation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.translate,
                        size: 16,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الترجمة',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hadith.explanation,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Copy functionality
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text('نسخ', style: GoogleFonts.cairo(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF059669)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Save functionality
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: Text('حفظ', style: GoogleFonts.cairo(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF059669)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Explain functionality
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: Text('شرح', style: GoogleFonts.cairo(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF059669)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
