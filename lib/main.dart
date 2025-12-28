import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
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
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Desktop Check (Mandatory for Desktop, No effect on mobile/android)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    ffi.sqfliteFfiInit();
    databaseFactory = ffi.databaseFactoryFfi;
  }

  // 2. Firebase Initialization (with timeout to prevent launch hang)
  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    debugPrint('✅ Firebase Initialized');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('❌ Firebase Initialization Failed or Timed out: $e');
  }

  // 3. Dependency Injection (CRITICAL ORDER)
  // These must be ready before SettingsController starts
  Get.put(TafseerService());
  Get.put(AudioService());

  // Register NotificationService synchronously and then init it
  final notificationService = Get.put(NotificationService());
  await notificationService.init();

  // Register AuthService and wait for its local init
  await AuthService.instance.init();

  // Now we can safely initialize Controllers
  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();

  final authController = Get.put(AuthController());
  authController.currentUser.value = AuthService.instance.currentUser;

  // 4. Start the UI immediately
  runApp(const RattelApp());

  // 5. Heavy Background Loading
  _initializeHeavyData();
}

Future<void> _initializeHeavyData() async {
  try {
    // Database and Data loaders are heavy, run them in background
    DatabaseHelper.initialize();
    await DatabaseHelper.instance.database;

    if (!await QuranDataLoader.isQuranDataLoaded()) {
      debugPrint('🕌 First launch - loading Quran data...');
      await QuranDataLoader.loadQuranData();
    }

    await Future.wait([
      SunnahDataLoader.loadSunnahData(),
      _loadAzkarIfneeded(),
      _loadNamesIfneeded(),
      Get.putAsync(() => GamificationService().init()),
    ]);

    debugPrint('🚀 Heavy initialization complete');
  } catch (e) {
    debugPrint('❌ Background Init Error: $e');
  }
}

Future<void> _loadAzkarIfneeded() async {
  if (!await AzkarDataLoader.isAzkarDataLoaded()) {
    await AzkarDataLoader.loadAzkarData();
  }
}

Future<void> _loadNamesIfneeded() async {
  if (!await AllahNamesDataLoader.isAllahNamesLoaded()) {
    await AllahNamesDataLoader.loadAllahNamesData();
  }
}

class RattelApp extends StatelessWidget {
  const RattelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rattel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(),
      locale: _getLocale(),
      translations: AppTranslations(),
      fallbackLocale: const Locale('ar', 'SA'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  ThemeMode _getThemeMode() {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      return settings.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      return ThemeMode.light;
    }
  }

  Locale _getLocale() {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      return Locale(settings.language);
    } catch (_) {
      return const Locale('ar', 'SA');
    }
  }
}
