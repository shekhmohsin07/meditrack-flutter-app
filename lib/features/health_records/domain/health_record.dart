enum HealthType {
  bloodPressure('blood_pressure'),
  bloodGlucose('blood_glucose'),
  weight('weight'),
  note('note'),
  history('history');

  const HealthType(this.dbValue);
  final String dbValue;
  bool get isNumeric => this == bloodPressure || this == bloodGlucose || this == weight;
  static HealthType fromDb(String v) => HealthType.values.firstWhere((e) => e.dbValue == v, orElse: () => note);
}

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.type,
    required this.recordedAt,
    this.value1,
    this.value2,
    this.unit,
    this.note,
  });
  final String id; // '' when new
  final HealthType type;
  final double? value1; // systolic / glucose / weight
  final double? value2; // diastolic
  final String? unit;
  final String? note;
  final DateTime recordedAt; // local

  factory HealthRecord.fromMap(Map<String, Object?> m) => HealthRecord(
        id: m['id'] as String,
        type: HealthType.fromDb(m['type'] as String),
        value1: (m['value1'] as num?)?.toDouble(),
        value2: (m['value2'] as num?)?.toDouble(),
        unit: m['unit'] as String?,
        note: m['note'] as String?,
        recordedAt: DateTime.parse(m['recorded_at'] as String).toLocal(),
      );

  Map<String, Object?> toMap(String userId) => {
        'user_id': userId,
        'type': type.dbValue,
        'value1': value1,
        'value2': value2,
        'unit': unit,
        'note': note,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
      };
}

/// Only catches impossible values / typing mistakes. It NEVER labels a reading
/// as high, low or normal - MediTrack does not interpret health data.
class HealthValidators {
  HealthValidators._();

  static String? check(HealthType type, {double? v1, double? v2, String? unit, String? note}) {
    switch (type) {
      case HealthType.bloodPressure:
        if (v1 == null || v2 == null) return 'requiredField';
        if (v1 < 40 || v1 > 300 || v2 < 20 || v2 > 200 || v2 >= v1) return 'outOfRange';
      case HealthType.bloodGlucose:
        if (v1 == null) return 'requiredField';
        final mmol = unit == 'mmol/L';
        if (mmol ? (v1 < 0.5 || v1 > 55) : (v1 < 10 || v1 > 1000)) return 'outOfRange';
      case HealthType.weight:
        if (v1 == null) return 'requiredField';
        final lb = unit == 'lb';
        if (lb ? (v1 < 2 || v1 > 1100) : (v1 < 1 || v1 > 500)) return 'outOfRange';
      case HealthType.note:
      case HealthType.history:
        if (note == null || note.trim().isEmpty) return 'requiredField';
    }
    return null;
  }
}
