import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/shared/widgets/confirm_dialog.dart';

final _allergyRepoProvider = FutureProvider<BaseRepository>(
    (ref) async => BaseRepository((await ref.watch(databaseProvider.future)).db, 'allergies'));

final allergiesProvider = FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final member = ref.watch(activeMemberProvider);
  return (await ref.watch(_allergyRepoProvider.future))
      .getAll(
          where: member == null ? 'user_id = ? AND member_id IS NULL' : 'user_id = ? AND member_id = ?',
          args: [s.id, if (member != null) member],
          orderBy: 'name COLLATE NOCASE');
});

/// Allergy records (name + optional reaction note).
class AllergiesScreen extends ConsumerWidget {
  const AllergiesScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, Map<String, Object?>? row) async {
    final t = AppLocalizations.of(context)!;
    final name = TextEditingController(text: row?['name'] as String?);
    final reaction = TextEditingController(text: row?['reaction'] as String?);
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(row == null ? t.addAllergy : t.editAllergy),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, decoration: InputDecoration(labelText: t.allergyName),
                validator: (v) => tr(t, Validators.required(v))),
            const SizedBox(height: 12),
            TextFormField(controller: reaction, decoration: InputDecoration(labelText: t.reactionOptional)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
          TextButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, true); }, child: Text(t.save)),
        ],
      ),
    );
    final values = {'name': name.text.trim(), 'reaction': reaction.text.trim().isEmpty ? null : reaction.text.trim()};
    name.dispose();
    reaction.dispose();
    if (ok != true) return;
    final repo = await ref.read(_allergyRepoProvider.future);
    if (row == null) {
      await repo.insert({...values, 'user_id': ref.read(sessionProvider)!.id, 'member_id': ref.read(activeMemberProvider)});
    } else {
      await repo.update(row['id'] as String, values);
    }
    ref.invalidate(allergiesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final items = ref.watch(allergiesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.allergies)),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addAllergy,
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.loadError)),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noAllergies, style: Theme.of(context).textTheme.bodySmall))
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = list[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      title: Text(r['name'] as String),
                      subtitle: (r['reaction'] as String?) == null ? null : Text(r['reaction'] as String),
                      onTap: () => _edit(context, ref, r),
                      trailing: IconButton(
                        tooltip: t.delete,
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () async {
                          if (!await confirmDelete(context)) return;
                          await (await ref.read(_allergyRepoProvider.future)).softDelete(r['id'] as String);
                          ref.invalidate(allergiesProvider);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
