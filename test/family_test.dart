import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/family/data/family_repository.dart';
import 'package:meditrack/features/family/domain/family_member.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late AppDatabase appDb;
  late String uid;
  setUp(() async {
    appDb = await AppDatabase.open(path: inMemoryDatabasePath);
    uid = await BaseRepository(appDb.db, 'users').insert({'email': 'a@b.com', 'display_name': 'T'});
  });
  tearDown(() => appDb.close());

  Medicine med(String name, {String? memberId}) => Medicine(
      id: '', userId: uid, memberId: memberId, name: name, dosage: '1', type: MedicineType.tablet,
      food: FoodInstruction.afterFood, startDate: DateTime(2026, 1, 1));

  test('each profile sees only its own medicines', () async {
    final family = FamilyRepository(appDb.db);
    final meds = MedicineRepository(appDb.db);
    final memberId = await family.add(uid, const FamilyMember(id: '', name: 'Mum', relationship: 'parent'));
    await meds.add(med('Mine'));
    await meds.add(med('Mums', memberId: memberId));
    expect((await meds.list(uid)).map((m) => m.name), ['Mine']);
    expect((await meds.list(uid, memberId: memberId)).map((m) => m.name), ['Mums']);
  });

  test('consent is stored with a timestamp and can be withdrawn', () async {
    final family = FamilyRepository(appDb.db);
    final id = await family.add(uid, FamilyMember(id: '', name: 'Dad', relationship: 'parent', caregiverConsent: true, consentAt: DateTime.now()));
    var m = (await family.list(uid)).single;
    expect(m.caregiverConsent, isTrue);
    expect(m.consentAt, isNotNull);
    await family.edit(uid, FamilyMember(id: id, name: 'Dad', relationship: 'parent'));
    m = (await family.list(uid)).single;
    expect(m.caregiverConsent, isFalse);
    expect(m.consentAt, isNull);
  });

  test('removing a member hides their medicines but not other data', () async {
    final family = FamilyRepository(appDb.db);
    final meds = MedicineRepository(appDb.db);
    final memberId = await family.add(uid, const FamilyMember(id: '', name: 'Sam', relationship: 'child'));
    await meds.add(med('Sams', memberId: memberId));
    await meds.add(med('Mine'));
    await family.remove(memberId);
    expect(await family.list(uid), isEmpty);
    expect((await meds.list(uid, memberId: memberId)), isEmpty);
    expect((await meds.list(uid)).length, 1);
  });
}
