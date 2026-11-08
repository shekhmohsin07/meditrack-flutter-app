import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/settings/presentation/sync_card.dart';
import 'package:meditrack/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final lang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(t.darkMode),
                  value: isDark,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setDark(v),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(t.language),
                  trailing: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'en', label: Text(t.english)),
                      ButtonSegment(value: 'bn', label: Text(t.bangla)),
                    ],
                    selected: {lang},
                    onSelectionChanged: (s) =>
                        ref.read(localeProvider.notifier).setLanguage(s.first),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Alarm permissions
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Alarm Permissions'),
              subtitle: const Text(
                'Enable notifications, exact alarms and full-screen alarms.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                try {
                  await NotificationService.instance.requestAlarmPermissions();

                  if (!context.mounted) return;

                  final exact =
                      await NotificationService.instance.canScheduleExact();
                  final notifications =
                      await NotificationService.instance.notificationsEnabled();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notifications: ${notifications ? "Enabled" : "Disabled"} | '
                        'Exact alarms: ${exact ? "Enabled" : "Disabled"}',
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permission error: $e'),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          const SyncCard(),

          const SizedBox(height: 16),

          Text(
            t.healthDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
