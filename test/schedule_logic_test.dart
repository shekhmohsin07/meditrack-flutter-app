import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/features/schedules/domain/schedule.dart';

Medicine med({DateTime? end, bool completed = false}) => Medicine(
    id: 'm1', userId: 'u', name: 'Demo', dosage: '1', type: MedicineType.tablet,
    food: FoodInstruction.afterFood, startDate: DateTime(2026, 1, 1), endDate: end, completed: completed);

Schedule sched({Frequency f = Frequency.daily, Set<int>? days, bool paused = false, DateTime? end, List<String>? times}) =>
    Schedule(id: 's', medicineId: 'm1', frequency: f, days: days ?? {1, 2, 3, 4, 5, 6, 7},
        startDate: DateTime(2026, 1, 1), endDate: end, paused: paused, times: times ?? ['08:00', '20:00']);

void main() {
  test('daily schedule gives every time on every day', () {
    final doses = ScheduleLogic.dosesBetween(
        [ScheduleEntry(sched(), med())], DateTime(2026, 3, 2), DateTime(2026, 3, 3, 23, 59));
    expect(doses.length, 4);
    expect(doses.first.at, DateTime(2026, 3, 2, 8));
  });

  test('weekly schedule only runs on chosen weekdays', () {
    // 2026-03-02 is a Monday
    final e = ScheduleEntry(sched(f: Frequency.weekly, days: {1}), med());
    expect(ScheduleLogic.runsOn(e.schedule, e.medicine, DateTime(2026, 3, 2)), isTrue);
    expect(ScheduleLogic.runsOn(e.schedule, e.medicine, DateTime(2026, 3, 3)), isFalse);
  });

  test('paused, completed and ended schedules produce no doses', () {
    final from = DateTime(2026, 3, 2);
    final to = DateTime(2026, 3, 2, 23, 59);
    expect(ScheduleLogic.dosesBetween([ScheduleEntry(sched(paused: true), med())], from, to), isEmpty);
    expect(ScheduleLogic.dosesBetween([ScheduleEntry(sched(), med(completed: true))], from, to), isEmpty);
    expect(ScheduleLogic.dosesBetween([ScheduleEntry(sched(end: DateTime(2026, 3, 1)), med())], from, to), isEmpty);
    expect(ScheduleLogic.dosesBetween([ScheduleEntry(sched(), med(end: DateTime(2026, 3, 1)))], from, to), isEmpty);
  });

  test('doses before "from" are excluded', () {
    final doses = ScheduleLogic.dosesBetween(
        [ScheduleEntry(sched(), med())], DateTime(2026, 3, 2, 9), DateTime(2026, 3, 2, 23, 59));
    expect(doses.single.at, DateTime(2026, 3, 2, 20));
  });
}
