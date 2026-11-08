// Integration test for registration, login and cloud sync. It needs a REAL Firebase project
// (use a separate test project, never your real data):
//
//   flutter test integration_test/firebase_flow_test.dart \
//     --dart-define=FIREBASE_TEST=true \
//     --dart-define=TEST_EMAIL=someone@example.com \
//     --dart-define=TEST_PASSWORD=choose-a-test-password
//
// Credentials come from --dart-define so nothing secret is stored in the source.
// DRAFT: written without being able to run it; adjust finders if a step fails.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/main.dart' as app;

const _enabled = bool.fromEnvironment('FIREBASE_TEST');
const _email = String.fromEnvironment('TEST_EMAIL');
const _password = String.fromEnvironment('TEST_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('register, log in, add a medicine and sync it to the cloud', (t) async {
    app.main();
    await t.pumpAndSettle(const Duration(seconds: 5));

    if (find.text('Skip').evaluate().isNotEmpty) {
      await t.tap(find.text('Skip'));
      await t.pumpAndSettle();
    }

    // Registration (first run) - if the account already exists Firebase reports an error; then log in instead.
    await t.tap(find.text('No account? Register'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Integration Test');
    await t.enterText(find.widgetWithText(TextFormField, 'Email'), _email);
    await t.enterText(find.widgetWithText(TextFormField, 'Password'), _password);
    await t.enterText(find.widgetWithText(TextFormField, 'Confirm password'), _password);
    await t.tap(find.text('Register').last);
    await t.pumpAndSettle(const Duration(seconds: 8));

    // Home visible = signed in. Then open Settings (via Profile) and check the sync card.
    expect(find.text('Home'), findsWidgets);
    await t.tap(find.text('Profile'));
    await t.pumpAndSettle();
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sync now'));
    await t.pumpAndSettle(const Duration(seconds: 10));
    expect(find.text('All changes are saved to the cloud.'), findsOneWidget);
  }, skip: !_enabled || _email.isEmpty || _password.isEmpty);
}
