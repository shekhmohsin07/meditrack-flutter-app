import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import '../data/medicine_repository.dart';
import '../domain/medicine.dart';

final medicineRepositoryProvider = FutureProvider<MedicineRepository>(
    (ref) async => MedicineRepository((await ref.watch(databaseProvider.future)).db));

final medicineSearchProvider = StateProvider<String>((ref) => '');
final medicineFilterProvider = StateProvider<bool?>((ref) => null); // null=all, false=active, true=completed
final medicineSortProvider = StateProvider<MedicineSort>((ref) => MedicineSort.name);

final medicinesProvider = FutureProvider.autoDispose<List<Medicine>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  await ref.watch(localUserProvider(session).future);
  final repo = await ref.watch(medicineRepositoryProvider.future);
  return repo.list(
    session.id,
    memberId: ref.watch(activeMemberProvider),
    query: ref.watch(medicineSearchProvider),
    completed: ref.watch(medicineFilterProvider),
    sort: ref.watch(medicineSortProvider),
  );
});
