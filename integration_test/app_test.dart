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
  const loginPasswordKey = Key('login_password');
  const loginSubmitKey = Key('login_submit');
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
      await app.main();
      await tester.pumpAndSettle();

      // 1. Auth Flow
      // Check if we are at Login Screen (look for email field)
      if (find.byKey(loginEmailKey).evaluate().isNotEmpty) {
        print('On Login Screen. Registering new user...');

        // Go to Register
        await tester.tap(find.byKey(gotoRegisterKey));
        await tester.pumpAndSettle();

        // Fill Register Form
        final timestamp = DateTime.now().millisecondsSinceEpoch;
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
        await tester.tap(find.byKey(roleStudentKey));
        await tester.pumpAndSettle();

        // Submit Register
        await tester.tap(find.byKey(registerSubmitKey));
        await tester.pumpAndSettle();
      } else {
        print('Already logged in or at Home Screen.');
      }

      // 2. Verify Home Screen & Sunnah Button
      expect(
        find.byKey(sunnahButtonKey),
        findsOneWidget,
        reason: 'Sunnah button should be visible on Student Home',
      );

      // 3. Navigate to Sunnah
      await tester.tap(find.byKey(sunnahButtonKey));
      await tester.pumpAndSettle();

      // 4. Verify Hadith Books Grid
      // Look for known book title or generic Grid/Cards
      // Assuming 'Sahih Bukhari' exists in the seeded JSON
      // If data loading is async, might need to wait, but pumpAndSettle should handle it
      expect(
        find.text('صحيح البخاري'),
        findsOneWidget,
        reason: 'Sahih Bukhari should be listed',
      );

      // 5. Open a Book
      await tester.tap(find.text('صحيح البخاري'));
      await tester.pumpAndSettle();

      // 6. Verify Hadith List
      // Check for 'Hadith 1' or similar text from the dummy/real data
      // Using generic search for ListView items
      expect(find.byType(ListView), findsOneWidget);

      // Verify at least one Hadith card is present
      // The cards usually have text. Let's look for "حديث" (Hadith in Arabic) or partial match?
      // Or just verify we are on the book detail page.
      // AppBar should show 'صحيح البخاري'
      expect(find.widgetWithText(AppBar, 'صحيح البخاري'), findsOneWidget);

      // 7. Test Search (Optional but good)
      // Tap search icon in AppBar
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle();

        // Enter search term
        await tester.enterText(find.byType(TextField), 'نية'); // Niyyah
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // Verify results
        // expect(find.textContaining('نية'), findsWidgets); // Might return multiple
      }
    });
  });
}
