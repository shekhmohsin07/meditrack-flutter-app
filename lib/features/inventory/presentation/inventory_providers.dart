import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import '../data/inventory_repository.dart';
import '../domain/inventory.dart';

final inventoryRepositoryProvider = FutureProvider<InventoryRepository>(
    (ref) async => InventoryRepository((await ref.watch(databaseProvider.future)).db));

class StockRow {
  const StockRow(this.medicine, this.item);
  final Medicine medicine;
  final InventoryItem? item;
}

/// Active medicines with their stock (if any). Rows needing attention come first.
final stockRowsProvider = FutureProvider.autoDispose<List<StockRow>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final db = (await ref.watch(databaseProvider.future)).db;
  final inv = await ref.watch(inventoryRepositoryProvider.future);
  await inv.reconcileTaken(s.id);
  final meds = await MedicineRepository(db).list(s.id, completed: false, memberId: ref.watch(activeMemberProvider));
  final stock = await inv.allForUser(s.id);
  final now = DateTime.now();
  final rows = [for (final m in meds) StockRow(m, stock[m.id])];
  int rank(StockRow r) => r.item == null ? 9 : 4 - r.item!.statusOn(now).index; // worse status => smaller number
  rows.sort((a, b) => rank(a).compareTo(rank(b)));
  return rows;
});

/// Rows that currently need attention (low / out / expired / expiring) - used by the dashboard later.
final stockAlertsProvider = FutureProvider.autoDispose<List<StockRow>>((ref) async {
  final rows = await ref.watch(stockRowsProvider.future);
  final now = DateTime.now();
  return rows.where((r) => r.item != null && r.item!.statusOn(now) != StockStatus.ok).toList();
});
