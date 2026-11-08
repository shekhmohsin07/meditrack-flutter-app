import 'package:meditrack/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../domain/health_record.dart';
import 'package:meditrack/features/inventory/domain/inventory.dart' show formatQty;

extension HealthLabels on AppLocalizations {
  String healthTypeLabel(HealthType type) => switch (type) {
        HealthType.bloodPressure => typeBloodPressure,
        HealthType.bloodGlucose => typeBloodGlucose,
        HealthType.weight => typeWeight,
        HealthType.note => typeHealthNote,
        HealthType.history => typeMedicalHistory,
      };
}

/// "120/80 mmHg", "5.6 mmol/L", "70 kg" or the note text.
String healthValueText(HealthRecord r) {
  switch (r.type) {
    case HealthType.bloodPressure:
      return '${formatQty(r.value1 ?? 0)}/${formatQty(r.value2 ?? 0)} mmHg';
    case HealthType.bloodGlucose:
    case HealthType.weight:
      return '${formatQty(r.value1 ?? 0)} ${r.unit ?? ''}'.trim();
    case HealthType.note:
    case HealthType.history:
      return r.note ?? '';
  }
}

String healthDateText(DateTime d, String locale) => DateFormat.yMMMd(locale).add_jm().format(d);
