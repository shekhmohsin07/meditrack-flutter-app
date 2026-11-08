// Navigation test. (Named widget_test.dart so that `flutter create .` does not add its own
// counter-app template with this name.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/router.dart';
import 'helpers/test_app.dart';

void main() {
  testWidgets('bottom navigation switches between the five tabs', (tester) async {
    await tester.pumpWidget(await buildTestApp(const MainShell(), overrides: dataOverrides()));
    await tester.pumpAndSettle();

    Finder navLabel(String text) => find.descendant(of: find.byType(NavigationBar), matching: find.text(text));
    for (final label in ['Home', 'Medicines', 'Schedule', 'Reports', 'Profile']) {
      expect(navLabel(label), findsOneWidget, reason: 'nav label $label');
    }

    await tester.tap(navLabel('Medicines'));
    await tester.pumpAndSettle();
    expect(find.text('Search medicines'), findsOneWidget);

    await tester.tap(navLabel('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);

    await tester.tap(navLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Family members'), findsOneWidget);
    expect(find.text('Test User'), findsWidgets);
  });
}
