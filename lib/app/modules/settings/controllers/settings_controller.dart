import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/services/notification_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

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

  /// Toggle circle notifications
  Future<void> toggleCircleNotifications() async {
    try {
      settings.value = settings.value.copyWith(
        circleNotifications: !settings.value.circleNotifications,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Error toggling circle notifications: $e');
    }
  }

  /// Toggle achievement notifications
  Future<void> toggleAchievementNotifications() async {
    try {
      settings.value = settings.value.copyWith(
        achievementNotifications: !settings.value.achievementNotifications,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Error toggling achievement notifications: $e');
    }
  }

  /// Change volume
  Future<void> changeVolume(double value) async {
    try {
      settings.value = settings.value.copyWith(audioVolume: value);
      await _saveSettings();
    } catch (e) {
      debugPrint('Error changing volume: $e');
    }
  }

  /// Update Profile Name
  Future<void> updateProfileName(String name) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(name: name);
      // Refresh user in AuthController if registered
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().currentUser.value = _authService.currentUser;
      }
      Get.snackbar('تم التحديث', 'تم تحديث اسم الملف الشخصي بنجاح');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar('خطأ', 'فشل تحديث الملف الشخصي');
    } finally {
      isLoading.value = false;
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
      debugPrint('Error reading mode toggle: $e');
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
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout();
      } else {
        await _authService.logout();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error logging out: $e');
      // Fallback navigation
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
