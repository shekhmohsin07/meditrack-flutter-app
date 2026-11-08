import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late AppDatabase appDb;
  late MedicineRepository repo;
  late String uid;

  setUp(() async {
    appDb = await AppDatabase.open(path: inMemoryDatabasePath);
    uid = await BaseRepository(appDb.db, 'users').insert({'email': 'a@b.com', 'display_name': 'T'});
    repo = MedicineRepository(appDb.db);
  });
  tearDown(() => appDb.close());

  Medicine med(String name, {bool completed = false}) => Medicine(
        id: '', userId: uid, name: name, dosage: '1 tablet', type: MedicineType.tablet,
        food: FoodInstruction.afterFood, startDate: DateTime(2026, 1, 1), completed: completed);

  test('add, search, filter, edit, delete', () async {
    final id = await repo.add(med('Alpha'));
    await repo.add(med('Beta', completed: true));
    expect((await repo.list(uid)).length, 2);
    expect((await repo.list(uid, query: 'alp')).single.name, 'Alpha');
    expect((await repo.list(uid, completed: true)).single.name, 'Beta');

    final loaded = (await repo.list(uid, query: 'Alpha')).single;
    await repo.edit(Medicine(id: id, userId: uid, name: 'Alpha2', dosage: loaded.dosage,
        type: loaded.type, food: loaded.food, startDate: loaded.startDate));
    expect((await repo.list(uid, query: 'Alpha2')).length, 1);

    await repo.remove(id);
    expect((await repo.list(uid)).length, 1);
  });
}
