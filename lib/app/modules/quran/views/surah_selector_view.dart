import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';

import '../controllers/quran_controller.dart';
import 'quran_reader_view.dart';
import 'pdf_selector_view.dart';

/// Modern Surah selector view with filters
class SurahSelectorView extends GetView<QuranController> {
  const SurahSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // Modern AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryLight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'holy_quran'.tr,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.menu_book,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'total_surahs'.tr,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showSearchDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: () => Get.to(() => const PdfSelectorView()),
              ),
            ],
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('filter_all'.tr, 'all'),
                    _buildFilterChip('filter_meccan'.tr, 'meccan'),
                    _buildFilterChip('filter_medinan'.tr, 'medinan'),
                    _buildFilterChip('filter_short'.tr, 'short'),
                    _buildFilterChip('filter_long'.tr, 'long'),
                  ],
                ),
              ),
            ),
          ),

          // Surah List
          Obx(() {
            if (controller.isLoading.value && controller.surahs.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.surahs.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState(context));
            }

            final filteredSurahs = controller.getFilteredSurahs();

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final surah = filteredSurahs[index];
                  return _buildSurahCard(
                    surah,
                    key: ValueKey(surah.surahNumber),
                  );
                }, childCount: filteredSurahs.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.selectedFilter.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(dynamic surah, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          label: 'surah_card'.trParams({
            'name': surah.surahName,
            'number': '${surah.surahNumber}',
            'type': surah.revelationType == 'Meccan'
                ? 'meccan'.tr
                : 'medinan'.tr,
          }),
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Get.to(
              () => QuranReaderView(surahNumber: surah.surahNumber),
              transition: Transition.cupertino,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Surah Number
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${surah.surahNumber}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Surah Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.surahName,
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'verses_count'.trParams({
                                'count': '${surah.versesCount}',
                              }),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: surah.revelationType == 'Meccan'
                                    ? AppColors.badgeOrange.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.badgeGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                surah.revelationType == 'Meccan'
                                    ? 'filter_meccan'.tr
                                    : 'filter_medinan'.tr,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: surah.revelationType == 'Meccan'
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'no_surahs_found'.tr,
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'try_different_search'.tr,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                controller.searchQuery.value = '';
                Navigator.pop(context); // Close search dialog if open
              },
              icon: const Icon(Icons.clear),
              label: Text('close'.tr, style: GoogleFonts.cairo()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'search_surah'.tr,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'type_surah_name'.tr,
            hintStyle: GoogleFonts.cairo(),
            prefixIcon: Icon(Icons.search, color: AppColors.primaryLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
          ),
          onChanged: (value) {
            controller.searchQuery.value = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.searchQuery.value = ''; // Clear search
              Navigator.pop(context);
            },
            child: Text(
              'close'.tr,
              style: GoogleFonts.cairo(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
