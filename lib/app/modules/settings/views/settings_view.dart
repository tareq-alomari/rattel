import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

/// Settings View
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'خصص تجربتك في التطبيق',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // Profile Section (New)
            _ProfileSection(
              name: Get.find<AuthController>().currentUser.value?.name ?? '',
              onNameUpdate: (newName) => controller.updateProfileName(newName),
            ),

            const SizedBox(height: 16),

            // Appearance Section
            _SettingsSection(
              title: 'المظهر',
              icon: Icons.wb_sunny,
              iconColor: AppColors.iconOrange,
              children: [
                Obx(
                  () => _SettingItem(
                    title: 'الوضع الليلي',
                    trailing: Switch(
                      value: controller.settings.value.theme == 'dark',
                      onChanged: (_) => controller.toggleTheme(),
                      activeThumbColor: AppColors.primaryLight,
                      key: const Key('settings_theme_switch'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Audio Section
            _SettingsSection(
              title: 'الصوت',
              icon: Icons.volume_up,
              iconColor: AppColors.iconGreen,
              children: [
                Text(
                  'مستوى الصوت',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(
                  () => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryLight,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.primaryLight,
                    ),
                    child: Slider(
                      value: controller.settings.value.audioVolume,
                      onChanged: (value) => controller.changeVolume(value),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notifications Section
            _SettingsSection(
              title: 'الإشعارات',
              icon: Icons.notifications,
              iconColor: AppColors.iconBlue,
              children: [
                Obx(
                  () => _SettingItem(
                    title: 'تذكير يومي',
                    trailing: Switch(
                      value: controller.settings.value.dailyReminderEnabled,
                      onChanged: (_) => controller.toggleDailyReminder(),
                      activeThumbColor: AppColors.primaryLight,
                      key: const Key('settings_notifications_switch'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _SettingItem(
                    title: 'إشعارات الحلقة',
                    trailing: Switch(
                      value: controller.settings.value.circleNotifications,
                      onChanged: (_) => controller.toggleCircleNotifications(),
                      activeThumbColor: const Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _SettingItem(
                    title: 'إشعارات الإنجازات',
                    trailing: Switch(
                      value: controller.settings.value.achievementNotifications,
                      onChanged: (_) =>
                          controller.toggleAchievementNotifications(),
                      activeThumbColor: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Language Section
            _SettingsSection(
              title: 'اللغة والتنسيق',
              icon: Icons.language,
              iconColor: AppColors.iconPurple,
              children: [
                Text(
                  'اللغة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: controller.settings.value.language,
                      isExpanded: true,
                      underline: const SizedBox(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _SettingItem({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        trailing,
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String name;
  final Function(String) onNameUpdate;

  const _ProfileSection({required this.name, required this.onNameUpdate});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: name,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.primaryLight, size: 24),
              const SizedBox(width: 12),
              Text(
                'الملف الشخصي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('settings_name_field'),
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              labelStyle: GoogleFonts.cairo(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save, color: AppColors.primaryLight),
                onPressed: () => onNameUpdate(nameController.text),
              ),
            ),
            style: GoogleFonts.cairo(),
          ),
        ],
      ),
    );
  }
}
