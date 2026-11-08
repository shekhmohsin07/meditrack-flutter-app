import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late AppDatabase appDb;
  late IntakeRepository intake;
  late String medId;
  final at = DateTime.utc(2026, 3, 2, 8);

  setUp(() async {
    appDb = await AppDatabase.open(path: inMemoryDatabasePath);
    final uid = await BaseRepository(appDb.db, 'users').insert({'email': 'a@b.com', 'display_name': 'T'});
    medId = await BaseRepository(appDb.db, 'medicines').insert({
      'user_id': uid, 'name': 'Demo', 'dosage': '1', 'type': 'tablet',
      'food_instruction': 'after_food', 'start_date': '2026-01-01'});
    intake = IntakeRepository(appDb.db);
  });
  tearDown(() => appDb.close());

  Future<List<Map<String, Object?>>> rows() => appDb.db.query('medicine_logs');

  test('recording the same dose twice keeps a single row', () async {
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.taken);
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.taken);
    expect((await rows()).length, 1);
  });

  test('automatic "missed" never overrides taken', () async {
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.taken);
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.missed, auto: true);
    expect((await rows()).single['status'], 'taken');
  });

  test('user can still mark a missed dose as taken later', () async {
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.missed, auto: true);
    await intake.record(medicineId: medId, scheduledAt: at, status: IntakeStatus.taken);
    expect((await rows()).single['status'], 'taken');
  });

  test('notification ids are stable and differ per dose', () {
    final a = NotificationService.idFor('m1', at);
    expect(NotificationService.idFor('m1', at), a);
    expect(NotificationService.idFor('m1', at.add(const Duration(hours: 1))), isNot(a));
    expect(NotificationService.idFor('m1', at, 'snooze'), isNot(a));
    expect(a, greaterThanOrEqualTo(0));
  });
}
