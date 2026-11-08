enum StockStatus { ok, expiringSoon, low, out, expired }

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.medicineId,
    required this.initial,
    required this.remaining,
    required this.threshold,
    required this.doseQuantity,
    this.expiry,
  });

  final String id;
  final String medicineId;
  final double initial;
  final double remaining;
  final double threshold; // low-stock alert level
  final double doseQuantity; // units used per dose
  final DateTime? expiry;

  static const expiryWarnDays = 30;

  factory InventoryItem.fromMap(Map<String, Object?> m) => InventoryItem(
        id: m['id'] as String,
        medicineId: m['medicine_id'] as String,
        initial: (m['initial_quantity'] as num).toDouble(),
        remaining: (m['remaining_quantity'] as num).toDouble(),
        threshold: (m['low_stock_threshold'] as num).toDouble(),
        doseQuantity: (m['dose_quantity'] as num).toDouble(),
        expiry: m['expiry_date'] == null ? null : DateTime.parse(m['expiry_date'] as String),
      );

  /// Priority: expired > out > low > expiring soon > ok.
  StockStatus statusOn(DateTime now) {
    int? daysLeft;
    if (expiry != null) {
      final e = DateTime(expiry!.year, expiry!.month, expiry!.day);
      final n = DateTime(now.year, now.month, now.day);
      daysLeft = e.difference(n).inDays;
    }
    if (daysLeft != null && daysLeft < 0) return StockStatus.expired;
    if (remaining <= 0) return StockStatus.out;
    if (remaining <= threshold) return StockStatus.low;
    if (daysLeft != null && daysLeft <= expiryWarnDays) return StockStatus.expiringSoon;
    return StockStatus.ok;
  }
}

class StockMovement {
  const StockMovement(this.change, this.reason, this.at);
  final double change;
  final String reason; // initial | intake | manual | refill
  final DateTime at;
}

String formatQty(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
