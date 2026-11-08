import 'dart:math';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/inventory.dart';

/// Stock levels. All changes that touch several rows run inside ONE transaction.
/// stock_history.log_id is UNIQUE, so one intake can never deduct stock twice.
class InventoryRepository extends BaseRepository {
  InventoryRepository(Database db) : super(db, 'inventory');
  late final BaseRepository _history = BaseRepository(db, 'stock_history');

  Future<InventoryItem?> forMedicine(String medicineId) async {
    final rows = await db.query('inventory',
        where: 'medicine_id = ? AND deleted_at IS NULL', whereArgs: [medicineId], limit: 1);
    return rows.isEmpty ? null : InventoryItem.fromMap(rows.first);
  }

  Future<Map<String, InventoryItem>> allForUser(String userId) async {
    final rows = await db.rawQuery(
        'SELECT i.* FROM inventory i JOIN medicines m ON m.id = i.medicine_id '
        'WHERE m.user_id = ? AND i.deleted_at IS NULL AND m.deleted_at IS NULL',
        [userId]);
    return {for (final r in rows) r['medicine_id'] as String: InventoryItem.fromMap(r)};
  }

  /// Creates stock for a medicine (existing == null) or edits it.
  /// For an existing item, a changed [quantity] is recorded as a manual adjustment.
  Future<void> save({
    InventoryItem? existing,
    required String medicineId,
    required double quantity, // initial quantity when new, remaining when editing
    required double threshold,
    required double doseQuantity,
    DateTime? expiry,
  }) {
    final expiryStr = expiry?.toIso8601String().substring(0, 10);
    return db.transaction((txn) async {
      if (existing == null) {
        final id = await insertIn(txn, {
          'medicine_id': medicineId,
          'initial_quantity': quantity,
          'remaining_quantity': quantity,
          'low_stock_threshold': threshold,
          'dose_quantity': doseQuantity,
          'expiry_date': expiryStr,
        });
        await _history.insertIn(txn, {'inventory_id': id, 'change_amount': quantity, 'reason': 'initial'});
      } else {
        await updateIn(txn, existing.id, {
          'remaining_quantity': quantity,
          'low_stock_threshold': threshold,
          'dose_quantity': doseQuantity,
          'expiry_date': expiryStr,
        });
        final diff = quantity - existing.remaining;
        if (diff != 0) {
          await _history.insertIn(txn, {'inventory_id': existing.id, 'change_amount': diff, 'reason': 'manual'});
        }
      }
    });
  }

  /// Manual change: positive = refill, negative = correction. Never goes below 0.
  Future<void> adjust(String inventoryId, double delta) => db.transaction((txn) async {
        final row = await txn.query('inventory', where: 'id = ?', whereArgs: [inventoryId], limit: 1);
        if (row.isEmpty) return;
        final remaining = (row.first['remaining_quantity'] as num).toDouble();
        final next = max(0.0, remaining + delta);
        final actual = next - remaining;
        if (actual == 0) return;
        await updateIn(txn, inventoryId, {'remaining_quantity': next});
        await _history.insertIn(txn, {
          'inventory_id': inventoryId,
          'change_amount': actual,
          'reason': actual > 0 ? 'refill' : 'manual',
        });
      });

  /// Deducts one dose for a "taken" log. Safe to call repeatedly for the same log.
  Future<void> deductForLog(String logId, String medicineId) => db.transaction((txn) async {
        final dup = await txn.query('stock_history', columns: ['id'], where: 'log_id = ?', whereArgs: [logId], limit: 1);
        if (dup.isNotEmpty) return; // already deducted
        final inv = await txn.query('inventory',
            where: 'medicine_id = ? AND deleted_at IS NULL', whereArgs: [medicineId], limit: 1);
        if (inv.isEmpty) return; // no stock tracking for this medicine
        final id = inv.first['id'] as String;
        final remaining = (inv.first['remaining_quantity'] as num).toDouble();
        final dose = (inv.first['dose_quantity'] as num).toDouble();
        final next = max(0.0, remaining - dose);
        await _history.insertIn(txn, {'inventory_id': id, 'log_id': logId, 'change_amount': next - remaining, 'reason': 'intake'});
        await updateIn(txn, id, {'remaining_quantity': next});
      });

  /// If a "taken" log is changed to something else, give the stock back.
  Future<void> reverseForLog(String logId) => db.transaction((txn) async {
        final h = await txn.query('stock_history', where: 'log_id = ?', whereArgs: [logId], limit: 1);
        if (h.isEmpty) return;
        final invId = h.first['inventory_id'] as String;
        final give = -(h.first['change_amount'] as num).toDouble();
        await _history.updateIn(txn, h.first['id'] as String, {'log_id': null});
        if (give <= 0) return;
        final inv = await txn.query('inventory', where: 'id = ?', whereArgs: [invId], limit: 1);
        if (inv.isEmpty) return;
        final remaining = (inv.first['remaining_quantity'] as num).toDouble();
        await updateIn(txn, invId, {'remaining_quantity': remaining + give});
        await _history.insertIn(txn, {'inventory_id': invId, 'change_amount': give, 'reason': 'manual'});
      });

  /// Safety net: deduct for "taken" logs that were recorded after stock tracking
  /// started but never got a stock_history row (e.g. the app was killed mid-write).
  Future<void> reconcileTaken(String userId) async {
    final rows = await db.rawQuery(
        'SELECT l.id AS log_id, l.medicine_id AS medicine_id FROM medicine_logs l '
        'JOIN medicines m ON m.id = l.medicine_id '
        'JOIN inventory i ON i.medicine_id = l.medicine_id '
        "WHERE m.user_id = ? AND l.status = 'taken' AND l.deleted_at IS NULL AND i.deleted_at IS NULL "
        'AND l.action_at >= i.created_at '
        'AND NOT EXISTS (SELECT 1 FROM stock_history h WHERE h.log_id = l.id)',
        [userId]);
    for (final r in rows) {
      await deductForLog(r['log_id'] as String, r['medicine_id'] as String);
    }
  }

  Future<List<StockMovement>> history(String inventoryId) async {
    final rows = await db.query('stock_history',
        where: 'inventory_id = ? AND deleted_at IS NULL', whereArgs: [inventoryId], orderBy: 'created_at DESC', limit: 100);
    return [
      for (final r in rows)
        StockMovement((r['change_amount'] as num).toDouble(), r['reason'] as String,
            DateTime.parse(r['created_at'] as String).toLocal())
    ];
  }
}
