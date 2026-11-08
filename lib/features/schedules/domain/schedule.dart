import 'package:meditrack/features/medicines/domain/medicine.dart';

enum Frequency { daily, weekly, custom }

class Schedule {
  const Schedule({
    required this.id,
    required this.medicineId,
    required this.frequency,
    required this.days,
    required this.startDate,
    required this.times,
    this.endDate,
    this.paused = false,
    this.updatedAt,
  });

  final String id; // '' for a new schedule
  final String medicineId;
  final Frequency frequency;
  final Set<int> days; // 1 = Monday ... 7 = Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final bool paused;
  final List<String> times; // 'HH:mm'
  final DateTime? updatedAt; // when this schedule last changed

  Schedule copyWith({bool? paused}) => Schedule(
      id: id, medicineId: medicineId, frequency: frequency, days: days,
      startDate: startDate, endDate: endDate, times: times, paused: paused ?? this.paused, updatedAt: updatedAt);
}

class ScheduleEntry {
  const ScheduleEntry(this.schedule, this.medicine);
  final Schedule schedule;
  final Medicine medicine;
}

class Dose {
  const Dose(this.schedule, this.medicine, this.at);
  final Schedule schedule;
  final Medicine medicine;
  final DateTime at; // local time
}

/// Pure scheduling maths (no database, no Flutter) - easy to unit test.
class ScheduleLogic {
  ScheduleLogic._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool runsOn(Schedule s, Medicine m, DateTime day) {
    if (s.paused || m.completed) return false;
    final d = dateOnly(day);
    if (d.isBefore(dateOnly(s.startDate)) || d.isBefore(dateOnly(m.startDate))) return false;
    if (s.endDate != null && d.isAfter(dateOnly(s.endDate!))) return false;
    if (m.endDate != null && d.isAfter(dateOnly(m.endDate!))) return false;
    return s.frequency == Frequency.daily || s.days.contains(d.weekday);
  }

  /// All dose date-times between [from] and [to] (inclusive), sorted.
  static List<Dose> dosesBetween(List<ScheduleEntry> entries, DateTime from, DateTime to) {
    final doses = <Dose>[];
    for (var day = dateOnly(from); !day.isAfter(to); day = DateTime(day.year, day.month, day.day + 1)) {
      for (final e in entries) {
        if (!runsOn(e.schedule, e.medicine, day)) continue;
        for (final t in e.schedule.times) {
          final parts = t.split(':');
          final at = DateTime(day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]));
          if (!at.isBefore(from) && !at.isAfter(to)) doses.add(Dose(e.schedule, e.medicine, at));
        }
      }
    }
    doses.sort((a, b) => a.at.compareTo(b.at));
    return doses;
  }
}
