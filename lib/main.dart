import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

import 'app/core/theme/app_theme.dart';
import 'app/core/translations/app_translations.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/gamification_service.dart';
import 'app/data/providers/database_helper.dart';
import 'app/data/providers/quran_data_loader.dart';
import 'app/data/providers/sunnah_data_loader.dart';
import 'app/data/providers/azkar_data_loader.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/settings/controllers/settings_controller.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/tafseer_service.dart';
import 'app/data/services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for desktop platforms (not web)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize database
  DatabaseHelper.initialize();
  await DatabaseHelper.instance.database;

  // Load Quran data if not already loaded
  try {
    if (!await QuranDataLoader.isQuranDataLoaded()) {
      debugPrint('🕌 First launch - loading Quran data...');
      await QuranDataLoader.loadQuranData();
    } else {
      debugPrint('✅ Quran data already loaded');
    }
  } catch (e) {
    debugPrint('❌ Failed to load Quran data: $e');
  }

  // Load Sunnah data
  try {
    await SunnahDataLoader.loadSunnahData();
  } catch (e) {
    debugPrint('❌ Failed to load Sunnah data: $e');
  }

  // Load Azkar data
  try {
    if (!await AzkarDataLoader.isAzkarDataLoaded()) {
      debugPrint('🤲 Loading Azkar data...');
      await AzkarDataLoader.loadAzkarData();
    } else {
      debugPrint('✅ Azkar data already loaded');
    }
  } catch (e) {
    debugPrint('❌ Failed to load Azkar data: $e');
  }

  // Load Allah Names data
  try {
    if (!await AllahNamesDataLoader.isAllahNamesLoaded()) {
      debugPrint('📿 Loading Allah Names...');
      await AllahNamesDataLoader.loadAllahNamesData();
    } else {
      debugPrint('✅ Allah Names already loaded');
    }
  } catch (e) {
    debugPrint('❌ Failed to load Allah Names: $e');
  }

  // Initialize badges (via GamificationService)
  await Get.putAsync(() => GamificationService().init());

  // Initialize services
  await Get.putAsync(() => NotificationService().init());
  Get.put(TafseerService());
  Get.put(AudioService());
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
      locale: Locale(Get.find<SettingsController>().settings.value.language),
      translations: AppTranslations(),
      fallbackLocale: const Locale('ar', 'SA'),
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
