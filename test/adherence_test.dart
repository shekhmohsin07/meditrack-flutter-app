import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';

HistoryEntry e(DateTime at, IntakeStatus s) =>
    HistoryEntry(medicineId: 'm', medicineName: 'Demo', dosage: '1', scheduledAt: at, status: s);

void main() {
  test('adherence = taken / (taken + missed + skipped); pending ignored', () {
    final s = AdherenceStats.from([
      IntakeStatus.taken, IntakeStatus.taken, IntakeStatus.taken,
      IntakeStatus.missed, IntakeStatus.pending, IntakeStatus.snoozed,
    ]);
    expect(s.resolved, 4);
    expect(s.percent, 75);
  });

  test('no resolved doses gives null, not 0 or a crash', () {
    expect(AdherenceStats.from(const []).percent, isNull);
    expect(AdherenceStats.from([IntakeStatus.pending]).percent, isNull);
  });

  test('week range starts on Monday and lasts 7 days', () {
    final r = DateRange.of(ReportPeriod.week, DateTime(2026, 3, 4)); // Wednesday
    expect(r.from, DateTime(2026, 3, 2));
    expect(r.to, DateTime(2026, 3, 9));
    expect(r.days, 7);
  });

  test('month and day ranges', () {
    final m = DateRange.of(ReportPeriod.month, DateTime(2026, 2, 15));
    expect(m.from, DateTime(2026, 2, 1));
    expect(m.days, 28);
    expect(DateRange.of(ReportPeriod.day, DateTime(2026, 2, 15, 13)).days, 1);
  });

  test('daily percentages per day', () {
    final range = DateRange.of(ReportPeriod.week, DateTime(2026, 3, 2));
    final d = AdherenceStats.daily([
      e(DateTime(2026, 3, 2, 8), IntakeStatus.taken),
      e(DateTime(2026, 3, 2, 20), IntakeStatus.missed),
      e(DateTime(2026, 3, 3, 8), IntakeStatus.taken),
    ], range);
    expect(d.length, 7);
    expect(d[DateTime(2026, 3, 2)], 50);
    expect(d[DateTime(2026, 3, 3)], 100);
    expect(d[DateTime(2026, 3, 4)], isNull);
  });
}
