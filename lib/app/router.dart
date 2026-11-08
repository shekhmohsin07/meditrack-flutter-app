import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/app/shell_provider.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/core/sync/sync_controller.dart';
import 'package:meditrack/features/authentication/presentation/profile_screen.dart';
import 'package:meditrack/features/dashboard/presentation/dashboard_screen.dart';
import 'package:meditrack/features/medicines/presentation/medicine_list_screen.dart';
import 'package:meditrack/features/reports/presentation/reports_screen.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:meditrack/features/schedules/presentation/schedule_screen.dart';
import 'package:meditrack/l10n/app_localizations.dart';

/// Main screen with the Material 3 bottom navigation bar.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    ref.read(syncControllerProvider); // starts cloud sync (does nothing for offline-only sessions)
    // After the first frame: ask for notification permission, then refresh reminders.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationService.instance.requestNotificationPermission();
      } catch (_) {}
      if (mounted) await refreshReminders(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final index = ref.watch(shellIndexProvider);
    const pages = <Widget>[
      DashboardScreen(),
      MedicineListScreen(),
      ScheduleScreen(),
      ReportsScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(shellIndexProvider.notifier).state = i,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: t.navHome),
          NavigationDestination(icon: const Icon(Icons.medication_outlined), selectedIcon: const Icon(Icons.medication), label: t.navMedicines),
          NavigationDestination(icon: const Icon(Icons.schedule_outlined), selectedIcon: const Icon(Icons.schedule), label: t.navSchedule),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: t.navReports),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: t.navProfile),
        ],
      ),
    );
  }
}
