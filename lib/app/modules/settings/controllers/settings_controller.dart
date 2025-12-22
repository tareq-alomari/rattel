import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/services/notification_service.dart';

/// Settings controller for user preferences
class SettingsController extends GetxController {
  final AuthService _authService = AuthService.instance;
  final DatabaseService _dbService = DatabaseService.instance;
  late final NotificationService _notificationService;

  final Rx<SettingsModel> settings = SettingsModel(userId: 0).obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
  }

  /// Load user settings
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.userId;

      if (userId != null) {
        final userSettings = await _dbService.getUserSettings(userId);
        if (userSettings != null) {
          settings.value = userSettings;
        } else {
          settings.value = SettingsModel.defaultSettings(userId);
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      Get.updateLocale(Locale(languageCode));
      settings.value = settings.value.copyWith(language: languageCode);
      await _saveSettings();
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    try {
      final newTheme = settings.value.theme == 'dark' ? 'light' : 'dark';
      Get.changeThemeMode(
        newTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      );
      settings.value = settings.value.copyWith(theme: newTheme);
      await _saveSettings();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    try {
      settings.value = settings.value.copyWith(
        notificationsEnabled: !settings.value.notificationsEnabled,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
    }
  }

  /// Toggle daily reminder
  Future<void> toggleDailyReminder() async {
    try {
      final newValue = !settings.value.dailyReminderEnabled;
      settings.value = settings.value.copyWith(dailyReminderEnabled: newValue);
      await _saveSettings();

      if (newValue) {
        await _notificationService.scheduleDailyReminder(
          hour: 18,
          minute: 0,
          title: 'notification_daily_title'.tr,
          body: 'notification_daily_body'.tr,
        );
      } else {
        await _notificationService.cancelDailyReminder();
      }
    } catch (e) {
      debugPrint('Error toggling daily reminder: $e');
    }
  }

  /// Toggle reading mode
  Future<void> toggleReadingMode() async {
    try {
      settings.value = settings.value.copyWith(
        readingMode: !settings.value.readingMode,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Error toggling reading mode: $e');
    }
  }

  /// Save settings
  Future<void> _saveSettings() async {
    try {
      final userId = _authService.currentUser?.userId;
      if (userId != null) {
        await _dbService.saveUserSettings(userId, settings.value);
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
