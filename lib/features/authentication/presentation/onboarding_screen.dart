import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/l10n/app_localizations.dart';

/// First-run introduction (3 pages). Shown once.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _State();
}

class _State extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final pages = [
      (Icons.alarm_on_outlined, t.onboardTitle1, t.onboardBody1),
      (Icons.insights_outlined, t.onboardTitle2, t.onboardBody2),
      (Icons.health_and_safety_outlined, t.onboardTitle3, '${t.onboardBody3}\n\n${t.healthDisclaimer}'),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => ref.read(onboardingDoneProvider.notifier).complete(), child: Text(t.skip)),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                for (final (icon, title, body) in pages)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(height: 40),
                      CircleAvatar(radius: 56, backgroundColor: AppColors.lightBlue, child: Icon(icon, size: 56, color: AppColors.primaryBlue)),
                      const SizedBox(height: 32),
                      Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: i == _page ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primaryBlue : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: FilledButton(
              onPressed: () {
                if (last) {
                  ref.read(onboardingDoneProvider.notifier).complete();
                } else {
                  _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                }
              },
              child: Text(last ? t.getStarted : t.next),
            ),
          ),
        ]),
      ),
    );
  }
}
