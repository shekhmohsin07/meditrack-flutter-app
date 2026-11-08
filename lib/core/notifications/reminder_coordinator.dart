import 'dart:convert';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/appointments/data/appointment_repository.dart';
import 'package:meditrack/features/appointments/domain/appointment.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/features/schedules/data/schedule_repository.dart';
import 'package:meditrack/features/schedules/domain/schedule.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'notification_service.dart';

/// Keeps Android's scheduled notifications in sync with the schedules in SQLite,
/// and marks doses "missed" when nobody responded.
///
/// Limitation (documented): reminders are scheduled a rolling 7 days ahead and
/// refreshed whenever the app opens or a schedule changes.
class ReminderCoordinator {
  ReminderCoordinator(this.db);
  final Database db;

  static const horizonDays = 7;
  static const maxScheduled = 400;
  static const missedGraceMinutes = 60;
  static const missedLookbackDays = 14;

  Future<void> rescheduleAll({
    required String userId,
    required String Function(Medicine) titleOf,
    required String Function(Medicine) bodyOf,
    required Map<String, String> labels,
  }) async {
    final svc = NotificationService.instance;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // 1. Cancel what we scheduled before (snoozes are not in this table, so they survive).
    final old = await db.query('notifications',
        columns: ['notification_int_id'], where: "user_id = ? AND status = 'scheduled'", whereArgs: [userId]);
    for (final r in old) {
      await svc.cancel(r['notification_int_id'] as int);
    }
    await db.rawUpdate("UPDATE notifications SET status = 'shown', updated_at = ? "
        "WHERE user_id = ? AND status = 'scheduled' AND scheduled_at <= ?", [nowIso, userId, nowIso]);
    await db.rawUpdate("UPDATE notifications SET status = 'cancelled', updated_at = ? "
        "WHERE user_id = ? AND status = 'scheduled'", [nowIso, userId]);

    // 2. Work out upcoming doses that still need a reminder.
    final entries = await ScheduleRepository(db).entriesForUser(userId, allMembers: true);
    final now = DateTime.now();
    final end = now.add(const Duration(days: horizonDays));
    final logs = await IntakeRepository(db).logsBetween(userId, now, end);
    final decided = {
      for (final l in logs)
        if (l.status == IntakeStatus.taken || l.status == IntakeStatus.skipped) l.key
    };
    final doses = ScheduleLogic.dosesBetween(entries, now, end)
        .where((d) => !decided.contains(IntakeRepository.keyOf(d.medicine.id, d.at)))
        .take(maxScheduled);

    // 3. Schedule them.
    for (final d in doses) {
      final id = NotificationService.idFor(d.medicine.id, d.at);
      final title = titleOf(d.medicine);
      final body = bodyOf(d.medicine);
      final payload = jsonEncode({
        'm': d.medicine.id,
        's': d.at.toUtc().toIso8601String(),
        't': title,
        'b': body,
        'l': labels,
      });
      // INSERT OR IGNORE + UPDATE (UNIQUE notification_int_id prevents duplicate rows).
      await db.rawInsert(
          'INSERT OR IGNORE INTO notifications (id, user_id, medicine_id, notification_int_id, title, body, '
          "scheduled_at, status, created_at, updated_at, sync_status) VALUES (?,?,?,?,?,?,?,'scheduled',?,?,'synced')",
          [const Uuid().v4(), userId, d.medicine.id, id, title, body, d.at.toUtc().toIso8601String(), nowIso, nowIso]);
      await db.rawUpdate("UPDATE notifications SET status = 'scheduled', title = ?, body = ?, updated_at = ? "
          'WHERE notification_int_id = ?', [title, body, nowIso, id]);
      await svc.scheduleAt(id: id, when: d.at, title: title, body: body, payload: payload, labels: labels);
    }
  }

  /// Doses from the last 14 days that are older than the grace period and have
  /// no decision become "missed".
  Future<void> markMissed(String userId) async {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: missedLookbackDays));
    final to = now.subtract(const Duration(minutes: missedGraceMinutes));
    final entries = await ScheduleRepository(db).entriesForUser(userId, allMembers: true);
    final intake = IntakeRepository(db);
    for (final d in ScheduleLogic.dosesBetween(entries, from, to)) {
      // Never blame the user for doses before this schedule existed in its current form.
      final since = d.schedule.updatedAt;
      if (since != null && d.at.isBefore(since)) continue;
      await intake.record(
          medicineId: d.medicine.id, scheduledAt: d.at, status: IntakeStatus.missed, auto: true);
    }
  }

  /// One reminder per upcoming appointment. The notification id depends only on the
  /// appointment id, so editing the time simply replaces the old reminder.
  Future<void> rescheduleAppointments({
    required String userId,
    required String Function(String doctorName) titleOf,
    required String Function(Appointment) bodyOf,
  }) async {
    final svc = NotificationService.instance;
    final repo = AppointmentRepository(db);
    int idOf(String apptId) => NotificationService.idFor(apptId, DateTime.utc(2000), 'appt');

    for (final id in await repo.allIds(userId)) {
      await svc.cancel(idOf(id)); // also clears deleted / cancelled ones
    }
    final now = DateTime.now();
    for (final a in await repo.list(userId)) {
      if (a.status != 'upcoming' || !a.remindAt.isAfter(now)) continue;
      await svc.scheduleAt(
        id: idOf(a.id),
        when: a.remindAt,
        title: titleOf(a.doctorName),
        body: bodyOf(a),
        payload: '{"a":"${a.id}"}',
        labels: const {},
        withActions: false,
      );
    }
  }

  /// Caregiver alerts: when a dose of a family member who GAVE CONSENT is marked missed,
  /// the account owner gets one local notification (never repeated, never without consent).
  /// Note: this notifies on this phone only - there is no server to alert other accounts.
  Future<void> alertMissedForConsentingMembers({
    required String userId,
    required String Function(String memberName) titleOf,
    required String Function(String medicineName, DateTime at) bodyOf,
  }) async {
    final since = DateTime.now().subtract(const Duration(hours: 48)).toUtc().toIso8601String();
    final rows = await db.rawQuery(
        'SELECT l.medicine_id AS medicine_id, l.scheduled_at AS scheduled_at, m.name AS med_name, f.name AS member_name '
        'FROM medicine_logs l JOIN medicines m ON m.id = l.medicine_id JOIN family_members f ON f.id = m.member_id '
        "WHERE m.user_id = ? AND l.status = 'missed' AND l.deleted_at IS NULL AND f.deleted_at IS NULL "
        'AND f.caregiver_consent = 1 AND l.scheduled_at >= ?',
        [userId, since]);
    final nowIso = BaseRepository.nowIso();
    for (final r in rows) {
      final at = DateTime.parse(r['scheduled_at'] as String).toLocal();
      final id = NotificationService.idFor(r['medicine_id'] as String, at, 'missed');
      final seen = await db.query('notifications', columns: ['id'], where: 'notification_int_id = ?', whereArgs: [id], limit: 1);
      if (seen.isNotEmpty) continue; // already alerted
      final title = titleOf(r['member_name'] as String);
      final body = bodyOf(r['med_name'] as String, at);
      await db.insert('notifications', {
        'id': const Uuid().v4(), 'user_id': userId, 'medicine_id': r['medicine_id'], 'notification_int_id': id,
        'title': title, 'body': body, 'scheduled_at': r['scheduled_at'], 'status': 'shown',
        'created_at': nowIso, 'updated_at': nowIso, 'sync_status': 'synced',
      });
      await NotificationService.instance.showNow(id: id, title: title, body: body);
    }
  }
}
