import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/app/router.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart';
import 'package:meditrack/features/authentication/presentation/onboarding_screen.dart';
import 'package:meditrack/features/authentication/presentation/splash_screen.dart';
import 'package:meditrack/l10n/app_localizations.dart';

/// Decides what to show: splash -> onboarding (first run) -> login -> main app.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(databaseProvider).when(
          loading: () => const SplashScreen(),
          error: (e, _) => Scaffold(
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(AppLocalizations.of(context)!.loadError),
                TextButton(onPressed: () => ref.invalidate(databaseProvider), child: Text(AppLocalizations.of(context)!.retry)),
              ]),
            ),
          ),
          data: (_) {
            if (!ref.watch(onboardingDoneProvider)) return const OnboardingScreen();
            return ref.watch(sessionProvider) == null ? const LoginScreen() : const MainShell();
          },
        );
  }
}
