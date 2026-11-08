import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/features/settings/presentation/settings_screen.dart';
import 'helpers/test_app.dart';

void main() {
  test('official palette is unchanged', () {
    expect(AppColors.primaryBlue, const Color(0xFF2563EB));
    expect(AppColors.primaryDark, const Color(0xFF1D4ED8));
    expect(AppColors.lightBlue, const Color(0xFFDBEAFE));
    expect(AppColors.darkNavy, const Color(0xFF172554));
    expect(AppColors.background, const Color(0xFFF7F9FC));
    expect(AppColors.success, const Color(0xFF16A34A));
    expect(AppColors.warning, const Color(0xFFF59E0B));
    expect(AppColors.danger, const Color(0xFFDC2626));
    expect(AppColors.info, const Color(0xFF0891B2));
    expect(AppColors.darkBackground, const Color(0xFF0F172A));
    expect(AppColors.darkCard, const Color(0xFF1E293B));
    expect(AppColors.darkPrimary, const Color(0xFF3B82F6));
  });

  testWidgets('dark mode switch changes the theme and is remembered', (tester) async {
    await tester.pumpWidget(await buildTestApp(const SettingsScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();
    final element = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(element).brightness, Brightness.light);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(SettingsScreen))).brightness, Brightness.dark);

    final container = ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));
    expect(container.read(sharedPrefsProvider).getString('theme_mode'), 'dark');
  });

  testWidgets('language switch changes the screen to Bangla', (tester) async {
    await tester.pumpWidget(await buildTestApp(const SettingsScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();
    expect(find.text('সেটিংস'), findsWidgets);
    expect(find.text('ডার্ক মোড'), findsOneWidget);
  });
}
