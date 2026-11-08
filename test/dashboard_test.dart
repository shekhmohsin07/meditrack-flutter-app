import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/dashboard/presentation/dashboard_screen.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/schedules/domain/schedule.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:flutter/material.dart';
import 'helpers/test_app.dart';

DoseStatus dose(String name, Duration fromNow, IntakeStatus? status) {
  final med = testMedicine(name);
  final at = DateTime.now().add(fromNow);
  final sched = Schedule(
      id: 's', medicineId: med.id, frequency: Frequency.daily, days: const {1, 2, 3, 4, 5, 6, 7},
      startDate: DateTime(2026, 1, 1), times: const ['08:00']);
  return DoseStatus(Dose(sched, med, at), status);
}

void main() {
  testWidgets('dashboard shows summary cards, next medicine and quick actions', (tester) async {
    final today = [
      dose('Aspirin', const Duration(hours: -3), IntakeStatus.taken),
      dose('Vitamin D', const Duration(hours: -2), IntakeStatus.missed),
      dose('Metformin', const Duration(hours: 2), null),
    ];
    await tester.pumpWidget(await buildTestApp(const DashboardScreen(), overrides: dataOverrides(today: today)));
    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsWidgets);
    for (final label in ['Scheduled', 'Taken', 'Missed', 'Upcoming']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('3'), findsOneWidget); // total scheduled
    expect(find.text('Next medicine'), findsOneWidget);
    expect(find.text('Metformin'), findsWidgets);
    expect(find.text('Snooze 10 min'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Add medicine'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Add medicine'), findsOneWidget);
    expect(find.text('View reports'), findsOneWidget);
  });

  testWidgets('dashboard with no doses shows the empty state', (tester) async {
    await tester.pumpWidget(await buildTestApp(const DashboardScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();
    expect(find.text('No doses scheduled for this day.'), findsWidgets);
  });
}
