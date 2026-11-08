import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'history_tab.dart';
import 'report_filters.dart';
import 'report_providers.dart';

/// Month calendar. Dot colour: green = all taken, red = something missed, orange = other.
class CalendarTab extends ConsumerWidget {
  const CalendarTab({super.key});

  Color _dotColor(List<HistoryEntry> day) {
    if (day.any((e) => e.status == IntakeStatus.missed)) return AppColors.danger;
    if (day.every((e) => e.status == IntakeStatus.taken)) return AppColors.success;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final anchor = ref.watch(reportAnchorProvider);
    final month = ref.watch(monthHistoryProvider);

    return Column(children: [
      const ReportFilters(showPeriod: false),
      month.when(
        loading: () => const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
        error: (_, __) => Padding(padding: const EdgeInsets.all(24), child: Text(t.loadError)),
        data: (entries) {
          final byDay = <DateTime, List<HistoryEntry>>{};
          for (final e in entries) {
            byDay.putIfAbsent(DateTime(e.scheduledAt.year, e.scheduledAt.month, e.scheduledAt.day), () => []).add(e);
          }
          final selected = byDay[DateTime(anchor.year, anchor.month, anchor.day)] ?? const <HistoryEntry>[];
          return Expanded(
            child: Column(children: [
              TableCalendar<HistoryEntry>(
                locale: locale,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: anchor,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                selectedDayPredicate: (d) => isSameDay(d, anchor),
                onDaySelected: (d, _) => ref.read(reportAnchorProvider.notifier).state = d,
                onPageChanged: (d) => ref.read(reportAnchorProvider.notifier).state = d,
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: AppColors.lightBlue, shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: AppColors.darkNavy),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, _) {
                    final list = byDay[DateTime(day.year, day.month, day.day)];
                    if (list == null || list.isEmpty) return null;
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: _dotColor(list), shape: BoxShape.circle),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: selected.isEmpty
                    ? Center(child: Text(t.noHistory, style: Theme.of(context).textTheme.bodySmall))
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.screenPadding),
                        itemCount: selected.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => HistoryTile(entry: selected[i], locale: locale),
                      ),
              ),
            ]),
          );
        },
      ),
    ]);
  }
}
