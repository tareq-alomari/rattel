import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/settings_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/database_service.dart';

/// Settings controller for app-wide settings
class SettingsController extends GetxController {
  // Observable states
  final RxString currentLanguage = 'ar'.obs;
  final RxString currentTheme = 'light'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool soundEnabled = true.obs;

  // Settings model observable (initialized with default userId 0)
  final Rx<SettingsModel> settings = SettingsModel(
    userId: 0,
    language: 'ar',
    theme: 'light',
    notificationsEnabled: true,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load settings from SharedPreferences (public method)
  Future<void> loadSettings() async {
    await _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      currentLanguage.value = prefs.getString('app_language') ?? 'ar';
      currentTheme.value = prefs.getString('app_theme') ?? 'light';
      notificationsEnabled.value =
          prefs.getBool('notifications_enabled') ?? true;
      soundEnabled.value = prefs.getBool('sound_enabled') ?? true;

      // Update settings model
      settings.value = SettingsModel(
        userId: 0, // Default user ID, will be updated when user logs in
        language: currentLanguage.value,
        theme: currentTheme.value,
        notificationsEnabled: notificationsEnabled.value,
      );

      // Apply loaded settings
      _applyLanguage();
      _applyTheme();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('app_language', currentLanguage.value);
      await prefs.setString('app_theme', currentTheme.value);
      await prefs.setBool('notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('sound_enabled', soundEnabled.value);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    try {
      currentLanguage.value = languageCode;
      await _saveSettings();
      _applyLanguage();

      Get.snackbar(
        'language_changed'.tr,
        'language_changed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Apply language
  void _applyLanguage() {
    final locale = currentLanguage.value == 'ar'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');

    Get.updateLocale(locale);
  }

  /// Change app theme
  Future<void> changeTheme(String theme) async {
    try {
      currentTheme.value = theme;
      await _saveSettings();
      _applyTheme();

      Get.snackbar(
        'theme_changed'.tr,
        'theme_changed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error changing theme: $e');
    }
  }

  /// Apply theme
  void _applyTheme() {
    final themeMode = currentTheme.value == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;

    Get.changeThemeMode(themeMode);
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    notificationsEnabled.value = !notificationsEnabled.value;
    await _saveSettings();
  }

  /// Toggle sound
  Future<void> toggleSound() async {
    soundEnabled.value = !soundEnabled.value;
    await _saveSettings();
  }

  /// Get available languages
  List<Map<String, String>> get availableLanguages => [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
  ];

  /// Get available themes
  List<Map<String, String>> get availableThemes => [
    {'code': 'light', 'name': 'light_theme'.tr},
    {'code': 'dark', 'name': 'dark_theme'.tr},
  ];

  /// Check if current language is Arabic
  bool get isArabic => currentLanguage.value == 'ar';

  /// Check if current theme is dark
  bool get isDark => currentTheme.value == 'dark';

  /// Toggle theme between light and dark
  Future<void> toggleTheme() async {
    final newTheme = currentTheme.value == 'dark' ? 'light' : 'dark';
    await changeTheme(newTheme);
  }

  /// Seed test data
  Future<void> seedTestData() async {
    try {
      final dbService = DatabaseService.instance;
      await dbService.seedTestData();
    } catch (e) {
      debugPrint('Error seeding test data: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
