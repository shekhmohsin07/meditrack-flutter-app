import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart' show refreshReminders;
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/shared/widgets/confirm_dialog.dart';
import '../domain/appointment.dart';
import 'appointment_form_screen.dart';
import 'appointment_providers.dart';

/// Upcoming appointments and appointment history.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  Future<void> _after(BuildContext context, WidgetRef ref) async {
    ref.invalidate(appointmentsProvider);
    if (context.mounted) await refreshReminders(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final appts = ref.watch(appointmentsProvider);

    Widget list(List<Appointment> items, {required bool upcoming}) => items.isEmpty
        ? Center(child: Text(upcoming ? t.noUpcomingAppointments : t.noAppointmentHistory,
            style: Theme.of(context).textTheme.bodySmall))
        : ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final a = items[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppDimensions.cardPadding),
                  leading: const CircleAvatar(
                      backgroundColor: AppColors.lightBlue, child: Icon(Icons.local_hospital, color: AppColors.primaryBlue)),
                  title: Text(a.doctorName, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text([
                    DateFormat.yMMMEd(locale).add_jm().format(a.at),
                    if ((a.hospital ?? '').isNotEmpty) a.hospital!,
                    if (a.status != 'upcoming') (a.status == 'completed' ? t.appointmentCompleted : t.appointmentCancelled),
                    if ((a.notes ?? '').isNotEmpty) a.notes!,
                  ].join('\n')),
                  isThreeLine: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentFormScreen(existing: a))),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      final repo = await ref.read(appointmentRepositoryProvider.future);

                      if (!context.mounted) return;

                      if (v == 'delete') {
                        final confirmed = await confirmDelete(context);

                        if (!context.mounted || !confirmed) return;

                        await repo.remove(a.id);
                      } else {
                        await repo.setStatus(a.id, v);
                      }

                      if (!context.mounted) return;

                      await _after(context, ref);
                    },
                    itemBuilder: (_) => [
                      if (a.status != 'completed') PopupMenuItem(value: 'completed', child: Text(t.markCompleted)),
                      if (a.status != 'cancelled') PopupMenuItem(value: 'cancelled', child: Text(t.cancelAppointment)),
                      if (a.status != 'upcoming') PopupMenuItem(value: 'upcoming', child: Text(t.reopenAppointment)),
                      PopupMenuItem(value: 'delete', child: Text(t.delete)),
                    ],
                  ),
                ),
              );
            },
          );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.appointments),
          bottom: TabBar(tabs: [Tab(text: t.upcoming), Tab(text: t.tabHistory)]),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: t.addAppointment,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentFormScreen())),
          child: const Icon(Icons.add),
        ),
        body: appts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(t.loadError),
              TextButton(onPressed: () => ref.invalidate(appointmentsProvider), child: Text(t.retry)),
            ]),
          ),
          data: (all) {
            final up = all.where((a) => a.isUpcoming).toList();
            final past = all.where((a) => !a.isUpcoming).toList().reversed.toList();
            return TabBarView(children: [list(up, upcoming: true), list(past, upcoming: false)]);
          },
        ),
      ),
    );
  }
}
