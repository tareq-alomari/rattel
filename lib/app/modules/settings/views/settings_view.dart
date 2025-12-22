import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// Settings view
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text('language'.tr),
                trailing: DropdownButton<String>(
                  value: controller.settings.value.language,
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.changeLanguage(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Theme
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text('dark_mode'.tr),
                value: controller.settings.value.theme == 'dark',
                onChanged: (_) => controller.toggleTheme(),
              ),
            ),
            const SizedBox(height: 8),

            // Notifications
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: Text('notifications'.tr),
                value: controller.settings.value.notificationsEnabled,
                onChanged: (_) => controller.toggleNotifications(),
              ),
            ),
            const SizedBox(height: 8),

            // Daily Reminder
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.alarm),
                title: Text('daily_reminder'.tr),
                value: controller.settings.value.dailyReminderEnabled,
                onChanged: (_) => controller.toggleDailyReminder(),
              ),
            ),
            const SizedBox(height: 8),

            // Reading Mode
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.chrome_reader_mode),
                title: Text('reading_mode'.tr),
                value: controller.settings.value.readingMode,
                onChanged: (_) => controller.toggleReadingMode(),
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            ElevatedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
