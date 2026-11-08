import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/family_member.dart';

class FamilyRepository extends BaseRepository {
  FamilyRepository(Database db) : super(db, 'family_members');

  Future<List<FamilyMember>> list(String userId) async {
    final rows = await getAll(where: 'user_id = ?', args: [userId], orderBy: 'name COLLATE NOCASE');
    return rows.map(FamilyMember.fromMap).toList();
  }

  Future<String> add(String userId, FamilyMember m) => insert(m.toMap(userId));
  Future<void> edit(String userId, FamilyMember m) => update(m.id, m.toMap(userId));

  /// Removes the member and hides their medicines (soft delete, one transaction).
  /// Their intake history rows are kept.
  Future<void> remove(String id) => db.transaction((txn) async {
        final meds = await txn.query('medicines',
            columns: ['id'], where: 'member_id = ? AND deleted_at IS NULL', whereArgs: [id]);
        final medRepo = BaseRepository(db, 'medicines');
        for (final r in meds) {
          await medRepo.softDeleteIn(txn, r['id'] as String);
        }
        await softDeleteIn(txn, id);
      });
}
