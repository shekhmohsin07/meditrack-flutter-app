import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/notifications/reminder_coordinator.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';

final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.week);
final reportAnchorProvider = StateProvider<DateTime>((ref) => DateTime.now());
final reportMedicineProvider = StateProvider<String?>((ref) => null); // null = all medicines

/// Every (non-deleted) medicine, for the filter dropdown.
final filterMedicinesProvider = FutureProvider.autoDispose<List<Medicine>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  return MedicineRepository((await ref.watch(databaseProvider.future)).db).list(s.id, memberId: ref.watch(activeMemberProvider));
});

Future<List<HistoryEntry>> _load(Ref ref, DateRange range) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final db = (await ref.watch(databaseProvider.future)).db;
  await ReminderCoordinator(db).markMissed(s.id); // DB only, no notifications
  return IntakeRepository(db).historyBetween(s.id, range.from, range.to,
      medicineId: ref.watch(reportMedicineProvider), memberId: ref.watch(activeMemberProvider));
}

/// Entries for the selected day / week / month.
final periodRangeProvider = Provider<DateRange>(
    (ref) => DateRange.of(ref.watch(reportPeriodProvider), ref.watch(reportAnchorProvider)));

final periodHistoryProvider =
    FutureProvider.autoDispose<List<HistoryEntry>>((ref) => _load(ref, ref.watch(periodRangeProvider)));

/// Entries for the whole month of the anchor date (calendar tab).
final monthHistoryProvider = FutureProvider.autoDispose<List<HistoryEntry>>(
    (ref) => _load(ref, DateRange.of(ReportPeriod.month, ref.watch(reportAnchorProvider))));

/// The current week (Mon-Sun), all medicines - used by the dashboard chart.
final weekHistoryProvider = FutureProvider.autoDispose<List<HistoryEntry>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final db = (await ref.watch(databaseProvider.future)).db;
  final r = DateRange.of(ReportPeriod.week, DateTime.now());
  return IntakeRepository(db).historyBetween(s.id, r.from, r.to, memberId: ref.watch(activeMemberProvider));
});
