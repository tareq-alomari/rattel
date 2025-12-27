import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
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
                      activeColor: AppColors.primaryLight,
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
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryLight,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: AppColors.primaryLight,
                  ),
                  child: Slider(value: 0.7, onChanged: (value) {}),
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
                      activeColor: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _SettingItem(
                    title: 'إشعارات الحلقة',
                    trailing: Switch(
                      value: controller.settings.value.notificationsEnabled,
                      onChanged: (_) => controller.toggleNotifications(),
                      activeColor: const Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _SettingItem(
                    title: 'إشعارات الإنجازات',
                    trailing: Switch(
                      value: controller.settings.value.notificationsEnabled,
                      onChanged: (_) => controller.toggleNotifications(),
                      activeColor: const Color(0xFF059669),
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
