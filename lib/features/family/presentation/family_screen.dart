import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/app/shell_provider.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart' show refreshReminders;
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/shared/widgets/confirm_dialog.dart';
import '../domain/family_member.dart';
import 'family_providers.dart';

extension FamilyLabels on AppLocalizations {
  String relationshipLabel(String key) => switch (key) {
        'spouse' => relSpouse,
        'parent' => relParent,
        'child' => relChild,
        'sibling' => relSibling,
        'grandparent' => relGrandparent,
        'friend' => relFriend,
        _ => relOther,
      };
}

/// Family members: each has separate medicines, schedules and intake history.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, FamilyMember? existing) async {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final name = TextEditingController(text: existing?.name);
    final form = GlobalKey<FormState>();
    var rel = existing?.relationship ?? 'other';
    DateTime? birth = existing?.birthDate;
    var consent = existing?.caregiverConsent ?? false;
    DateTime? consentAt = existing?.consentAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(existing == null ? t.addFamilyMember : t.editFamilyMember),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: name, decoration: InputDecoration(labelText: t.fullName),
                    validator: (v) => tr(t, Validators.required(v))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: rel,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: t.relationship),
                  items: [for (final r in FamilyMember.relationships) DropdownMenuItem(value: r, child: Text(t.relationshipLabel(r)))],
                  onChanged: (v) => setState(() => rel = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.birthDateOptional),
                  subtitle: Text(birth == null ? '-' : DateFormat.yMMMd(locale).format(birth!)),
                  trailing: const Icon(Icons.event),
                  onTap: () async {
                    final d = await showDatePicker(
                        context: c, initialDate: birth ?? DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
                    if (d != null) setState(() => birth = d);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.caregiverConsent),
                  subtitle: Text(t.caregiverConsentHint),
                  value: consent,
                  onChanged: (v) async {
                    if (!v) {
                      setState(() { consent = false; consentAt = null; });
                      return;
                    }
                    // Turning consent ON needs an explicit confirmation.
                    final agreed = await showDialog<bool>(
                      context: c,
                      builder: (d) => AlertDialog(
                        title: Text(t.consentTitle),
                        content: Text(t.consentBody),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
                          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(t.iConfirm)),
                        ],
                      ),
                    );
                    if (agreed == true) setState(() { consent = true; consentAt = DateTime.now(); });
                  },
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
            TextButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, true); }, child: Text(t.save)),
          ],
        ),
      ),
    );
    final member = FamilyMember(
        id: existing?.id ?? '', name: name.text, relationship: rel, birthDate: birth,
        caregiverConsent: consent, consentAt: consentAt);
    name.dispose();
    if (ok != true) return;
    final session = ref.read(sessionProvider)!;
    final repo = await ref.read(familyRepositoryProvider.future);
    existing == null ? await repo.add(session.id, member) : await repo.edit(session.id, member);
    ref.invalidate(familyMembersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final members = ref.watch(familyMembersProvider);
    final active = ref.watch(activeMemberProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.familyMembers)),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addFamilyMember,
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: members.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.loadError)),
        data: (list) => list.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.noFamilyMembers, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)))
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final m = list[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.cardPadding),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const CircleAvatar(backgroundColor: AppColors.lightBlue,
                              child: Icon(Icons.family_restroom, color: AppColors.primaryBlue)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                              Text(t.relationshipLabel(m.relationship), style: Theme.of(context).textTheme.bodySmall),
                            ]),
                          ),
                          if (m.caregiverConsent)
                            Chip(
                              label: Text(t.consentGiven, style: const TextStyle(color: AppColors.success, fontSize: 12)),
                              backgroundColor: AppColors.lightGreen,
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ),
                        ]),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          FilledButton.tonal(
                            onPressed: active == m.id ? null : () {
                              ref.read(activeMemberProvider.notifier).state = m.id;
                              ref.read(shellIndexProvider.notifier).state = 0;
                              Navigator.pop(context);
                            },
                            child: Text(active == m.id ? t.viewingNow : t.viewProfile),
                          ),
                          OutlinedButton(onPressed: () => _edit(context, ref, m), child: Text(t.editFamilyMember)),
                          TextButton(
                            onPressed: () async {
                              if (!await confirmDelete(context, message: t.deleteMemberConfirm)) return;
                              await (await ref.read(familyRepositoryProvider.future)).remove(m.id);
                              if (ref.read(activeMemberProvider) == m.id) ref.read(activeMemberProvider.notifier).state = null;
                              ref.invalidate(familyMembersProvider);
                              if (context.mounted) await refreshReminders(context, ref);
                            },
                            child: Text(t.delete, style: const TextStyle(color: AppColors.danger)),
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
