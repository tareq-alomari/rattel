import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quran_controller.dart';

/// Quran reading settings screen
class QuranSettingsView extends StatelessWidget {
  const QuranSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuranController>();

    return Scaffold(
      appBar: AppBar(title: Text('quran_settings'.tr)),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Font Size Section
            _buildSectionHeader('font_sizes'.tr, Icons.format_size),
            const SizedBox(height: 8),
            _buildFontSizeCard(
              'arabic_text'.tr,
              controller.settings.value.arabicFontSize,
              (value) => controller.updateArabicFontSize(value),
            ),
            const SizedBox(height: 12),
            _buildFontSizeCard(
              'translation_text'.tr,
              controller.settings.value.translationFontSize,
              (value) => controller.updateTranslationFontSize(value),
            ),

            const SizedBox(height: 24),

            // Display Options
            _buildSectionHeader('display_options'.tr, Icons.visibility),
            const SizedBox(height: 8),
            _buildSwitchCard(
              'show_translations'.tr,
              controller.settings.value.showTranslation,
              controller.toggleTranslation,
              Icons.translate,
            ),
            const SizedBox(height: 12),
            _buildSwitchCard(
              'show_transliteration'.tr,
              controller.settings.value.showTransliteration,
              controller.toggleTransliteration,
              Icons.text_fields,
            ),

            const SizedBox(height: 24),

            // Language Selection
            _buildSectionHeader('translation_languages'.tr, Icons.language),
            const SizedBox(height: 8),
            _buildLanguageSelection(controller),

            const SizedBox(height: 24),

            // Theme Selection
            _buildSectionHeader('reading_theme'.tr, Icons.palette),
            const SizedBox(height: 8),
            _buildThemeSelection(controller),

            const SizedBox(height: 24),

            // Available Languages Info
            _buildInfoCard(
              'available_languages'.tr,
              '${controller.availableLanguages.length} ${'available_languages_info'.tr}',
              Icons.info_outline,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeCard(
    String label,
    double currentSize,
    Function(double) onChanged,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${currentSize.toInt()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: currentSize,
              min: label == 'arabic_text'.tr
                  ? 16.0
                  : 12.0, // Check generated key
              max: label == 'arabic_text'.tr
                  ? 48.0
                  : 24.0, // Increased max for Arabic
              divisions: 32,
              label: currentSize.toInt().toString(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
    String label,
    bool value,
    VoidCallback onToggle,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Get.theme.colorScheme.primary),
        title: Text(label),
        trailing: Switch(value: value, onChanged: (_) => onToggle()),
        onTap: onToggle,
      ),
    );
  }

  Widget _buildLanguageSelection(QuranController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_translation_languages'.tr,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableLanguages.map((lang) {
                final isSelected = controller.settings.value.selectedLanguages
                    .contains(lang);
                return FilterChip(
                  label: Text(controller.getLanguageName(lang)),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleLanguage(lang),
                  selectedColor: Get.theme.colorScheme.primary.withOpacity(0.3),
                  checkmarkColor: Get.theme.colorScheme.primary,
                );
              }).toList(),
            ),
            if (controller.settings.value.selectedLanguages.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'select_at_least_one_language'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelection(QuranController controller) {
    final themes = [
      {'name': 'light_mode'.tr, 'value': 'light', 'icon': Icons.light_mode},
      {'name': 'dark_mode'.tr, 'value': 'dark', 'icon': Icons.dark_mode},
      {'name': 'sepia_mode'.tr, 'value': 'sepia', 'icon': Icons.auto_stories},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your reading theme:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: themes.map((theme) {
                final isSelected =
                    controller.settings.value.theme == theme['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () =>
                          controller.changeTheme(theme['value'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Get.theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Get.theme.colorScheme.primary
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              theme['icon'] as IconData,
                              color: isSelected
                                  ? Get.theme.colorScheme.primary
                                  : Colors.grey[600],
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              theme['name'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Get.theme.colorScheme.primary
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
