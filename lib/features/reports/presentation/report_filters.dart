import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'report_providers.dart';

/// Period selector, date navigation and medicine filter shared by the report tabs.
class ReportFilters extends ConsumerWidget {
  const ReportFilters({super.key, this.showPeriod = true});
  final bool showPeriod;

  String _label(ReportPeriod p, DateRange r, String locale) {
    switch (p) {
      case ReportPeriod.day:
        return DateFormat.yMMMd(locale).format(r.from);
      case ReportPeriod.week:
        final last = DateTime(r.to.year, r.to.month, r.to.day - 1);
        return '${DateFormat.MMMd(locale).format(r.from)} – ${DateFormat.MMMd(locale).format(last)}';
      case ReportPeriod.month:
        return DateFormat.yMMMM(locale).format(r.from);
    }
  }

  DateTime _shift(ReportPeriod p, DateTime a, int dir) => switch (p) {
        ReportPeriod.day => DateTime(a.year, a.month, a.day + dir),
        ReportPeriod.week => DateTime(a.year, a.month, a.day + 7 * dir),
        ReportPeriod.month => DateTime(a.year, a.month + dir, 1),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final period = ref.watch(reportPeriodProvider);
    final anchor = ref.watch(reportAnchorProvider);
    final range = ref.watch(periodRangeProvider);
    final meds = ref.watch(filterMedicinesProvider).valueOrNull ?? const [];
    final selected = ref.watch(reportMedicineProvider);

    return Column(children: [
      const ProfileSelector(),
      Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding, 12, AppDimensions.screenPadding, 4),
      child: Column(children: [
        if (showPeriod) ...[
          SegmentedButton<ReportPeriod>(
            segments: [
              ButtonSegment(value: ReportPeriod.day, label: Text(t.periodDay)),
              ButtonSegment(value: ReportPeriod.week, label: Text(t.periodWeek)),
              ButtonSegment(value: ReportPeriod.month, label: Text(t.periodMonth)),
            ],
            selected: {period},
            onSelectionChanged: (s) => ref.read(reportPeriodProvider.notifier).state = s.first,
          ),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(reportAnchorProvider.notifier).state = _shift(period, anchor, -1),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final d = await showDatePicker(
                      context: context, initialDate: anchor, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) ref.read(reportAnchorProvider.notifier).state = d;
                },
                child: Text(_label(period, range, locale), style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(reportAnchorProvider.notifier).state = _shift(period, anchor, 1),
            ),
          ]),
        ],
        DropdownButtonFormField<String?>(
          initialValue: meds.any((m) => m.id == selected) ? selected : null,
          isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.medication_outlined)),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(t.allMedicines)),
            for (final m in meds) DropdownMenuItem<String?>(value: m.id, child: Text(m.name, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => ref.read(reportMedicineProvider.notifier).state = v,
        ),
      ]),
    ),
    ]);
  }
}
