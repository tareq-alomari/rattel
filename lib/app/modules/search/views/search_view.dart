import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/search_controller.dart' as app;

/// Quran search view matching reference design
class SearchView extends GetView<app.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchTextController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'البحث',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ابحث في القرآن والأحاديث',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Input (matching reference image 4)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن آية أو حديث...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primaryLight,
                    size: 28,
                  ),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchTextController.clear();
                              controller.clearSearch();
                            },
                          )
                        : const SizedBox(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) => controller.searchQuran(value),
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs (القرآن / الأحاديث)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildTab('القرآن', true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTab('الأحاديث', false)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Results
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 24),
                      Text(
                        'ابدأ البحث للحصول على النتائج',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'لا توجد نتائج',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ayah = controller.searchResults[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ayah.ayahText,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            height: 1.8,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${ayah.surahName} - آية ${ayah.ayahNumber}',
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? Icons.book : Icons.article,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
