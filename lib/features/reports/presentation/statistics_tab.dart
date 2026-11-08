import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'report_filters.dart';
import 'report_providers.dart';

/// Adherence percentage, outcome pie chart and per-day bar chart.
class StatisticsTab extends ConsumerWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final history = ref.watch(periodHistoryProvider);
    final range = ref.watch(periodRangeProvider);

    return Column(children: [
      const ReportFilters(),
      Expanded(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(t.loadError)),
          data: (list) {
            final stats = AdherenceStats.from(list.map((e) => e.status));
            final daily = AdherenceStats.daily(list, range);
            return ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.cardPadding),
                    child: Column(children: [
                      Text(t.adherence, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(stats.percent == null ? '—' : '${stats.percent!.round()}%',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        _CountChip(t.statusTaken, stats.taken, AppColors.success, AppColors.lightGreen),
                        _CountChip(t.statusMissed, stats.missed, AppColors.danger, AppColors.lightRed),
                        _CountChip(t.statusSkipped, stats.skipped, AppColors.textSecondary, AppColors.divider),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                if (stats.resolved == 0)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(t.noHistory, style: Theme.of(context).textTheme.bodySmall)),
                  )
                else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.cardPadding),
                      child: SizedBox(height: 180, child: _OutcomePie(stats: stats)),
                    ),
                  ),
                  if (range.days > 1) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.cardPadding),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t.dailyAdherence, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          SizedBox(height: 200, child: DailyAdherenceBars(daily: daily, color: AppColors.primaryBlue)),
                        ]),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Text(t.adherenceNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
        ),
      ),
    ]);
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip(this.label, this.count, this.fg, this.bg);
  final String label;
  final int count;
  final Color fg;
  final Color bg;
  @override
  Widget build(BuildContext context) => Chip(
        label: Text('$label: $count', style: TextStyle(color: fg, fontSize: 12)),
        backgroundColor: bg,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      );
}

class _OutcomePie extends StatelessWidget {
  const _OutcomePie({required this.stats});
  final AdherenceStats stats;

  @override
  Widget build(BuildContext context) {
    PieChartSectionData section(int v, Color c) => PieChartSectionData(
          value: v.toDouble(),
          color: c,
          radius: 56,
          title: '$v',
          titleStyle: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
        );
    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 36,
      sections: [
        if (stats.taken > 0) section(stats.taken, AppColors.success),
        if (stats.missed > 0) section(stats.missed, AppColors.danger),
        if (stats.skipped > 0) section(stats.skipped, AppColors.textSecondary),
      ],
    ));
  }
}

class DailyAdherenceBars extends StatelessWidget {
  const DailyAdherenceBars({super.key, required this.daily, required this.color});
  final Map<DateTime, double?> daily;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final days = daily.keys.toList();
    final locale = Localizations.localeOf(context).toString();
    final weekly = days.length <= 7;
    final style = Theme.of(context).textTheme.bodySmall;
    return BarChart(BarChartData(
      maxY: 100,
      minY: 0,
      gridData: const FlGridData(drawVerticalLine: false, horizontalInterval: 25),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 25,
            getTitlesWidget: (v, meta) => Text('${v.toInt()}%', style: style),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i >= days.length) return const SizedBox.shrink();
              if (!weekly && i % 5 != 0) return const SizedBox.shrink(); // avoid crowded labels in a month
              final label = weekly ? DateFormat.E(locale).format(days[i]) : '${days[i].day}';
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(label, style: style));
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < days.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: daily[days[i]] ?? 0,
              color: daily[days[i]] == null ? AppColors.divider : color,
              width: weekly ? 16 : 6,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
      ],
    ));
  }
}
