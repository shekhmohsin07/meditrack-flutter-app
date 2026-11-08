import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/notifications/presentation/notification_history_screen.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_form_screen.dart';
import 'schedule_labels.dart';
import 'schedule_list_screen.dart';
import 'schedule_providers.dart';

/// Schedule tab: calendar + the doses planned for the selected day.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  Future<void> _mark(BuildContext context, WidgetRef ref, DoseStatus d, IntakeStatus status) =>
      markDose(context, ref, d.dose, status);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final day = ref.watch(selectedDayProvider);
    final doses = ref.watch(dayDosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navSchedule, style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
            tooltip: t.notificationHistory,
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationHistoryScreen())),
          ),
          IconButton(
            tooltip: t.manageSchedules,
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleListScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addSchedule,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        const ProfileSelector(),
        TableCalendar(
          locale: locale,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: day,
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {CalendarFormat.week: 'Week'},
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          selectedDayPredicate: (d) => isSameDay(d, day),
          onDaySelected: (selected, _) => ref.read(selectedDayProvider.notifier).state = selected,
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: AppColors.lightBlue, shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: AppColors.darkNavy),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: doses.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(t.loadError),
                TextButton(onPressed: () => ref.invalidate(dayDosesProvider), child: Text(t.retry)),
              ]),
            ),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noDosesToday, style: Theme.of(context).textTheme.bodySmall))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final d = list[i];
                      final (fg, bg) = doseStatusColors(d.status, d.dose.at);
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppDimensions.cardPadding),
                          leading: Text(DateFormat.jm(locale).format(d.dose.at),
                              style: Theme.of(context).textTheme.titleMedium),
                          title: Text(d.dose.medicine.name),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                              Text(d.dose.medicine.dosage),
                              Chip(
                                label: Text(t.doseStatusLabel(d.status, d.dose.at), style: TextStyle(color: fg, fontSize: 12)),
                                backgroundColor: bg,
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ),
                            ]),
                          ),
                          trailing: PopupMenuButton<IntakeStatus>(
                            onSelected: (s) => _mark(context, ref, d, s),
                            itemBuilder: (_) => [
                              PopupMenuItem(value: IntakeStatus.taken, child: Text(t.markTaken)),
                              PopupMenuItem(value: IntakeStatus.skipped, child: Text(t.markSkipped)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
