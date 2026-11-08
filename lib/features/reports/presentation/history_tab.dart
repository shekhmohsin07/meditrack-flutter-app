import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/schedules/presentation/schedule_labels.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'report_filters.dart';
import 'report_providers.dart';

/// Daily / weekly / monthly list of taken, missed and skipped doses.
class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final history = ref.watch(periodHistoryProvider);

    return Column(children: [
      const ReportFilters(),
      Expanded(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(t.loadError),
              TextButton(onPressed: () => ref.invalidate(periodHistoryProvider), child: Text(t.retry)),
            ]),
          ),
          data: (list) => list.isEmpty
              ? Center(child: Text(t.noHistory, style: Theme.of(context).textTheme.bodySmall))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => HistoryTile(entry: list[i], locale: locale),
                ),
        ),
      ),
    ]);
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.entry, required this.locale});
  final HistoryEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (fg, bg) = doseStatusColors(entry.status, entry.scheduledAt);
    return Card(
      child: ListTile(
        title: Text(entry.medicineName),
        subtitle: Text('${entry.dosage}\n${DateFormat.MMMd(locale).add_jm().format(entry.scheduledAt)}'),
        isThreeLine: true,
        trailing: Chip(
          label: Text(t.doseStatusLabel(entry.status, entry.scheduledAt), style: TextStyle(color: fg, fontSize: 12)),
          backgroundColor: bg,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
