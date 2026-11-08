import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/inventory/data/inventory_repository.dart';
import 'package:meditrack/features/inventory/domain/inventory.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late AppDatabase appDb;
  late InventoryRepository inv;
  late IntakeRepository intake;
  late String uid, medId;
  final at1 = DateTime.utc(2026, 3, 2, 8);
  final at2 = DateTime.utc(2026, 3, 2, 20);

  setUp(() async {
    appDb = await AppDatabase.open(path: inMemoryDatabasePath);
    uid = await BaseRepository(appDb.db, 'users').insert({'email': 'a@b.com', 'display_name': 'T'});
    medId = await BaseRepository(appDb.db, 'medicines').insert({
      'user_id': uid, 'name': 'Demo', 'dosage': '1', 'type': 'tablet',
      'food_instruction': 'after_food', 'start_date': '2026-01-01'});
    inv = InventoryRepository(appDb.db);
    intake = IntakeRepository(appDb.db);
    await inv.save(medicineId: medId, quantity: 10, threshold: 3, doseQuantity: 1);
  });
  tearDown(() => appDb.close());

  Future<double> remaining() async => (await inv.forMedicine(medId))!.remaining;

  test('taking a dose deducts exactly once, even if recorded twice', () async {
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    expect(await remaining(), 9);
  });

  test('different doses each deduct', () async {
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    await intake.record(medicineId: medId, scheduledAt: at2, status: IntakeStatus.taken);
    expect(await remaining(), 8);
  });

  test('changing taken to skipped gives the stock back; taking again deducts again', () async {
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.skipped);
    expect(await remaining(), 10);
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    expect(await remaining(), 9);
  });

  test('stock never goes below zero; manual adjust and refill work', () async {
    final item = (await inv.forMedicine(medId))!;
    await inv.adjust(item.id, -50);
    expect(await remaining(), 0);
    await inv.adjust(item.id, 20);
    expect(await remaining(), 20);
    final history = await inv.history(item.id);
    expect(history.map((m) => m.reason), containsAll(['initial', 'manual', 'refill']));
  });

  test('reconcile does not double-deduct', () async {
    await intake.record(medicineId: medId, scheduledAt: at1, status: IntakeStatus.taken);
    await inv.reconcileTaken(uid);
    expect(await remaining(), 9);
  });

  test('stock status priority', () {
    final now = DateTime(2026, 3, 2);
    InventoryItem item(double rem, {DateTime? exp}) => InventoryItem(
        id: 'i', medicineId: 'm', initial: 10, remaining: rem, threshold: 3, doseQuantity: 1, expiry: exp);
    expect(item(10).statusOn(now), StockStatus.ok);
    expect(item(3).statusOn(now), StockStatus.low);
    expect(item(0).statusOn(now), StockStatus.out);
    expect(item(10, exp: DateTime(2026, 3, 20)).statusOn(now), StockStatus.expiringSoon);
    expect(item(10, exp: DateTime(2026, 3, 1)).statusOn(now), StockStatus.expired);
    expect(item(0, exp: DateTime(2026, 3, 1)).statusOn(now), StockStatus.expired);
  });
}
