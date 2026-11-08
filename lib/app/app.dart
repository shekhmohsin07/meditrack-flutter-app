import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/app/app_root.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/l10n/app_localizations.dart';

class MediTrackApp extends ConsumerWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final bangla = locale.languageCode == 'bn';
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c)!.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(bangla: bangla),
      darkTheme: AppTheme.dark(bangla: bangla),
      themeMode: ref.watch(themeModeProvider),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppRoot(),
    );
  }
}
