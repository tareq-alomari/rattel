import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'azkar_list_view.dart';
import 'azkar_statistics_view.dart';
import '../../prayer_times/views/prayer_times_view.dart';
import '../../tajweed/views/tajweed_view.dart';

/// Dua and Azkar View - Placeholder
/// Dua and Azkar View - Placeholder
class DuaAzkarView extends StatelessWidget {
  const DuaAzkarView({super.key});

  @override
  Widget build(BuildContext context) {
    // List of items with gradient colors
    final items = [
      {
        'title': 'morning_azkar'.tr,
        'icon': Icons.wb_sunny,
        'category': 'morning',
        'colors': [Colors.orange.shade400, Colors.orange.shade700],
      },
      {
        'title': 'evening_azkar'.tr,
        'icon': Icons.nightlight_round,
        'category': 'evening',
        'colors': [Colors.indigo.shade400, Colors.indigo.shade800],
      },
      {
        'title': 'prayer_azkar'.tr,
        'icon': Icons.mosque,
        'category': 'prayer',
        'colors': [Colors.teal.shade500, Colors.teal.shade800],
      },
      {
        'title': 'sleep_azkar'.tr,
        'icon': Icons.bed,
        'category': 'sleep',
        'colors': [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
      },
      {
        'title': 'waking_azkar'.tr,
        'icon': Icons.alarm,
        'category': 'waking_up',
        'colors': [Colors.amber.shade500, Colors.amber.shade800],
      },
      {
        'title': 'food_azkar'.tr,
        'icon': Icons.restaurant,
        'category': 'food',
        'colors': [Colors.red.shade400, Colors.red.shade700],
      },
      {
        'title': 'tajweed_rules'.tr,
        'icon': Icons.menu_book_rounded,
        'category': 'tajweed',
        'colors': [Colors.brown.shade400, Colors.brown.shade700],
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'dua_azkar'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            expandedHeight: 120,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const AzkarStatisticsView(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return _buildGradientCard(
                  context,
                  item['title'] as String,
                  item['icon'] as IconData,
                  item['category'] as String,
                  item['colors'] as List<Color>,
                );
              }, childCount: items.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildGradientCard(
    BuildContext context,
    String title,
    IconData icon,
    String category,
    List<Color> colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (category == 'prayer_times') {
              Get.to(() => const PrayerTimesView());
            } else if (category == 'tajweed') {
              Get.to(() => const TajweedView());
            } else {
              Get.to(() => AzkarListView(category: category, title: title));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
