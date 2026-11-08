import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/features/authentication/domain/session.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/family/domain/family_member.dart';
import 'package:meditrack/features/family/presentation/family_providers.dart';
import 'package:meditrack/features/inventory/presentation/inventory_providers.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/features/medicines/presentation/medicine_providers.dart';
import 'package:meditrack/features/reports/presentation/report_providers.dart';
import 'package:meditrack/features/schedules/domain/schedule.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signed-in (offline) test user.
class TestSession extends SessionNotifier {
  @override
  Session? build() => const Session(id: 'u1', email: '', name: 'Test User', offline: true);
}

/// Nobody signed in.
class NoSession extends SessionNotifier {
  @override
  Session? build() => null;
}

/// Replaces every database-backed provider with in-memory data, so widget tests need no SQLite.
List<Override> dataOverrides({List<DoseStatus> today = const [], List<Medicine> medicines = const []}) => [
      databaseProvider.overrideWith((ref) async => throw StateError('no database in widget tests')),
      todayDosesProvider.overrideWith((ref) async => today),
      dayDosesProvider.overrideWith((ref) async => today),
      medicinesProvider.overrideWith((ref) async => medicines),
      filterMedicinesProvider.overrideWith((ref) async => medicines),
      pickableMedicinesProvider.overrideWith((ref) async => medicines),
      scheduleEntriesProvider.overrideWith((ref) async => <ScheduleEntry>[]),
      stockRowsProvider.overrideWith((ref) async => <StockRow>[]),
      stockAlertsProvider.overrideWith((ref) async => <StockRow>[]),
      weekHistoryProvider.overrideWith((ref) async => <HistoryEntry>[]),
      periodHistoryProvider.overrideWith((ref) async => <HistoryEntry>[]),
      monthHistoryProvider.overrideWith((ref) async => <HistoryEntry>[]),
      familyMembersProvider.overrideWith((ref) async => <FamilyMember>[]),
    ];

/// Wraps [home] with localisation, theme switching and the test overrides.
/// (Uses the plain Material theme: AppTheme loads Google Fonts, which needs the network.)
Future<Widget> buildTestApp(
  Widget home, {
  bool signedIn = true,
  List<Override> overrides = const [],
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(sp),
      sessionProvider.overrideWith(signedIn ? TestSession.new : NoSession.new),
      ...overrides,
    ],
    child: Consumer(
      builder: (context, ref, _) => MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: ref.watch(themeModeProvider),
        locale: ref.watch(localeProvider),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
}

Medicine testMedicine(String name, {MedicineType type = MedicineType.tablet}) => Medicine(
    id: name, userId: 'u1', name: name, dosage: '1 tablet', type: type,
    food: FoodInstruction.afterFood, startDate: DateTime(2026, 1, 1));
