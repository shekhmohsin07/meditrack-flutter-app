enum IntakeStatus {
  pending, taken, missed, skipped, snoozed;
  static IntakeStatus fromDb(String v) =>
      IntakeStatus.values.firstWhere((e) => e.name == v, orElse: () => pending);
}

class IntakeLog {
  const IntakeLog(this.id, this.medicineId, this.scheduledAt, this.status);
  final String id;
  final String medicineId;
  final DateTime scheduledAt;
  final IntakeStatus status;
  String get key => '$medicineId|${scheduledAt.toUtc().toIso8601String()}';
}

/// A log row plus the medicine's name, for history screens.
class HistoryEntry {
  const HistoryEntry({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledAt,
    required this.status,
  });
  final String medicineId;
  final String medicineName;
  final String dosage;
  final DateTime scheduledAt; // local time
  final IntakeStatus status;
}
