import 'package:sqflite/sqflite.dart';
import 'schema.dart';

/// Runs database creation and upgrades.
/// To add a migration: bump Schema.version and add an entry to [_migrations]
/// keyed by the version it upgrades TO.
class MigrationManager {
  static final Map<int, List<String>> _migrations = {
    // 2: ['ALTER TABLE medicines ADD COLUMN example TEXT'],
  };

  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();
    for (final sql in Schema.createStatements) {
      batch.execute(sql);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      for (var v = oldVersion + 1; v <= newVersion; v++) {
        for (final sql in _migrations[v] ?? const <String>[]) {
          await txn.execute(sql);
        }
      }
    });
  }
}
