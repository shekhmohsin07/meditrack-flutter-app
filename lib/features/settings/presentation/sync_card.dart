import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/sync/sync_controller.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/l10n/app_localizations.dart';

/// Cloud sync status with "Sync now" and "Retry failed".
class SyncCard extends ConsumerWidget {
  const SyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final s = ref.watch(syncControllerProvider);
    final (icon, color, text) = switch (s.phase) {
      SyncPhase.disabled => (Icons.cloud_off_outlined, AppColors.textSecondary, t.syncDisabled),
      SyncPhase.idle => (Icons.cloud_done_outlined, AppColors.success, s.waiting == 0 ? t.syncUpToDate : t.syncWaiting(s.waiting.toString())),
      SyncPhase.syncing => (Icons.cloud_sync_outlined, AppColors.primaryBlue, t.syncing),
      SyncPhase.offline => (Icons.wifi_off, AppColors.warning, t.syncOffline),
      SyncPhase.error => (Icons.error_outline, AppColors.danger, t.syncError),
    };
    final enabled = s.phase != SyncPhase.disabled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.cloudSync, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ]),
          if (s.lastSyncAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${t.lastSynced}: ${DateFormat.yMMMd(locale).add_jm().format(s.lastSyncAt!)}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          if (s.failed > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(t.syncFailedChanges(s.failed.toString()), style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ),
          if (s.phase == SyncPhase.error && s.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(s.lastError!, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            FilledButton.tonal(
              onPressed: enabled && s.phase != SyncPhase.syncing ? () => ref.read(syncControllerProvider.notifier).syncNow() : null,
              child: Text(t.syncNow),
            ),
            if (s.failed > 0)
              OutlinedButton(onPressed: () => ref.read(syncControllerProvider.notifier).retryFailed(), child: Text(t.retryFailed)),
          ]),
        ]),
      ),
    );
  }
}
