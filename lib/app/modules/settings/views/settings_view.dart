import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../auth/controllers/auth_controller.dart';

/// Settings view
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          Text('language'.tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Obx(
            () => Card(
              child: Column(
                children: settingsController.availableLanguages.map((lang) {
                  final isSelected =
                      settingsController.currentLanguage.value == lang['code'];
                  return ListTile(
                    title: Text(lang['name']!),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        settingsController.changeLanguage(lang['code']!),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Theme section
          Text('theme'.tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Obx(
            () => Card(
              child: Column(
                children: settingsController.availableThemes.map((theme) {
                  final isSelected =
                      settingsController.currentTheme.value == theme['code'];
                  return ListTile(
                    title: Text(theme['name']!),
                    leading: Icon(
                      theme['code'] == 'dark'
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => settingsController.changeTheme(theme['code']!),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notifications section
          Text(
            'notifications'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    title: Text('enable_notifications'.tr),
                    subtitle: Text('receive_daily_reminders'.tr),
                    value: settingsController.notificationsEnabled.value,
                    onChanged: (_) => settingsController.toggleNotifications(),
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    title: Text('sound'.tr),
                    subtitle: Text('enable_sound_effects'.tr),
                    value: settingsController.soundEnabled.value,
                    onChanged: (_) => settingsController.toggleSound(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account section
          Text('account'.tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('name'.tr),
                  subtitle: Text(authController.fullName),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text('email'.tr),
                  subtitle: Text(authController.username),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text('role'.tr),
                  subtitle: Text(
                    authController.isStudent ? 'student'.tr : 'teacher'.tr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout button
          ElevatedButton.icon(
            onPressed: () => authController.logout(),
            icon: const Icon(Icons.logout),
            label: Text('logout'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Developer Options
          if (true) // Visible for now, can be hidden later
            Card(
              color: Colors.grey[100],
              child: ExpansionTile(
                title: Text(
                  'developer_options'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.developer_mode),
                children: [
                  ListTile(
                    title: Text('load_test_data'.tr),
                    subtitle: const Text('Add 7 dummy students'),
                    trailing: const Icon(Icons.cloud_download),
                    onTap: () async {
                      await settingsController.seedTestData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('test_data_loaded'.tr),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // App version
          Center(
            child: Text(
              '${'version'.tr} 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
