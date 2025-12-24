import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'azkar_list_view.dart';
import 'azkar_statistics_view.dart';
import '../../prayer_times/views/prayer_times_view.dart';
import '../../tajweed/views/tajweed_view.dart';

/// Dua and Azkar View - Placeholder
class DuaAzkarView extends StatelessWidget {
  const DuaAzkarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('dua_azkar'.tr)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Icon(
                Icons.menu_book,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'dua_azkar'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Statistics Section
              const AzkarStatisticsView(),

              const SizedBox(height: 16),

              // Categories
              _buildCategoryCard(
                context,
                'morning_azkar'.tr,
                Icons.wb_sunny,
                'morning',
              ),
              _buildCategoryCard(
                context,
                'evening_azkar'.tr,
                Icons.nightlight,
                'evening',
              ),
              _buildCategoryCard(
                context,
                'prayer_azkar'.tr,
                Icons.mosque,
                'prayer',
              ),
              _buildCategoryCard(context, 'sleep_azkar'.tr, Icons.bed, 'sleep'),
              _buildCategoryCard(
                context,
                'waking_azkar'.tr,
                Icons.access_alarm,
                'waking_up',
              ),
              _buildCategoryCard(
                context,
                'food_azkar'.tr,
                Icons.restaurant,
                'food',
              ),
              _buildCategoryCard(
                context,
                'tajweed_rules'.tr,
                Icons.menu_book_outlined,
                'tajweed',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (category == 'prayer_times') {
              Get.to(() => const PrayerTimesView());
            } else if (category == 'tajweed') {
              Get.to(() => const TajweedView());
            } else {
              Get.to(() => AzkarListView(category: category, title: title));
            }
          },
        ),
      ),
    );
  }
}
