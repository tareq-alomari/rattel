import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

import 'app/core/theme/app_theme.dart';
import 'app/core/translations/app_translations.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/badge_service.dart';
import 'app/data/services/database_service.dart';
import 'app/data/providers/database_helper.dart';
import 'app/data/providers/quran_data_loader.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/settings/controllers/settings_controller.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize database
  DatabaseHelper.initialize();
  await DatabaseHelper.instance.database;

  // Load Quran data if not already loaded
  if (!await QuranDataLoader.isQuranDataLoaded()) {
    debugPrint('🕌 First launch - loading Quran data...');
    await QuranDataLoader.loadQuranData();
  } else {
    debugPrint('✅ Quran data already loaded');
  }

  // Initialize badges
  await BadgeService.instance.initializeBadges();

  // Seed initial data
  print('🌱 Seeding initial data...');
  try {
    await DatabaseService.instance.seedDuas();
    await DatabaseService.instance.seedTajweedData();
  } catch (e) {
    print('❌ Error seeding data: $e');
  }

  // Initialize services
  await Get.putAsync(() => NotificationService().init());
  await AuthService.instance.init();

  // Initialize AuthController with current user
  final authController = Get.put(AuthController());
  authController.currentUser.value = AuthService.instance.currentUser;

  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();

  runApp(const RattelApp());
}

class RattelApp extends StatelessWidget {
  const RattelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rattel',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<SettingsController>().settings.value.theme == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light,

      // Localization
      locale: const Locale('ar', 'SA'), // Default to Arabic
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],

      // Routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
