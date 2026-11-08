import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/appointment.dart';

class AppointmentRepository extends BaseRepository {
  AppointmentRepository(Database db) : super(db, 'appointments');
  late final BaseRepository _doctors = BaseRepository(db, 'doctors');

  Future<List<Appointment>> list(String userId) async {
    final rows = await db.rawQuery(
        'SELECT a.*, d.name AS doctor_name FROM appointments a LEFT JOIN doctors d ON d.id = a.doctor_id '
        'WHERE a.user_id = ? AND a.deleted_at IS NULL ORDER BY a.appointment_at ASC',
        [userId]);
    return rows.map(Appointment.fromMap).toList();
  }

  /// Creates or updates an appointment. The doctor row is found by name or created,
  /// all inside one transaction.
  Future<void> save(String userId, Appointment a) => db.transaction((txn) async {
        final name = a.doctorName.trim();
        final found = await txn.query('doctors',
            columns: ['id'],
            where: 'user_id = ? AND deleted_at IS NULL AND name = ? COLLATE NOCASE',
            whereArgs: [userId, name],
            limit: 1);
        final doctorId = found.isNotEmpty
            ? found.first['id'] as String
            : await _doctors.insertIn(txn, {'user_id': userId, 'name': name, 'hospital': a.hospital});
        final values = <String, Object?>{
          'user_id': userId,
          'doctor_id': doctorId,
          'hospital': a.hospital,
          'appointment_at': a.at.toUtc().toIso8601String(),
          'notes': a.notes,
          'reminder_minutes': a.reminderMinutes,
          'status': a.status,
        };
        if (a.id.isEmpty) {
          await insertIn(txn, values);
        } else {
          await updateIn(txn, a.id, values);
        }
      });

  Future<void> setStatus(String id, String status) => update(id, {'status': status});
  Future<void> remove(String id) => softDelete(id);

  /// Every appointment id for this user, including deleted ones (used to cancel stale reminders).
  Future<List<String>> allIds(String userId) async =>
      [for (final r in await db.query('appointments', columns: ['id'], where: 'user_id = ?', whereArgs: [userId])) r['id'] as String];
}
