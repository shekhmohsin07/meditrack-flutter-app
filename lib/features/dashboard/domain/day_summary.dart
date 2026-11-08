import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';

/// Counts for the four dashboard cards.
class DaySummary {
  const DaySummary(this.total, this.taken, this.missed, this.upcoming);
  final int total;
  final int taken;
  final int missed;
  final int upcoming;

  factory DaySummary.from(Iterable<({DateTime at, IntakeStatus? status})> doses, DateTime now) {
    var total = 0, taken = 0, missed = 0, upcoming = 0;
    for (final d in doses) {
      total++;
      if (d.status == IntakeStatus.taken) {
        taken++;
      } else if (d.status == IntakeStatus.missed) {
        missed++;
      } else if ((d.status == null || d.status == IntakeStatus.snoozed || d.status == IntakeStatus.pending) &&
          d.at.isAfter(now)) {
        upcoming++;
      }
    }
    return DaySummary(total, taken, missed, upcoming);
  }
}
