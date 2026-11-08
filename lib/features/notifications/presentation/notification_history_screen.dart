import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:meditrack/l10n/app_localizations.dart';

final _historyProvider = FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  final db = (await ref.watch(databaseProvider.future)).db;
  return db.query('notifications',
      where: "user_id = ? AND deleted_at IS NULL AND status != 'cancelled' AND scheduled_at <= ?",
      whereArgs: [s.id, DateTime.now().toUtc().toIso8601String()],
      orderBy: 'scheduled_at DESC',
      limit: 200);
});

typedef _Status = ({bool enabled, bool exact, int pending});

/// What Android says about this app's notifications right now.
final _statusProvider = FutureProvider.autoDispose<_Status>((ref) async {
  final svc = NotificationService.instance;
  return (enabled: await svc.notificationsEnabled(), exact: await svc.canScheduleExact(), pending: await svc.pendingCount());
});

/// Notification status + test buttons + history.
/// If reminders do not appear, this screen shows why (permission, exact alarms, or an error).
class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() job, {String? okMessage}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await job();
      if (okMessage != null) messenger.showSnackBar(SnackBar(content: Text(okMessage)));
    } catch (e) {
      NotificationService.lastError = e.toString();
      messenger.showSnackBar(SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 8)));
    }
    ref.invalidate(_statusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final history = ref.watch(_historyProvider);
    final status = ref.watch(_statusProvider).valueOrNull;
    final error = ref.watch(reminderErrorProvider) ?? NotificationService.lastError;
    final labels = {'taken': t.actionTaken, 'snooze': t.actionSnooze, 'skip': t.actionSkip};

    Widget line(IconData icon, Color color, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: Text(t.notificationHistory)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.reminderStatus, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (status != null) ...[
                  line(status.enabled ? Icons.notifications_active : Icons.notifications_off,
                      status.enabled ? AppColors.success : AppColors.danger, status.enabled ? t.notificationsOn : t.notificationsOff),
                  line(status.exact ? Icons.alarm_on : Icons.alarm_off, status.exact ? AppColors.success : AppColors.warning,
                      status.exact ? t.exactAlarmsOn : t.exactAlarmsOff),
                  line(Icons.schedule, AppColors.primaryBlue, t.remindersScheduled(status.pending.toString())),
                ],
                if (error != null) line(Icons.error_outline, AppColors.danger, '${t.reminderProblem}\n$error'),
                const SizedBox(height: 8),
                Text(t.batteryHint, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton(
                    onPressed: () => _run(context, ref, () => NotificationService.instance.requestNotificationPermission()),
                    child: Text(t.enableNotifications),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(context, ref, () => NotificationService.instance.requestExactAlarmPermission()),
                    child: Text(t.allowExactAlarms),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(context, ref, () async {
                      await refreshReminders(context, ref);
                    }),
                    child: Text(t.refreshReminders),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _run(context, ref, () => NotificationService.instance.showTestNow(t.testNotificationTitle, t.testNotificationBody)),
                    child: Text(t.sendTestNow),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _run(
                      context,
                      ref,
                      () => NotificationService.instance.scheduleTest(const Duration(minutes: 1), t.testNotificationTitle, t.testNotificationBody, labels),
                      okMessage: t.testScheduledMsg,
                    ),
                    child: Text(t.testInOneMinute),
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(t.loadError)),
            data: (rows) => rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(t.noNotifications, style: Theme.of(context).textTheme.bodySmall)),
                  )
                : Column(children: [
                    for (final r in rows)
                      ListTile(
                        title: Text(r['title'] as String),
                        subtitle: Text('${r['body']}\n${DateFormat.yMMMd(locale).add_jm().format(DateTime.parse(r['scheduled_at'] as String).toLocal())}'),
                        isThreeLine: true,
                      ),
                  ]),
          ),
        ],
      ),
    );
  }
}
