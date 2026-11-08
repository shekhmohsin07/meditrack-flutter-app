import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'family_providers.dart';

/// Chips to switch between "Me" and family members. Hidden when there are no members.
class ProfileSelector extends ConsumerWidget {
  const ProfileSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final members = ref.watch(familyMembersProvider).valueOrNull ?? const [];
    if (members.isEmpty) return const SizedBox.shrink();
    final active = ref.watch(activeMemberProvider);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: 8),
        children: [
          ChoiceChip(
            avatar: const Icon(Icons.person, size: 18),
            label: Text(t.me),
            selected: active == null,
            onSelected: (_) => ref.read(activeMemberProvider.notifier).state = null,
          ),
          for (final m in members) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: const Icon(Icons.family_restroom, size: 18),
              label: Text(m.name),
              selected: active == m.id,
              onSelected: (_) => ref.read(activeMemberProvider.notifier).state = m.id,
            ),
          ],
        ],
      ),
    );
  }
}
