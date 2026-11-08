import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'migration_manager.dart';
import 'schema.dart';

/// Opens the SQLite database (single shared instance).
class AppDatabase {
  AppDatabase._(this.db);
  final Database db;

  static AppDatabase? _instance;

  /// [path] can be [inMemoryDatabasePath] for tests.
  static Future<AppDatabase> open({String? path}) async {
    if (_instance != null && path == null) return _instance!;
    final dbPath = path ?? p.join(await getDatabasesPath(), 'meditrack.db');
    final db = await openDatabase(
      dbPath,
      version: Schema.version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: MigrationManager.onCreate,
      onUpgrade: MigrationManager.onUpgrade,
    );
    final instance = AppDatabase._(db);
    if (path == null) _instance = instance;
    return instance;
  }

  Future<void> close() => db.close();
}
