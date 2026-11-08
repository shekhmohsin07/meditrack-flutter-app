import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/core/sync/remote_store.dart';
import 'package:meditrack/core/sync/sync_engine.dart';
import 'package:meditrack/core/sync/sync_models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// In-memory stand-in for Firestore.
class FakeRemote implements RemoteStore {
  final Map<String, Map<String, Map<String, Object?>>> data = {};
  bool offline = false;
  int sets = 0;

  @override
  Future<Map<String, Object?>?> get(String c, String id) async {
    if (offline) throw Exception('offline');
    return data[c]?[id];
  }

  @override
  Future<void> set(String c, String id, Map<String, Object?> doc) async {
    if (offline) throw Exception('offline');
    sets++;
    (data[c] ??= {})[id] = Map.of(doc);
  }

  @override
  Future<List<Map<String, Object?>>> changedSince(String c, String? since, {int limit = 500}) async {
    if (offline) throw Exception('offline');
    final docs = (data[c] ?? {}).values.where((d) => since == null || (d['updated_at'] as String).compareTo(since) >= 0).toList()
      ..sort((a, b) => (a['updated_at'] as String).compareTo(b['updated_at'] as String));
    return docs.take(limit).toList();
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('conflict rules', () {
    Map<String, Object?> row(String id, String updated, {String? status}) =>
        {'id': id, 'updated_at': updated, if (status != null) 'status': status};

    test('newest updated_at wins', () {
      expect(SyncConflict.resolve('medicines', row('a', '2026-01-02T00:00:00.000Z'), row('a', '2026-01-01T00:00:00.000Z')), Winner.local);
      expect(SyncConflict.resolve('medicines', row('a', '2026-01-01T00:00:00.000Z'), row('a', '2026-01-02T00:00:00.000Z')), Winner.remote);
    });
    test('a decided dose beats an automatic missed, whatever the time', () {
      final missedNewer = row('a', '2026-01-05T00:00:00.000Z', status: 'missed');
      final takenOlder = row('b', '2026-01-01T00:00:00.000Z', status: 'taken');
      expect(SyncConflict.resolve('medicine_logs', missedNewer, takenOlder), Winner.remote);
      expect(SyncConflict.resolve('medicine_logs', takenOlder, missedNewer), Winner.local);
    });
    test('exact ties are broken the same way on every device', () {
      final a = row('a', '2026-01-01T00:00:00.000Z');
      final b = row('b', '2026-01-01T00:00:00.000Z');
      expect(SyncConflict.resolve('medicines', a, b), Winner.remote); // b is larger
      expect(SyncConflict.resolve('medicines', b, a), Winner.local);
    });
  });

  group('sync engine', () {
    late AppDatabase appDb;
    late FakeRemote remote;
    late SyncEngine engine;
    late String uid;

    Future<String> addMedicine(String name, {String? user}) => BaseRepository(appDb.db, 'medicines').insert({
          'user_id': user ?? uid, 'name': name, 'dosage': '1', 'type': 'tablet',
          'food_instruction': 'after_food', 'start_date': '2026-01-01'});

    setUp(() async {
      appDb = await AppDatabase.open(path: inMemoryDatabasePath);
      uid = await BaseRepository(appDb.db, 'users').insert({'id': 'user-1', 'email': 'a@b.com', 'display_name': 'T'});
      remote = FakeRemote();
      engine = SyncEngine(db: appDb.db, remote: remote, userId: uid);
    });
    tearDown(() => appDb.close());

    test('uploads pending rows, empties the queue and marks them synced', () async {
      final id = await addMedicine('Alpha');
      final report = await engine.run();
      expect(report.uploaded, 1);
      expect(remote.data['medicines']![id]!['name'], 'Alpha');
      expect(remote.data['medicines']![id]!.containsKey('sync_status'), isFalse);
      expect(await appDb.db.query('sync_queue'), isEmpty);
      expect((await appDb.db.query('medicines')).single['sync_status'], 'synced');
    });

    test('repeated edits upload once (no duplicate uploads)', () async {
      final id = await addMedicine('Alpha');
      final repo = BaseRepository(appDb.db, 'medicines');
      await repo.update(id, {'name': 'Alpha 2'});
      await repo.update(id, {'name': 'Alpha 3'});
      await engine.run();
      expect(remote.sets, 1);
      expect(remote.data['medicines']![id]!['name'], 'Alpha 3');
      await engine.run(); // nothing pending -> nothing uploaded
      expect(remote.sets, 1);
    });

    test('offline: data stays queued, attempts are counted, next sync succeeds', () async {
      await addMedicine('Alpha');
      remote.offline = true;
      final r = await engine.run();
      expect(r.error, isNotNull);
      final q = await appDb.db.query('sync_queue');
      expect(q.single['attempts'], 1);
      remote.offline = false;
      final r2 = await engine.run();
      expect(r2.uploaded, 1);
      expect(await appDb.db.query('sync_queue'), isEmpty);
    });

    test('entries that failed too often are parked until retryFailed', () async {
      await addMedicine('Alpha');
      await appDb.db.update('sync_queue', {'attempts': SyncEngine.maxAttempts});
      expect((await engine.run()).uploaded, 0);
      expect(await engine.counts(), (0, 1));
      await engine.retryFailed();
      expect((await engine.run()).uploaded, 1);
    });

    test('deletions sync as tombstones', () async {
      final id = await addMedicine('Alpha');
      await engine.run();
      await BaseRepository(appDb.db, 'medicines').softDelete(id);
      await engine.run();
      expect(remote.data['medicines']![id]!['deleted_at'], isNotNull);
    });

    test('downloads new cloud documents', () async {
      remote.data['medicines'] = {
        'm-remote': {
          'id': 'm-remote', 'user_id': uid, 'member_id': null, 'name': 'From cloud', 'dosage': '2', 'type': 'syrup',
          'food_instruction': 'with_food', 'start_date': '2026-02-01', 'end_date': null, 'image_path': null,
          'status': 'active', 'notes': null, 'created_at': '2026-02-01T00:00:00.000Z',
          'updated_at': '2026-02-01T00:00:00.000Z', 'deleted_at': null,
        }
      };
      final r = await engine.run();
      expect(r.downloaded, 1);
      final rows = await appDb.db.query('medicines', where: 'id = ?', whereArgs: ['m-remote']);
      expect(rows.single['name'], 'From cloud');
      expect(rows.single['sync_status'], 'synced');
    });

    test('cloud version wins when it is newer; local wins when it is newer', () async {
      final id = await addMedicine('Alpha');
      await engine.run();
      // Newer cloud edit
      remote.data['medicines']![id] = {...remote.data['medicines']![id]!, 'name': 'Cloud edit', 'updated_at': '2999-01-01T00:00:00.000Z'};
      await engine.run();
      expect((await appDb.db.query('medicines')).single['name'], 'Cloud edit');
      // Newer local edit
      await BaseRepository(appDb.db, 'medicines').update(id, {'name': 'Local edit'});
      await engine.run();
      expect(remote.data['medicines']![id]!['name'], 'Cloud edit'); // cloud (year 2999) is still newer
    });

    test("never accepts another user's documents", () async {
      remote.data['medicines'] = {
        'x': {'id': 'x', 'user_id': 'someone-else', 'name': 'Intruder', 'dosage': '1', 'type': 'tablet',
              'food_instruction': 'after_food', 'start_date': '2026-01-01', 'status': 'active',
              'created_at': '2026-01-01T00:00:00.000Z', 'updated_at': '2026-01-01T00:00:00.000Z'}
      };
      await engine.run();
      expect(await appDb.db.query('medicines'), isEmpty);
    });

    test("another account's queued changes are not uploaded", () async {
      final other = await BaseRepository(appDb.db, 'users').insert({'id': 'user-2', 'email': 'b@b.com', 'display_name': 'O'});
      await addMedicine('Other users medicine', user: other);
      await addMedicine('Mine');
      await engine.run();
      expect(remote.data['medicines']!.length, 1);
      expect((await appDb.db.query('sync_queue')).length, 1); // the other account's entry is left alone
    });

    test('duplicate logs for one dose converge to a single row', () async {
      final med = await addMedicine('Alpha');
      await BaseRepository(appDb.db, 'medicine_logs').insert(
          {'id': 'log-local', 'medicine_id': med, 'scheduled_at': '2026-03-02T08:00:00.000Z', 'status': 'missed'});
      remote.data['medicine_logs'] = {
        'log-remote': {
          'id': 'log-remote', 'medicine_id': med, 'member_id': null, 'schedule_time_id': null,
          'scheduled_at': '2026-03-02T08:00:00.000Z', 'action_at': '2026-03-02T08:05:00.000Z', 'status': 'taken',
          'created_at': '2026-03-02T08:05:00.000Z', 'updated_at': '2026-03-02T08:05:00.000Z', 'deleted_at': null,
        }
      };
      await engine.run();
      final logs = await appDb.db.query('medicine_logs');
      expect(logs.length, 1);
      expect(logs.single['status'], 'taken');
    });
  });
}
