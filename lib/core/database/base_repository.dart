import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Generic local-first CRUD. Every write also queues a sync_queue entry
/// (one row per entity, so repeated edits never create duplicate uploads).
/// The *In methods run inside an existing transaction ([DatabaseExecutor]).
class BaseRepository {
  BaseRepository(this.db, this.table);
  final Database db;
  final String table;
  static const _uuid = Uuid();

  /// UTC ISO-8601 with exactly 3 fractional digits, so timestamps sort correctly as text
  /// (the sync service relies on this).
  static String nowIso() =>
      DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch, isUtc: true).toIso8601String();
  String _now() => nowIso();

  Future<void> _enqueue(DatabaseExecutor ex, String id, String op) => ex.insert(
        'sync_queue',
        {'entity_table': table, 'entity_id': id, 'operation': op, 'attempts': 0, 'created_at': _now()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<String> insertIn(DatabaseExecutor ex, Map<String, Object?> values) async {
    final id = (values['id'] as String?) ?? _uuid.v4();
    final now = _now();
    await ex.insert(table, {...values, 'id': id, 'created_at': now, 'updated_at': now, 'sync_status': 'pending'});
    await _enqueue(ex, id, 'upsert');
    return id;
  }

  Future<void> updateIn(DatabaseExecutor ex, String id, Map<String, Object?> values) async {
    await ex.update(table, {...values, 'updated_at': _now(), 'sync_status': 'pending'},
        where: 'id = ?', whereArgs: [id]);
    await _enqueue(ex, id, 'upsert');
  }

  /// Soft delete (tombstone) so the deletion can be synced.
  Future<void> softDeleteIn(DatabaseExecutor ex, String id) async {
    final now = _now();
    await ex.update(table, {'deleted_at': now, 'updated_at': now, 'sync_status': 'pending'},
        where: 'id = ?', whereArgs: [id]);
    await _enqueue(ex, id, 'delete');
  }

  Future<String> insert(Map<String, Object?> values) => db.transaction((t) => insertIn(t, values));
  Future<void> update(String id, Map<String, Object?> values) => db.transaction((t) => updateIn(t, id, values));
  Future<void> softDelete(String id) => db.transaction((t) => softDeleteIn(t, id));

  Future<Map<String, Object?>?> getById(String id) async {
    final rows = await db.query(table, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getAll({String? where, List<Object?>? args, String? orderBy}) {
    final w = where == null ? 'deleted_at IS NULL' : 'deleted_at IS NULL AND ($where)';
    return db.query(table, where: w, whereArgs: args, orderBy: orderBy);
  }
}
