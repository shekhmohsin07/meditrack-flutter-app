import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/appointments/presentation/appointments_screen.dart';
import 'package:meditrack/features/family/presentation/family_screen.dart';
import 'package:meditrack/features/health_records/presentation/allergies_screen.dart';
import 'package:meditrack/features/health_records/presentation/emergency_contacts_screen.dart';
import 'package:meditrack/features/health_records/presentation/health_records_screen.dart';
import 'package:meditrack/features/health_records/presentation/prescriptions_screen.dart';
import 'package:meditrack/features/settings/presentation/settings_screen.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'auth_providers.dart';
import 'profile_image.dart';

/// Profile tab: who is signed in + shortcuts to personal health information.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final s = ref.watch(sessionProvider);
    void open(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

    Widget tile(IconData icon, String label, Widget page) => Card(
          child: ListTile(leading: Icon(icon, color: AppColors.primaryBlue), title: Text(label),
              trailing: const Icon(Icons.chevron_right), onTap: () => open(page)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(t.navProfile, style: Theme.of(context).textTheme.headlineMedium)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    final src = await chooseImageSource(context);
                    if (src == null) return;
                    try {
                      await ref.read(profileImageProvider.notifier).change(src);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imageErrorText(t, e))));
                      }
                    }
                  },
                  child: Tooltip(message: t.changePhoto, child: const UserAvatar(radius: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s?.name ?? '', style: Theme.of(context).textTheme.titleMedium),
                    Text(s == null || s.offline ? t.offlineAccount : s.email, style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          tile(Icons.family_restroom, t.familyMembers, const FamilyScreen()),
          tile(Icons.monitor_heart_outlined, t.healthRecords, const HealthRecordsScreen()),
          tile(Icons.event_note_outlined, t.appointments, const AppointmentsScreen()),
          tile(Icons.description_outlined, t.prescriptions, const PrescriptionsScreen()),
          tile(Icons.warning_amber_rounded, t.allergies, const AllergiesScreen()),
          tile(Icons.phone_in_talk_outlined, t.emergencyContacts, const EmergencyContactsScreen()),
          tile(Icons.settings_outlined, t.settings, const SettingsScreen()),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(t.logout),
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
