import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/appointments/data/appointment_repository.dart';
import 'package:meditrack/features/appointments/domain/appointment.dart';
import 'package:meditrack/features/dashboard/domain/day_summary.dart';
import 'package:meditrack/features/health_records/data/health_repository.dart';
import 'package:meditrack/features/health_records/domain/health_record.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('health validation (typing mistakes only)', () {
    test('blood pressure needs both values, diastolic below systolic', () {
      expect(HealthValidators.check(HealthType.bloodPressure, v1: 120), 'requiredField');
      expect(HealthValidators.check(HealthType.bloodPressure, v1: 120, v2: 80), isNull);
      expect(HealthValidators.check(HealthType.bloodPressure, v1: 80, v2: 120), 'outOfRange');
      expect(HealthValidators.check(HealthType.bloodPressure, v1: 1200, v2: 80), 'outOfRange');
    });
    test('glucose and weight bounds depend on the unit', () {
      expect(HealthValidators.check(HealthType.bloodGlucose, v1: 5.6, unit: 'mmol/L'), isNull);
      expect(HealthValidators.check(HealthType.bloodGlucose, v1: 5.6, unit: 'mg/dL'), 'outOfRange');
      expect(HealthValidators.check(HealthType.weight, v1: 70, unit: 'kg'), isNull);
      expect(HealthValidators.check(HealthType.weight, v1: 700, unit: 'kg'), 'outOfRange');
    });
    test('notes need text', () {
      expect(HealthValidators.check(HealthType.note, note: '  '), 'requiredField');
      expect(HealthValidators.check(HealthType.history, note: 'Surgery 2020'), isNull);
    });
  });

  test('day summary counts', () {
    final now = DateTime(2026, 3, 2, 12);
    final s = DaySummary.from([
      (at: DateTime(2026, 3, 2, 8), status: IntakeStatus.taken),
      (at: DateTime(2026, 3, 2, 9), status: IntakeStatus.missed),
      (at: DateTime(2026, 3, 2, 18), status: null),
      (at: DateTime(2026, 3, 2, 20), status: IntakeStatus.snoozed),
      (at: DateTime(2026, 3, 2, 11), status: null), // due, not upcoming
    ], now);
    expect((s.total, s.taken, s.missed, s.upcoming), (5, 1, 1, 2));
  });

  group('repositories', () {
    late AppDatabase appDb;
    late String uid;
    setUp(() async {
      appDb = await AppDatabase.open(path: inMemoryDatabasePath);
      uid = await BaseRepository(appDb.db, 'users').insert({'email': 'a@b.com', 'display_name': 'T'});
    });
    tearDown(() => appDb.close());

    test('health record add / filter / delete', () async {
      final repo = HealthRepository(appDb.db);
      await repo.add(uid, HealthRecord(id: '', type: HealthType.weight, value1: 70, unit: 'kg', recordedAt: DateTime(2026, 3, 1)));
      await repo.add(uid, HealthRecord(id: '', type: HealthType.bloodPressure, value1: 120, value2: 80, unit: 'mmHg', recordedAt: DateTime(2026, 3, 2)));
      expect((await repo.list(uid)).length, 2);
      final weights = await repo.list(uid, type: HealthType.weight);
      expect(weights.single.value1, 70);
      expect((await repo.list(uid, from: DateTime(2026, 3, 2), to: DateTime(2026, 3, 3))).length, 1);
      await repo.remove(weights.single.id);
      expect((await repo.list(uid)).length, 1);
    });

    test('appointments reuse the doctor row and keep status', () async {
      final repo = AppointmentRepository(appDb.db);
      final at = DateTime.now().add(const Duration(days: 3));
      await repo.save(uid, Appointment(id: '', doctorName: 'Dr Rahman', at: at));
      await repo.save(uid, Appointment(id: '', doctorName: 'dr rahman', at: at.add(const Duration(days: 1))));
      expect((await appDb.db.query('doctors')).length, 1);
      final all = await repo.list(uid);
      expect(all.length, 2);
      await repo.setStatus(all.first.id, 'completed');
      expect((await repo.list(uid)).first.status, 'completed');
      await repo.remove(all.last.id);
      expect((await repo.list(uid)).length, 1);
    });
  });
}
