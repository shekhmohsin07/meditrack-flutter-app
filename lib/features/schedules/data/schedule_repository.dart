import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/schedule.dart';

class ScheduleRepository {
  ScheduleRepository(this.db)
      : _schedules = BaseRepository(db, 'schedules'),
        _times = BaseRepository(db, 'schedule_times');
  final Database db;
  final BaseRepository _schedules;
  final BaseRepository _times;

  /// Every schedule (with its times) and medicine for this user, newest data only.
  /// [memberId] null = the account owner's own medicines. [allMembers] = everyone (used for reminders).
  Future<List<ScheduleEntry>> entriesForUser(String userId, {String? memberId, bool allMembers = false}) async {
    final meds = await db.query('medicines',
        where: 'user_id = ? AND deleted_at IS NULL${allMembers ? '' : (memberId == null ? ' AND member_id IS NULL' : ' AND member_id = ?')}',
        whereArgs: [userId, if (!allMembers && memberId != null) memberId]);
    final medById = {for (final m in meds) m['id'] as String: Medicine.fromMap(m)};
    final schedRows = await db.rawQuery(
        'SELECT s.* FROM schedules s JOIN medicines m ON m.id = s.medicine_id '
        'WHERE m.user_id = ? AND s.deleted_at IS NULL AND m.deleted_at IS NULL',
        [userId]);
    final timeRows = await db.rawQuery(
        'SELECT t.* FROM schedule_times t JOIN schedules s ON s.id = t.schedule_id '
        'JOIN medicines m ON m.id = s.medicine_id '
        'WHERE m.user_id = ? AND t.deleted_at IS NULL AND s.deleted_at IS NULL ORDER BY t.time_of_day',
        [userId]);
    final timesBySchedule = <String, List<String>>{};
    for (final t in timeRows) {
      timesBySchedule.putIfAbsent(t['schedule_id'] as String, () => []).add(t['time_of_day'] as String);
    }
    return [
      for (final r in schedRows)
        if (medById[r['medicine_id']] != null)
          ScheduleEntry(
            Schedule(
              id: r['id'] as String,
              medicineId: r['medicine_id'] as String,
              frequency: Frequency.values.firstWhere((f) => f.name == r['frequency']),
              days: (r['days_of_week'] as String).split(',').where((e) => e.isNotEmpty).map(int.parse).toSet(),
              startDate: DateTime.parse(r['start_date'] as String),
              endDate: r['end_date'] == null ? null : DateTime.parse(r['end_date'] as String),
              paused: r['is_paused'] == 1,
              times: timesBySchedule[r['id']] ?? const [],
              updatedAt: DateTime.parse(r['updated_at'] as String),
            ),
            medById[r['medicine_id']]!,
          ),
    ];
  }

  /// Creates or updates a schedule and replaces its times in ONE transaction.
  Future<String> save(Schedule s) {
    final values = <String, Object?>{
      'medicine_id': s.medicineId,
      'frequency': s.frequency.name,
      'days_of_week': (s.days.toList()..sort()).join(','),
      'start_date': s.startDate.toIso8601String().substring(0, 10),
      'end_date': s.endDate?.toIso8601String().substring(0, 10),
      'is_paused': s.paused ? 1 : 0,
    };
    return db.transaction((txn) async {
      late final String id;
      if (s.id.isEmpty) {
        id = await _schedules.insertIn(txn, values);
      } else {
        id = s.id;
        await _schedules.updateIn(txn, id, values);
        final old = await txn.query('schedule_times',
            columns: ['id'], where: 'schedule_id = ? AND deleted_at IS NULL', whereArgs: [id]);
        for (final r in old) {
          await _times.softDeleteIn(txn, r['id'] as String);
        }
      }
      for (final t in s.times.toSet()) {
        await _times.insertIn(txn, {'schedule_id': id, 'time_of_day': t});
      }
      return id;
    });
  }

  Future<void> setPaused(String id, bool paused) => _schedules.update(id, {'is_paused': paused ? 1 : 0});

  Future<void> remove(String id) => db.transaction((txn) async {
        final times = await txn.query('schedule_times',
            columns: ['id'], where: 'schedule_id = ? AND deleted_at IS NULL', whereArgs: [id]);
        for (final r in times) {
          await _times.softDeleteIn(txn, r['id'] as String);
        }
        await _schedules.softDeleteIn(txn, id);
      });
}
