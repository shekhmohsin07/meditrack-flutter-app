// Integration test (runs the REAL app on an emulator / phone, with no Firebase needed):
//   flutter test integration_test/offline_flow_test.dart
//
// Before running, allow notifications once so Android's permission pop-up does not block the test:
//   adb shell pm grant com.meditrack.meditrack android.permission.POST_NOTIFICATIONS
//
// DRAFT: written without being able to run it. Finders use the English UI text; if a step fails,
// the usual fix is adjusting a finder to match the screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meditrack/main.dart' as app;

Future<void> settle(WidgetTester t) => t.pumpAndSettle(const Duration(milliseconds: 300), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 20));

Future<void> tapText(WidgetTester t, String text) async {
  await t.ensureVisible(find.text(text).first);
  await t.tap(find.text(text).first);
  await settle(t);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline: medicine CRUD, schedule, intake, stock deduction, health record', (t) async {
    final name = 'ITest-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final renamed = '$name-edited';

    app.main();
    await settle(t);

    // Onboarding -> offline account
    if (find.text('Skip').evaluate().isNotEmpty) await tapText(t, 'Skip');
    await tapText(t, 'Continue offline (no cloud)');
    expect(find.text('Home'), findsWidgets);

    // --- Add medicine
    await tapText(t, 'Medicines');
    await t.tap(find.byTooltip('Add medicine'));
    await settle(t);
    await t.enterText(find.widgetWithText(TextFormField, 'Medicine name'), name);
    await t.enterText(find.widgetWithText(TextFormField, 'Dosage (as prescribed)'), '1 tablet');
    await tapText(t, 'Save');
    expect(find.text(name), findsOneWidget);

    // --- Edit medicine (list -> details -> edit)
    await t.tap(find.text(name));
    await settle(t);
    await t.tap(find.byTooltip('Edit medicine'));
    await settle(t);
    await t.enterText(find.widgetWithText(TextFormField, 'Medicine name'), renamed);
    await tapText(t, 'Save');
    expect(find.text(renamed), findsOneWidget);

    // --- Set up stock (10 units)
    await t.tap(find.byTooltip('Stock & expiry'));
    await settle(t);
    await tapText(t, 'Set up stock');
    await t.enterText(find.widgetWithText(TextFormField, 'Quantity you have now'), '10');
    await tapText(t, 'Save');
    expect(find.text('10 / 10 left'), findsOneWidget);
    await t.pageBack();
    await settle(t);

    // --- Schedule one reminder for "now"
    await tapText(t, 'Schedule');
    await t.tap(find.byTooltip('Add schedule'));
    await settle(t);
    await t.tap(find.byType(DropdownButtonFormField<String>).first);
    await settle(t);
    await t.tap(find.textContaining(renamed).last);
    await settle(t);
    await tapText(t, 'Add time');
    await tapText(t, 'OK'); // time picker: keep the current time
    await tapText(t, 'Save');

    // --- Record intake (Taken) from the day list
    expect(find.text(renamed), findsWidgets);
    await t.tap(find.byIcon(Icons.more_vert).first);
    await settle(t);
    await tapText(t, 'Mark as taken');

    // --- Stock must now be 9 (exactly one deduction)
    await tapText(t, 'Medicines');
    await t.tap(find.byTooltip('Stock & expiry'));
    await settle(t);
    expect(find.text('9 / 10 left'), findsOneWidget);
    await t.pageBack();
    await settle(t);

    // --- Health record
    await tapText(t, 'Profile');
    await tapText(t, 'Health records');
    await t.tap(find.byTooltip('Add health record'));
    await settle(t);
    await t.enterText(find.widgetWithText(TextFormField, 'Systolic (upper)'), '120');
    await t.enterText(find.widgetWithText(TextFormField, 'Diastolic (lower)'), '80');
    await tapText(t, 'Save');
    expect(find.text('120/80 mmHg'), findsOneWidget);
    await t.pageBack();
    await settle(t);

    // --- Delete the medicine
    await tapText(t, 'Medicines');
    await t.tap(find.byIcon(Icons.delete_outline).first);
    await settle(t);
    await tapText(t, 'Delete');
    expect(find.text(renamed), findsNothing);
  });
}
