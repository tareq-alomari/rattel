import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rattel/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Define Keys
  const loginEmailKey = Key('login_email');

  const gotoRegisterKey = Key('goto_register');

  const registerNameKey = Key('register_name');
  const registerEmailKey = Key('register_email');
  const registerPasswordKey = Key('register_password');
  const roleStudentKey = Key('role_student');
  const registerSubmitKey = Key('register_submit');

  const sunnahButtonKey = Key('quick_action_sunnah');

  group('Sunnah Module Walkthrough', () {
    testWidgets('Full Walkthrough: Auth -> Home -> Sunnah -> Details', (
      tester,
    ) async {
      // Fix: Some versions of Flutter/Analyzer might see app.main() as void
      // even if it's Future<void>. In integration tests, we usually don't await
      // the entire app execution but rather pump frames.
      app.main();
      await tester.pumpAndSettle();

      // 0. Setup
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Auth Flow
      // Check if we are at Login Screen (look for email field)
      if (find.byKey(loginEmailKey).evaluate().isNotEmpty) {
        debugPrint('On Login Screen. Registering new user...');

        // Go to Register
        await tester.tap(find.byKey(gotoRegisterKey));
        await tester.pumpAndSettle();

        // Fill Register Form
        await tester.enterText(
          find.byKey(registerNameKey),
          'Test User $timestamp',
        );
        await tester.enterText(
          find.byKey(registerEmailKey),
          'test_$timestamp@example.com',
        );
        await tester.enterText(find.byKey(registerPasswordKey), 'password123');

        // Select Student Role (default might vary, so be explicit)
        final studentRole = find.byKey(roleStudentKey);
        await tester.ensureVisible(studentRole);
        await tester.tap(studentRole);
        await tester.pumpAndSettle();

        // Submit Register
        final submitButton = find.byKey(registerSubmitKey);
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);

        // Wait for registration to complete and navigate to home
        // Registration takes time (Firebase + DB)
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      } else {
        debugPrint('Already logged in or at Home Screen.');
      }

      // 2. Verify Home Screen & Sunnah Button
      debugPrint('Verifying Home Screen...');
      await tester.pump(const Duration(seconds: 8)); // increased wait

      final sunnahButton = find.byKey(sunnahButtonKey);

      // Check if we stumbled
      if (sunnahButton.evaluate().isEmpty) {
        debugPrint('Sunnah not found immediately. Diagnosing...');

        // Are we on Register Screen (Submit button visible)?
        if (find.byKey(registerSubmitKey).hitTestable().evaluate().isNotEmpty) {
          debugPrint('ℹ️ Still on Register Form (visible).');
          // Check for ANY snackbar text
          final snackbars = find.byType(SnackBar);
          if (snackbars.evaluate().isNotEmpty) {
            debugPrint('⚠️ Snackbar found!');
            // Try to print text inside snackbar
            // Use a wider text finder
            final allText = find
                .byType(Text)
                .evaluate()
                .map((e) => (e.widget as Text).data)
                .join(', ');
            debugPrint('Screen Text: $allText');
          }
        }
        // Are we on Login Form (visible)?
        else if (find
            .byKey(const Key('login_submit'))
            .hitTestable()
            .evaluate()
            .isNotEmpty) {
          debugPrint('ℹ️ On Login Form (visible). Falling back to login...');
          await tester.enterText(
            find.byKey(const Key('login_email')),
            'test_$timestamp@example.com',
          );
          await tester.enterText(
            find.byKey(const Key('login_password')),
            'password123',
          );
          await tester.tap(find.byKey(const Key('login_submit')));
          await tester.pump(const Duration(seconds: 5));
        }
      }

      // Wait loop
      int retry = 0;
      while (sunnahButton.evaluate().isEmpty && retry < 10) {
        debugPrint('Sunnah button not found yet, retrying... ($retry)');
        await tester.pump(const Duration(seconds: 1));
        retry++;
      }

      if (sunnahButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(sunnahButton);
      } else {
        debugPrint('FAILED: Sunnah button still not found.');
        // Dump ALL text
        final allText = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data ?? "")
            .toList();
        debugPrint('DUMPING SCREEN TEXT: $allText');
      }

      expect(
        sunnahButton,
        findsOneWidget,
        reason: 'Sunnah button should be visible on Student Home',
      );

      // 3. Test Quran Module
      debugPrint('Testing Quran Module...');
      final quranButton = find.byKey(const Key('quick_action_quran'));
      await tester.ensureVisible(quranButton);
      await tester.tap(quranButton);
      await tester.pumpAndSettle();

      // Verify Surah List (assuming Al-Fatihah is first)
      expect(find.text('الفاتحة'), findsOneWidget);

      // Test Filter
      await tester.tap(find.byKey(const Key('filter_medinan')));
      await tester.pumpAndSettle();
      expect(find.text('البقرة'), findsOneWidget);

      // Go back to Home using Drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      ); // Open Drawer
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_home')));
      await tester.pumpAndSettle();

      // 4. Test Azkar Module
      debugPrint('Testing Azkar Module...');
      final azkarButton = find.byKey(const Key('quick_action_azkar'));
      await tester.ensureVisible(azkarButton);
      await tester.tap(azkarButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('azkar_morning')), findsOneWidget);
      await tester.tap(find.byKey(const Key('azkar_morning')));
      await tester.pumpAndSettle();

      // Go back to Azkar Main
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      // Back to Home via Drawer
      await tester.dragFrom(const Offset(0, 300), const Offset(300, 300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_home')));
      await tester.pumpAndSettle();

      // 5. Test Allah Names
      debugPrint('Testing Allah Names Module...');
      final namesButton = find.byKey(const Key('quick_action_names'));
      await tester.ensureVisible(namesButton);
      await tester.tap(namesButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('allah_name_0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('allah_name_0')));
      await tester.pumpAndSettle();

      // Go to Settings via Drawer
      await tester.dragFrom(const Offset(0, 300), const Offset(300, 300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_settings')));
      await tester.pumpAndSettle();

      // 6. Test Settings
      debugPrint('Testing Settings Module...');
      expect(find.byKey(const Key('settings_theme_switch')), findsOneWidget);

      // Toggle Theme
      await tester.tap(find.byKey(const Key('settings_theme_switch')));
      await tester.pumpAndSettle();

      // Update Name
      await tester.enterText(
        find.byKey(const Key('settings_name_field')),
        'Full Test User',
      );
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // 7. Test Sunnah Module
      debugPrint('Testing Sunnah Module...');
      await tester.dragFrom(const Offset(0, 300), const Offset(300, 300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_hadith')));
      await tester.pumpAndSettle();

      expect(find.text('صحيح البخاري'), findsOneWidget);
      await tester.tap(find.text('صحيح البخاري'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'صحيح البخاري'), findsOneWidget);
      debugPrint('✅ All Integration Tests Passed Successfully!');
    });
  });
}
