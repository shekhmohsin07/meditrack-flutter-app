
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/l10n/app_localizations.dart';

import 'schedule_form_screen.dart';
import 'schedule_labels.dart';
import 'schedule_providers.dart';

// Lists every schedule: edit, pause/resume, delete.
class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  Future<void> _changed(BuildContext context, WidgetRef ref) async {
    ref.invalidate(scheduleEntriesProvider);
    ref.invalidate(dayDosesProvider);

    if (context.mounted) {
      await refreshReminders(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final entries = ref.watch(scheduleEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.manageSchedules)),
      body: entries.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(t.loadError),
        ),
        data: (list) => list.isEmpty
            ? Center(
          child: Text(
            t.noSchedules,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(
            AppDimensions.screenPadding,
          ),
          itemCount: list.length,
          separatorBuilder: (context, index) =>
          const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final e = list[i];
            final s = e.schedule;

            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(
                  AppDimensions.cardPadding,
                ),
                title: Text(
                  e.medicine.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${t.frequencyLabel(s.frequency)} • '
                      '${s.times.join(', ')}'
                      '${s.paused ? '\n${t.paused}' : ''}',
                ),
                isThreeLine: s.paused,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleFormScreen(
                        existing: e.schedule,
                      ),
                    ),
                  );

                  if (context.mounted) {
                    await _changed(context, ref);
                  }
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: !s.paused,
                      onChanged: (on) async {
                        await (await ref.read(
                          scheduleRepositoryProvider.future,
                        )).setPaused(s.id, !on);

                        if (context.mounted) {
                          await _changed(context, ref);
                        }
                      },
                    ),
                    IconButton(
                      tooltip: t.delete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            content: Text(t.deleteConfirm),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(c, false),
                                child: Text(t.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(c, true),
                                child: Text(t.delete),
                              ),
                            ],
                          ),
                        );

                        if (ok == true && context.mounted) {
                          await (await ref.read(
                            scheduleRepositoryProvider.future,
                          )).remove(s.id);

                          if (context.mounted) {
                            await _changed(context, ref);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
