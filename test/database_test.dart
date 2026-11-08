import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase appDb;
  setUp(() async => appDb = await AppDatabase.open(path: inMemoryDatabasePath));
  tearDown(() => appDb.close());

  Future<String> seedMedicine() async {
    final users = BaseRepository(appDb.db, 'users');
    final uid = await users.insert({'email': 'a@b.com', 'display_name': 'Test'});
    return BaseRepository(appDb.db, 'medicines').insert({
      'user_id': uid, 'name': 'Demo', 'dosage': 'as prescribed', 'type': 'tablet',
      'food_instruction': 'after_food', 'start_date': '2026-01-01',
    });
  }

  test('insert queues exactly one sync entry, even after edits', () async {
    final id = await seedMedicine();
    await BaseRepository(appDb.db, 'medicines').update(id, {'name': 'Demo 2'});
    final q = await appDb.db.query('sync_queue', where: 'entity_id = ?', whereArgs: [id]);
    expect(q.length, 1);
  });

  test('soft delete hides the row but keeps a tombstone', () async {
    final id = await seedMedicine();
    final repo = BaseRepository(appDb.db, 'medicines');
    await repo.softDelete(id);
    expect(await repo.getById(id), isNull);
    final raw = await appDb.db.query('medicines', where: 'id = ?', whereArgs: [id]);
    expect(raw.single['deleted_at'], isNotNull);
  });

  test('duplicate intake log for the same dose is rejected', () async {
    final id = await seedMedicine();
    final logs = BaseRepository(appDb.db, 'medicine_logs');
    final row = {'medicine_id': id, 'scheduled_at': '2026-01-01T08:00:00Z', 'status': 'taken'};
    await logs.insert(row);
    expect(() => logs.insert(row), throwsA(isA<DatabaseException>()));
  });
}
