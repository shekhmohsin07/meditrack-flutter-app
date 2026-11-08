import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/medicine.dart';

enum MedicineSort { name, startDate }

class MedicineRepository extends BaseRepository {
  MedicineRepository(Database db) : super(db, 'medicines');

  Future<List<Medicine>> list(
    String userId, {
    String query = '',
    bool? completed, // null = all
    MedicineSort sort = MedicineSort.name,
    String? memberId,
  }) async {
    final where = StringBuffer('user_id = ?');
    final args = <Object?>[userId];
    if (memberId == null) {
      where.write(' AND member_id IS NULL');
    } else {
      where.write(' AND member_id = ?');
      args.add(memberId);
    }
    if (query.trim().isNotEmpty) {
      where.write(' AND name LIKE ?');
      args.add('%${query.trim()}%');
    }
    if (completed != null) {
      where.write(' AND status = ?');
      args.add(completed ? 'completed' : 'active');
    }
    final rows = await getAll(
      where: where.toString(),
      args: args,
      orderBy: sort == MedicineSort.name ? 'name COLLATE NOCASE ASC' : 'start_date DESC',
    );
    return rows.map(Medicine.fromMap).toList();
  }

  Future<String> add(Medicine m) => insert(m.toMap());
  Future<void> edit(Medicine m) => update(m.id, m.toMap());
  Future<void> remove(String id) => softDelete(id);
}
