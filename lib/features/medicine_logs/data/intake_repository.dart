import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/inventory/data/inventory_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/intake_log.dart';

/// Records what happened to each scheduled dose.
/// UNIQUE(medicine_id, scheduled_at) in the schema guarantees one log per dose.
/// Marking a dose "taken" also deducts stock (once - see InventoryRepository).
class IntakeRepository extends BaseRepository {
  IntakeRepository(Database db)
      : _inventory = InventoryRepository(db),
        super(db, 'medicine_logs');
  final InventoryRepository _inventory;

  static String keyOf(String medicineId, DateTime at) => '$medicineId|${at.toUtc().toIso8601String()}';

  /// [auto] = true when the app itself marks a dose missed; that never overrides
  /// something the user already decided (taken / skipped).
  Future<void> record({
    required String medicineId,
    required DateTime scheduledAt,
    required IntakeStatus status,
    bool auto = false,
  }) async {
    final iso = scheduledAt.toUtc().toIso8601String();
    final existing = await db.query('medicine_logs',
        where: 'medicine_id = ? AND scheduled_at = ? AND deleted_at IS NULL', whereArgs: [medicineId, iso], limit: 1);
    final actionAt = DateTime.now().toUtc().toIso8601String();

    late final String logId;
    IntakeStatus? previous;
    if (existing.isNotEmpty) {
      logId = existing.first['id'] as String;
      previous = IntakeStatus.fromDb(existing.first['status'] as String);
      if (auto && previous != IntakeStatus.pending && previous != IntakeStatus.snoozed) return;
      if (previous != status) {
        await update(logId, {'status': status.name, 'action_at': actionAt});
      }
    } else {
      final med = await db.query('medicines', columns: ['member_id'], where: 'id = ?', whereArgs: [medicineId], limit: 1);
      logId = await insert({
        'medicine_id': medicineId,
        'member_id': med.isEmpty ? null : med.first['member_id'],
        'scheduled_at': iso,
        'action_at': actionAt,
        'status': status.name,
      });
    }

    if (status == IntakeStatus.taken) {
      await _inventory.deductForLog(logId, medicineId); // idempotent
    } else if (previous == IntakeStatus.taken) {
      await _inventory.reverseForLog(logId);
    }
  }

  /// Logs for this user whose dose time is in [from, to).
  Future<List<IntakeLog>> logsBetween(String userId, DateTime from, DateTime to) async {
    final rows = await db.rawQuery(
        'SELECT l.* FROM medicine_logs l JOIN medicines m ON m.id = l.medicine_id '
        'WHERE m.user_id = ? AND l.deleted_at IS NULL AND l.scheduled_at >= ? AND l.scheduled_at < ?',
        [userId, from.toUtc().toIso8601String(), to.toUtc().toIso8601String()]);
    return [
      for (final r in rows)
        IntakeLog(r['id'] as String, r['medicine_id'] as String, DateTime.parse(r['scheduled_at'] as String).toLocal(),
            IntakeStatus.fromDb(r['status'] as String))
    ];
  }

  /// History with medicine names, newest first. History is kept even if the
  /// medicine was deleted later.
  /// [memberId] null = the account owner's own medicines.
  Future<List<HistoryEntry>> historyBetween(String userId, DateTime from, DateTime to,
      {String? medicineId, String? memberId}) async {
    final rows = await db.rawQuery(
        'SELECT l.medicine_id, l.scheduled_at, l.status, m.name AS med_name, m.dosage AS med_dosage '
        'FROM medicine_logs l JOIN medicines m ON m.id = l.medicine_id '
        'WHERE m.user_id = ? AND l.deleted_at IS NULL AND l.scheduled_at >= ? AND l.scheduled_at < ? '
        '${memberId == null ? 'AND m.member_id IS NULL ' : 'AND m.member_id = ? '}'
        '${medicineId == null ? '' : 'AND l.medicine_id = ? '}'
        'ORDER BY l.scheduled_at DESC',
        [userId, from.toUtc().toIso8601String(), to.toUtc().toIso8601String(), if (memberId != null) memberId, if (medicineId != null) medicineId]);
    return [
      for (final r in rows)
        HistoryEntry(
          medicineId: r['medicine_id'] as String,
          medicineName: r['med_name'] as String,
          dosage: r['med_dosage'] as String,
          scheduledAt: DateTime.parse(r['scheduled_at'] as String).toLocal(),
          status: IntakeStatus.fromDb(r['status'] as String),
        )
    ];
  }
}
