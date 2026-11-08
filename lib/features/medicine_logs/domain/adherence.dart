import 'intake_log.dart';

enum ReportPeriod { day, week, month }

/// [from] inclusive, [to] exclusive (local dates).
class DateRange {
  const DateRange(this.from, this.to);
  final DateTime from;
  final DateTime to;

  /// Week starts on Monday.
  factory DateRange.of(ReportPeriod p, DateTime anchor) {
    final d = DateTime(anchor.year, anchor.month, anchor.day);
    switch (p) {
      case ReportPeriod.day:
        return DateRange(d, DateTime(d.year, d.month, d.day + 1));
      case ReportPeriod.week:
        final start = DateTime(d.year, d.month, d.day - (d.weekday - 1));
        return DateRange(start, DateTime(start.year, start.month, start.day + 7));
      case ReportPeriod.month:
        return DateRange(DateTime(d.year, d.month), DateTime(d.year, d.month + 1));
    }
  }

  int get days => DateTime(to.year, to.month, to.day).difference(DateTime(from.year, from.month, from.day)).inDays;
}

/// Adherence = taken / (taken + missed + skipped).
/// Pending and snoozed doses are not counted until they are resolved.
/// This is a record of reminders only - never a medical assessment.
class AdherenceStats {
  const AdherenceStats(this.taken, this.missed, this.skipped);
  final int taken;
  final int missed;
  final int skipped;

  int get resolved => taken + missed + skipped;
  double? get percent => resolved == 0 ? null : taken * 100 / resolved;

  factory AdherenceStats.from(Iterable<IntakeStatus> statuses) {
    var t = 0, m = 0, s = 0;
    for (final st in statuses) {
      switch (st) {
        case IntakeStatus.taken:
          t++;
        case IntakeStatus.missed:
          m++;
        case IntakeStatus.skipped:
          s++;
        case IntakeStatus.pending:
        case IntakeStatus.snoozed:
          break;
      }
    }
    return AdherenceStats(t, m, s);
  }

  /// One adherence percentage per day in [range] (null = nothing resolved that day).
  static Map<DateTime, double?> daily(List<HistoryEntry> entries, DateRange range) {
    final byDay = <DateTime, List<IntakeStatus>>{};
    for (final e in entries) {
      final k = DateTime(e.scheduledAt.year, e.scheduledAt.month, e.scheduledAt.day);
      byDay.putIfAbsent(k, () => []).add(e.status);
    }
    return {
      for (var i = 0; i < range.days; i++)
        DateTime(range.from.year, range.from.month, range.from.day + i):
            AdherenceStats.from(byDay[DateTime(range.from.year, range.from.month, range.from.day + i)] ?? const []).percent
    };
  }
}
