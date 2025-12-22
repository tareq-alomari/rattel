import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../settings/controllers/settings_controller.dart';

/// Teacher settings view
class TeacherSettingsView extends GetView<SettingsController> {
  const TeacherSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: Obx(() => ListView(
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
      )),
    );
  }
}
