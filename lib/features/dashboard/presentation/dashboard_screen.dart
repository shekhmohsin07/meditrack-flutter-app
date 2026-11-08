import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/app/shell_provider.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/appointments/presentation/appointment_form_screen.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/profile_image.dart';
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/features/health_records/presentation/health_form_screen.dart';
import 'package:meditrack/features/inventory/domain/inventory.dart';
import 'package:meditrack/features/inventory/presentation/inventory_labels.dart';
import 'package:meditrack/features/inventory/presentation/inventory_providers.dart';
import 'package:meditrack/features/inventory/presentation/inventory_screen.dart';
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/presentation/medicine_form_screen.dart';
import 'package:meditrack/features/medicines/presentation/medicine_labels.dart';
import 'package:meditrack/features/notifications/presentation/notification_history_screen.dart';
import 'package:meditrack/features/reports/presentation/report_providers.dart';
import 'package:meditrack/features/reports/presentation/statistics_tab.dart' show DailyAdherenceBars;
import 'package:meditrack/features/schedules/presentation/schedule_labels.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/day_summary.dart';

/// Home tab. Sections: header, today's summary, next medicine, timeline,
/// low-stock alerts, weekly adherence, quick actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final session = ref.watch(sessionProvider);
    final today = ref.watch(todayDosesProvider);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? t.greetingMorning : (hour < 17 ? t.greetingAfternoon : t.greetingEvening);
    final h2 = Theme.of(context).textTheme.titleLarge;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayDosesProvider);
            ref.invalidate(stockRowsProvider);
            ref.invalidate(weekHistoryProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            children: [
              // A. Header
              Row(children: [
                const UserAvatar(radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting, style: Theme.of(context).textTheme.bodySmall),
                    Text(session?.name ?? '', style: Theme.of(context).textTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                    Text(DateFormat.yMMMMEEEEd(locale).format(now), style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
                IconButton(
                  tooltip: t.notificationHistory,
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationHistoryScreen())),
                ),
              ]),
              const SizedBox(height: 8),
              const ProfileSelector(),
              const SizedBox(height: 12),

              today.when(
                loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Column(children: [
                  Text(t.loadError),
                  TextButton(onPressed: () => ref.invalidate(todayDosesProvider), child: Text(t.retry)),
                ]),
                data: (doses) {
                  final summary = DaySummary.from([for (final d in doses) (at: d.dose.at, status: d.status)], now);
                  DoseStatus? next;
                  for (final d in doses) {
                    final open = d.status == null || d.status == IntakeStatus.snoozed || d.status == IntakeStatus.pending;
                    if (open && d.dose.at.isAfter(now.subtract(const Duration(minutes: 60)))) {
                      next = d;
                      break;
                    }
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // B. Summary
                    Text(t.todaySummary, style: h2),
                    const SizedBox(height: 12),
                    Row(children: [
                      _SummaryCard(t.totalScheduled, summary.total, Icons.medication_outlined, AppColors.primaryBlue, AppColors.lightBlue),
                      const SizedBox(width: 12),
                      _SummaryCard(t.statusTaken, summary.taken, Icons.check_circle_outline, AppColors.success, AppColors.lightGreen),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      _SummaryCard(t.statusMissed, summary.missed, Icons.cancel_outlined, AppColors.danger, AppColors.lightRed),
                      const SizedBox(width: 12),
                      _SummaryCard(t.statusUpcoming, summary.upcoming, Icons.schedule, AppColors.warning, AppColors.lightOrange),
                    ]),
                    const SizedBox(height: 24),

                    // C. Next medicine
                    Text(t.nextMedicine, style: h2),
                    const SizedBox(height: 12),
                    if (next == null)
                      Card(child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.cardPadding),
                        child: Row(children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(child: Text(doses.isEmpty ? t.noDosesToday : t.allDoneToday)),
                        ]),
                      ))
                    else
                      _NextDoseCard(entry: next, locale: locale),
                    const SizedBox(height: 24),

                    // D. Timeline
                    Text(t.todaySchedule, style: h2),
                    const SizedBox(height: 12),
                    if (doses.isEmpty)
                      Text(t.noDosesToday, style: Theme.of(context).textTheme.bodySmall)
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.cardPadding),
                          child: Column(children: [
                            for (var i = 0; i < doses.length; i++)
                              _TimelineRow(entry: doses[i], locale: locale, last: i == doses.length - 1),
                          ]),
                        ),
                      ),
                  ]);
                },
              ),
              const SizedBox(height: 24),

              // E. Low stock
              Consumer(builder: (context, ref, _) {
                final alerts = ref.watch(stockAlertsProvider).valueOrNull ?? const <StockRow>[];
                if (alerts.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.stockAlerts, style: h2),
                  const SizedBox(height: 12),
                  for (final r in alerts.take(3))
                    Card(
                      child: ListTile(
                        title: Text(r.medicine.name),
                        subtitle: Text('${t.unitsLeft(formatQty(r.item!.remaining))} • ${t.stockLabel(r.item!.statusOn(now))}'),
                        trailing: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                          child: Text(t.refill),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ]);
              }),

              // F. Weekly adherence
              Text(t.weeklyAdherence, style: h2),
              const SizedBox(height: 12),
              Consumer(builder: (context, ref, _) {
                final week = ref.watch(weekHistoryProvider);
                return week.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text(t.loadError),
                  data: (entries) {
                    final stats = AdherenceStats.from(entries.map((e) => e.status));
                    final daily = AdherenceStats.daily(entries, DateRange.of(ReportPeriod.week, now));
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.cardPadding),
                        child: stats.resolved == 0
                            ? Text(t.noHistory, style: Theme.of(context).textTheme.bodySmall)
                            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${stats.percent!.round()}%', style: Theme.of(context).textTheme.headlineLarge),
                                const SizedBox(height: 12),
                                SizedBox(height: 180, child: DailyAdherenceBars(daily: daily, color: AppColors.primaryBlue)),
                              ]),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 24),

              // G. Quick actions
              Text(t.quickActions, style: h2),
              const SizedBox(height: 12),
              Row(children: [
                _QuickAction(Icons.add_circle_outline, t.addMedicine,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineFormScreen()))),
                const SizedBox(width: 12),
                _QuickAction(Icons.monitor_heart_outlined, t.addHealthRecord,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthFormScreen()))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _QuickAction(Icons.event_available_outlined, t.addAppointment,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentFormScreen()))),
                const SizedBox(width: 12),
                _QuickAction(Icons.bar_chart_outlined, t.viewReports, () => ref.read(shellIndexProvider.notifier).state = 3),
              ]),
              const SizedBox(height: 24),
              Text(t.healthDisclaimer, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.label, this.value, this.icon, this.fg, this.bg);
  final String label;
  final int value;
  final IconData icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          label: '$label: $value',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(children: [
                CircleAvatar(backgroundColor: bg, child: Icon(icon, color: fg)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$value', style: Theme.of(context).textTheme.headlineMedium),
                    Text(label, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _NextDoseCard extends ConsumerWidget {
  const _NextDoseCard({required this.entry, required this.locale});
  final DoseStatus entry;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final m = entry.dose.medicine;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.medication, color: AppColors.primaryBlue)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${m.dosage} • ${t.foodLabel(m.food)}', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            Text(DateFormat.jm(locale).format(entry.dose.at), style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: () => markDose(context, ref, entry.dose, IntakeStatus.taken), child: Text(t.statusTaken))),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
                onPressed: () => snoozeDose(context, ref, entry.dose),
                child: Text(t.actionSnooze),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.locale, required this.last});
  final DoseStatus entry;
  final String locale;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (fg, bg) = doseStatusColors(entry.status, entry.dose.at);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 64, child: Text(DateFormat.jm(locale).format(entry.dose.at), style: Theme.of(context).textTheme.labelLarge)),
        Column(children: [
          Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 3), decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          if (!last) Expanded(child: Container(width: 2, color: Theme.of(context).dividerColor)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.dose.medicine.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(entry.dose.medicine.dosage, style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              Chip(
                label: Text(t.doseStatusLabel(entry.status, entry.dose.at), style: TextStyle(color: fg, fontSize: 12)),
                backgroundColor: bg,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Column(children: [
                Icon(icon, color: AppColors.primaryBlue, size: 28),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
              ]),
            ),
          ),
        ),
      );
}
