import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/health_record.dart';

class HealthRepository extends BaseRepository {
  HealthRepository(Database db) : super(db, 'health_records');

  Future<List<HealthRecord>> list(String userId, {String? memberId, HealthType? type, DateTime? from, DateTime? to}) async {
    final where = StringBuffer(memberId == null ? 'user_id = ? AND member_id IS NULL' : 'user_id = ? AND member_id = ?');
    final args = <Object?>[userId, if (memberId != null) memberId];
    if (type != null) {
      where.write(' AND type = ?');
      args.add(type.dbValue);
    }
    if (from != null) {
      where.write(' AND recorded_at >= ?');
      args.add(from.toUtc().toIso8601String());
    }
    if (to != null) {
      where.write(' AND recorded_at < ?');
      args.add(to.toUtc().toIso8601String());
    }
    final rows = await getAll(where: where.toString(), args: args, orderBy: 'recorded_at DESC');
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<String> add(String userId, HealthRecord r, {String? memberId}) => insert({...r.toMap(userId), 'member_id': memberId});
  Future<void> edit(String userId, HealthRecord r) => update(r.id, r.toMap(userId));
  Future<void> remove(String id) => softDelete(id);
}
