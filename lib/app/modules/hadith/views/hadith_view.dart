import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../hadith/controllers/hadith_controller.dart';
import '../../../data/models/hadith_book.dart';
import '../views/hadith_book_view.dart';
import '../views/hadith_search_view.dart';

class HadithView extends GetView<HadithController> {
  const HadithView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HadithController>()) {
      Get.put(HadithController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'الأحاديث النبوية',
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => Get.to(() => const HadithSearchView()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingBooks.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.books.isEmpty) {
          return Center(
            child: Text(
              'لا توجد كتب أحاديث',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 18),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر الكتاب',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.books.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;
                return _buildBookCard(context, book, index);
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBookCard(BuildContext context, HadithBook book, int index) {
    // Different colors for each book
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];

    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        controller.selectBook(book);
        Get.to(() => const HadithBookView());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleAr,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.hadithCount} حديث',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
