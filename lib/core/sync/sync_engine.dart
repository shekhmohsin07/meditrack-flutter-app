import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'remote_store.dart';
import 'sync_models.dart';

class SyncReport {
  const SyncReport({this.uploaded = 0, this.downloaded = 0, this.failed = 0, this.remoteWon = 0, this.error});
  final int uploaded;
  final int downloaded;
  final int failed;
  final int remoteWon; // conflicts decided in favour of the cloud version
  final String? error;
}

enum _Applied { applied, keptLocal, skipped }

/// Offline-first sync between SQLite and a [RemoteStore] for ONE signed-in user.
///  - Upload: every sync_queue entry (one per changed row) is pushed; if the cloud copy is newer it wins.
///  - Download: documents changed since the last checkpoint are merged into SQLite.
///  - Failures are counted per queue entry; after [maxAttempts] an entry is parked until retryFailed().
class SyncEngine {
  SyncEngine({required this.db, required this.remote, required this.userId});
  final Database db;
  final RemoteStore remote;
  final String userId;

  static const maxAttempts = 8;
  final Map<String, Set<String>> _columnCache = {};

  Future<SyncReport> run() async {
    var report = await _upload();
    final down = await _download();
    report = SyncReport(
      uploaded: report.uploaded,
      downloaded: down.downloaded,
      failed: report.failed + down.failed,
      remoteWon: report.remoteWon + down.remoteWon,
      error: report.error ?? down.error,
    );
    if (report.error == null) await _setSetting('last_sync_at', BaseRepository.nowIso());
    return report;
  }

  // ---------------------------------------------------------------- queue helpers

  Future<String?> _owner(String table, String id) async {
    final sql = ownerSql[table];
    if (sql == null) return null;
    final rows = await db.rawQuery(sql, [id]);
    return rows.isEmpty ? null : rows.first.values.first as String?;
  }

  /// (waiting, failed) queue entries that belong to this user.
  Future<(int, int)> counts() async {
    var waiting = 0, failed = 0;
    for (final e in await db.query('sync_queue')) {
      if (await _owner(e['entity_table'] as String, e['entity_id'] as String) != userId) continue;
      (e['attempts'] as int) >= maxAttempts ? failed++ : waiting++;
    }
    return (waiting, failed);
  }

  Future<void> retryFailed() =>
      db.rawUpdate('UPDATE sync_queue SET attempts = 0, last_error = NULL WHERE attempts >= ?', [maxAttempts]);

