import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dua_azkar/views/dua_azkar_view.dart';
import '../../prayer/views/prayer_times_view.dart';
import '../../tajweed/views/tajweed_view.dart';
import '../../about/views/about_view.dart';

/// More Menu View
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('more'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.menu_book,
            title: 'dua_azkar'.tr,
            subtitle: 'duas_and_azkar_desc'.tr,
            onTap: () => Get.to(() => const DuaAzkarView()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.access_time,
            title: 'prayer_times'.tr,
            subtitle: 'prayer_times_desc'.tr,
            onTap: () => Get.to(() => const PrayerTimesView()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.school,
            title: 'tajweed'.tr,
            subtitle: 'tajweed_desc'.tr,
            onTap: () => Get.to(() => const TajweedView()),
          ),
          const Divider(height: 32),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'about'.tr,
            subtitle: 'about_app_desc'.tr,
            onTap: () => Get.to(() => const AboutView()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
