import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/shared/widgets/confirm_dialog.dart';
import '../domain/health_record.dart';
import 'health_form_screen.dart';
import 'health_labels.dart';
import 'health_providers.dart';

/// Health records with a type filter, date filter, trend chart and list.
/// MediTrack only stores and charts what you enter; it does not interpret values.
class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key, this.initialType});
  final HealthType? initialType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final type = ref.watch(healthTypeFilterProvider);
    final range = ref.watch(healthRangeProvider);
    final records = ref.watch(healthRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.healthRecords)),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addHealthRecord,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthFormScreen(initialType: type))),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        const ProfileSelector(),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: 8),
            children: [
              for (final e in HealthType.values) ...[
                ChoiceChip(
                  label: Text(t.healthTypeLabel(e)),
                  selected: type == e,
                  onSelected: (_) => ref.read(healthTypeFilterProvider.notifier).state = e,
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Row(children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(range == null
                  ? t.allDates
                  : '${DateFormat.MMMd(locale).format(range.start)} – ${DateFormat.MMMd(locale).format(range.end)}'),
              onPressed: () async {
                final r = await showDateRangePicker(
                    context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDateRange: range);
                if (r != null) ref.read(healthRangeProvider.notifier).state = r;
              },
            ),
            if (range != null)
              IconButton(icon: const Icon(Icons.clear), onPressed: () => ref.read(healthRangeProvider.notifier).state = null),
          ]),
        ),
        Expanded(
          child: records.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(t.loadError),
                TextButton(onPressed: () => ref.invalidate(healthRecordsProvider), child: Text(t.retry)),
              ]),
            ),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noHealthRecords, style: Theme.of(context).textTheme.bodySmall))
                : ListView(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    children: [
                      if (type.isNumeric) HealthTrendChart(records: list, type: type),
                      for (final r in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              title: Text(healthValueText(r), style: Theme.of(context).textTheme.titleMedium),
                              subtitle: Text(
                                  '${healthDateText(r.recordedAt, locale)}${r.type.isNumeric && (r.note ?? '').isNotEmpty ? '\n${r.note}' : ''}'),
                              isThreeLine: r.type.isNumeric && (r.note ?? '').isNotEmpty,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthFormScreen(existing: r))),
                              trailing: IconButton(
                                tooltip: t.delete,
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () async {
                                  if (!await confirmDelete(context)) return;
                                  await (await ref.read(healthRepositoryProvider.future)).remove(r.id);
                                  ref.invalidate(healthRecordsProvider);
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ]),
    );
  }
}

/// Line chart of the numeric values over time. Only records that use the same unit
/// as the newest record are plotted, so mixed units are never drawn on one axis.
class HealthTrendChart extends StatelessWidget {
  const HealthTrendChart({super.key, required this.records, required this.type});
  final List<HealthRecord> records; // newest first
  final HealthType type;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final unit = records.first.unit;
    final data = records.where((r) => r.unit == unit && r.value1 != null).toList().reversed.toList(); // oldest first
    if (data.length < 2) return const SizedBox.shrink();

    final t0 = data.first.recordedAt;
    double x(HealthRecord r) => r.recordedAt.difference(t0).inMinutes / 1440.0; // days since first
    final span = x(data.last);
    final style = Theme.of(context).textTheme.bodySmall;

    LineChartBarData line(List<FlSpot> spots, Color c) => LineChartBarData(
          spots: spots,
          isCurved: false,
          color: c,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        );

    final lines = [
      line([for (final r in data) FlSpot(x(r), r.value1!)], AppColors.primaryBlue),
      if (type == HealthType.bloodPressure)
        line([for (final r in data) FlSpot(x(r), r.value2 ?? 0)], AppColors.info),
    ];
    final allY = [for (final r in data) ...[r.value1!, if (type == HealthType.bloodPressure) r.value2 ?? 0]];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.15).clamp(1.0, 1000.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            minY: (minY - pad).floorToDouble(),
            maxY: (maxY + pad).ceilToDouble(),
            minX: 0,
            maxX: span <= 0 ? 1 : span,
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            lineBarsData: lines,
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: style),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: span <= 4 ? 1 : (span / 4).ceilToDouble(),
                  getTitlesWidget: (v, meta) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(DateFormat.Md(locale).format(t0.add(Duration(minutes: (v * 1440).round()))), style: style),
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
