import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/features/family/data/family_repository.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/core/notifications/reminder_coordinator.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/inventory/presentation/inventory_providers.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/features/medicines/presentation/medicine_labels.dart';
import 'package:meditrack/features/reports/presentation/report_providers.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule.dart';

final scheduleRepositoryProvider = FutureProvider<ScheduleRepository>(
    (ref) async => ScheduleRepository((await ref.watch(databaseProvider.future)).db));

final intakeRepositoryProvider = FutureProvider<IntakeRepository>(
    (ref) async => IntakeRepository((await ref.watch(databaseProvider.future)).db));

final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Last error while (re)scheduling reminders, or null. Shown on the notification status screen.
final reminderErrorProvider = StateProvider<String?>((ref) => null);

final scheduleEntriesProvider = FutureProvider.autoDispose<List<ScheduleEntry>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  return (await ref.watch(scheduleRepositoryProvider.future)).entriesForUser(s.id, memberId: ref.watch(activeMemberProvider));
});

/// Active medicines for the "choose medicine" dropdown.
final pickableMedicinesProvider = FutureProvider.autoDispose<List<Medicine>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final repo = MedicineRepository((await ref.watch(databaseProvider.future)).db);
  return repo.list(s.id, completed: false, memberId: ref.watch(activeMemberProvider));
});

class DoseStatus {
  const DoseStatus(this.dose, this.status);
  final Dose dose;
  final IntakeStatus? status; // null = no log yet
}

Future<List<DoseStatus>> _dosesFor(Ref ref, DateTime date) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  final day = ScheduleLogic.dateOnly(date);
  final entries = await ref.watch(scheduleEntriesProvider.future);
  final next = DateTime(day.year, day.month, day.day + 1);
  final doses = ScheduleLogic.dosesBetween(entries, day, next.subtract(const Duration(seconds: 1)));
  final logs = await (await ref.watch(intakeRepositoryProvider.future)).logsBetween(s.id, day, next);
  final byKey = {for (final l in logs) l.key: l.status};
  return [for (final d in doses) DoseStatus(d, byKey[IntakeRepository.keyOf(d.medicine.id, d.at)])];
}

/// Doses for the day selected on the Schedule tab.
final dayDosesProvider =
    FutureProvider.autoDispose<List<DoseStatus>>((ref) => _dosesFor(ref, ref.watch(selectedDayProvider)));

/// Today's doses (dashboard).
final todayDosesProvider = FutureProvider.autoDispose<List<DoseStatus>>((ref) => _dosesFor(ref, DateTime.now()));

void _invalidateDoseData(WidgetRef ref) {
  ref.invalidate(dayDosesProvider);
  ref.invalidate(todayDosesProvider);
  ref.invalidate(stockRowsProvider);
  ref.invalidate(periodHistoryProvider);
  ref.invalidate(monthHistoryProvider);
  ref.invalidate(weekHistoryProvider);
}

/// Mark a dose taken / skipped from the UI (stock is deducted by the repository).
Future<void> markDose(BuildContext context, WidgetRef ref, Dose d, IntakeStatus status) async {
  final repo = await ref.read(intakeRepositoryProvider.future);
  await repo.record(medicineId: d.medicine.id, scheduledAt: d.at, status: status);
  _invalidateDoseData(ref);
  if (context.mounted) await refreshReminders(context, ref);
}

/// Snooze from the UI: logs "snoozed" and schedules a reminder in 10 minutes.
Future<void> snoozeDose(BuildContext context, WidgetRef ref, Dose d) async {
  final t = AppLocalizations.of(context)!;
  final title = t.notifTitle(d.medicine.name);
  final body = '${d.medicine.dosage} • ${t.foodLabel(d.medicine.food)}';
  final labels = {'taken': t.actionTaken, 'snooze': t.actionSnooze, 'skip': t.actionSkip};
  try {
    final repo = await ref.read(intakeRepositoryProvider.future);
    await repo.record(medicineId: d.medicine.id, scheduledAt: d.at, status: IntakeStatus.snoozed);
    await NotificationService.instance.scheduleAt(
      id: NotificationService.idFor(d.medicine.id, d.at, 'snooze'),
      when: DateTime.now().add(const Duration(minutes: snoozeMinutes)),
      title: title,
      body: body,
      payload: jsonEncode({'m': d.medicine.id, 's': d.at.toUtc().toIso8601String(), 't': title, 'b': body, 'l': labels}),
      labels: labels,
    );
  } catch (e) {
    debugPrint('snoozeDose failed: $e');
  }
  _invalidateDoseData(ref);
}

/// Re-creates Android notifications (doses + appointments) from the database.
/// Safe to call any time; failures (e.g. permission denied) never crash the UI.
Future<void> refreshReminders(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();

  final s = ref.read(sessionProvider);
  if (s == null) return;

  try {
    final db = (await ref.read(databaseProvider.future)).db;
    final c = ReminderCoordinator(db);

    final members = {
      for (final m in await FamilyRepository(db).list(s.id)) m.id: m
    };

    String who(Medicine m) =>
        m.memberId == null || members[m.memberId] == null
            ? ''
            : ' (${members[m.memberId]!.name})';

    await c.markMissed(s.id);

    await c.alertMissedForConsentingMembers(
      userId: s.id,
      titleOf: t.missedDoseTitle,
      bodyOf: (name, at) => '$name • ${DateFormat.jm(locale).format(at)}',
    );

    await c.rescheduleAll(
      userId: s.id,
      titleOf: (m) => t.notifTitle(m.name) + who(m),
      bodyOf: (m) => '${m.dosage} • ${t.foodLabel(m.food)}',
      labels: {
        'taken': t.actionTaken,
        'snooze': t.actionSnooze,
        'skip': t.actionSkip,
      },
    );

    await c.rescheduleAppointments(
      userId: s.id,
      titleOf: (doctor) => t.appointmentNotifTitle(doctor),
      bodyOf: (a) =>
      a.hospital?.isNotEmpty == true
          ? a.hospital!
          : t.appointmentNotifBody,
    );

    ref.read(reminderErrorProvider.notifier).state = null;
    _invalidateDoseData(ref);
  } catch (e) {
    debugPrint('refreshReminders failed: $e');
    ref.read(reminderErrorProvider.notifier).state = e.toString();
  }
}