  Future<void> _ensureQueued(String table, String id) => db.insert(
        'sync_queue',
        {'entity_table': table, 'entity_id': id, 'operation': 'upsert', 'attempts': 0, 'created_at': BaseRepository.nowIso()},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<void> _dropQueue(String table, String id) =>
      db.delete('sync_queue', where: 'entity_table = ? AND entity_id = ?', whereArgs: [table, id]);

  // ---------------------------------------------------------------- upload

  Future<SyncReport> _upload() async {
    var uploaded = 0, failed = 0, remoteWon = 0, consecutiveFailures = 0;
    String? error;
    final entries = await db.query('sync_queue', where: 'attempts < ?', whereArgs: [maxAttempts], orderBy: 'id');
    for (final e in entries) {
      final qid = e['id'] as int;
      final table = e['entity_table'] as String;
      final id = e['entity_id'] as String;
      if (!syncTables.contains(table)) {
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [qid]);
        continue;
      }
      final owner = await _owner(table, id);
      if (owner == null) {
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [qid]); // row no longer exists
        continue;
      }
      if (owner != userId) continue; // belongs to another account on this phone - leave it alone

      try {
        final row = (await db.query(table, where: 'id = ?', whereArgs: [id])).first;
        final cloud = await remote.get(table, id);
        if (cloud != null && cloud['updated_at'] is String &&
            SyncConflict.resolve(table, row, cloud) == Winner.remote) {
          await _applyRemote(table, cloud);
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [qid]);
          remoteWon++;
        } else {
          await remote.set(table, id, SyncMapper.toDoc(row));
          // Mark synced only if the row has not changed again in the meantime.
          await db.rawUpdate("UPDATE $table SET sync_status = 'synced' WHERE id = ? AND updated_at = ?", [id, row['updated_at']]);
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [qid]);
          uploaded++;
        }
        consecutiveFailures = 0;
      } catch (err) {
        failed++;
        consecutiveFailures++;
        error = err.toString();
        await db.rawUpdate('UPDATE sync_queue SET attempts = attempts + 1, last_error = ? WHERE id = ?',
            [err.toString().length > 300 ? err.toString().substring(0, 300) : err.toString(), qid]);
        if (consecutiveFailures >= 3) break; // most likely offline - stop hammering
      }
    }
    return SyncReport(uploaded: uploaded, failed: failed, remoteWon: remoteWon, error: error);
  }

  // ---------------------------------------------------------------- download

  Future<SyncReport> _download() async {
    var downloaded = 0, failed = 0, remoteWon = 0;
    String? error;
    await db.execute('PRAGMA foreign_keys = OFF'); // parents-first order is used, but orphans must not abort a pull
    try {
      for (final table in syncTables) {
        try {
          var since = await _getSetting('sync_since_$table');
          var maxSeen = since;
          while (true) {
            final docs = await remote.changedSince(table, since);
            for (final doc in docs) {
              final r = await _applyRemote(table, doc);
              if (r == _Applied.applied) {
                downloaded++;
              }
              final u = doc['updated_at'];
              if (u is String && (maxSeen == null || u.compareTo(maxSeen) > 0)) maxSeen = u;
            }
            if (docs.length < 500 || maxSeen == since) break; // last page (or all docs share one timestamp)
            since = maxSeen;
          }
          if (maxSeen != null) await _setSetting('sync_since_$table', maxSeen);
        } catch (err) {
          failed++;
          error = err.toString();
        }
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
    return SyncReport(downloaded: downloaded, failed: failed, remoteWon: remoteWon, error: error);
  }

  Future<Set<String>> _columns(String table) async => _columnCache[table] ??=
      {for (final c in await db.rawQuery('PRAGMA table_info($table)')) c['name'] as String};

  Future<_Applied> _applyRemote(String table, Map<String, Object?> doc) async {
    final id = doc['id'];
    if (id is! String || doc['updated_at'] is! String) return _Applied.skipped;
    if (tablesWithUserId.contains(table) && doc['user_id'] != userId) return _Applied.skipped; // never accept foreign data

    final cols = await _columns(table);
    final remoteRow = <String, Object?>{
      for (final e in doc.entries)
        if (cols.contains(e.key) && e.key != 'sync_status') e.key: e.value,
      'sync_status': 'synced',
    };

    final existing = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (existing.isNotEmpty) {
      final l = existing.first;
      if (l['updated_at'] == remoteRow['updated_at'] && l['deleted_at'] == remoteRow['deleted_at']) return _Applied.skipped;
      if (SyncConflict.resolve(table, l, remoteRow) == Winner.local) {
        await _ensureQueued(table, id); // make sure our newer version reaches the cloud
        return _Applied.keptLocal;
      }
      await db.update(table, remoteRow, where: 'id = ?', whereArgs: [id]);
      await _dropQueue(table, id);
      return _Applied.applied;
    }

    // Two devices can create a log for the same dose with different ids: keep exactly one.
    if (table == 'medicine_logs') {
      final dup = await db.query('medicine_logs',
          where: 'medicine_id = ? AND scheduled_at = ? AND id != ?',
          whereArgs: [remoteRow['medicine_id'], remoteRow['scheduled_at'], id],
          limit: 1);
      if (dup.isNotEmpty) {
        if (SyncConflict.resolve(table, dup.first, remoteRow) == Winner.local) return _Applied.keptLocal;
        final dupId = dup.first['id'] as String;
        await db.update('stock_history', {'log_id': null}, where: 'log_id = ?', whereArgs: [dupId]);
        await db.delete('medicine_logs', where: 'id = ?', whereArgs: [dupId]);
        await _dropQueue(table, dupId);
      }
    }
    try {
      await db.insert(table, remoteRow);
      return _Applied.applied;
    } on DatabaseException {
      return _Applied.skipped; // e.g. another UNIQUE rule; the next sync will not retry this forever
    }
  }

  // ---------------------------------------------------------------- settings kv (app_settings)

  Future<String?> _getSetting(String key) async {
    final r = await db.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return r.isEmpty ? null : r.first['value'] as String;
  }

  Future<void> _setSetting(String key, String value) => db.insert(
        'app_settings', {'key': key, 'value': value, 'updated_at': BaseRepository.nowIso()},
        conflictAlgorithm: ConflictAlgorithm.replace);
}
