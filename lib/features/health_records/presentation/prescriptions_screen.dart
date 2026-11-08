import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/services/image_service.dart';
import 'package:meditrack/core/services/storage_service.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/profile_image.dart' show chooseImageSource, imageErrorText;
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/shared/widgets/confirm_dialog.dart';

final _rxRepoProvider = FutureProvider<BaseRepository>(
    (ref) async => BaseRepository((await ref.watch(databaseProvider.future)).db, 'prescriptions'));

final prescriptionsProvider = FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final member = ref.watch(activeMemberProvider);
  return (await ref.watch(_rxRepoProvider.future)).getAll(
    where: member == null ? 'user_id = ? AND member_id IS NULL' : 'user_id = ? AND member_id = ?',
    args: [s.id, if (member != null) member],
    orderBy: 'created_at DESC',
  );
});

/// Prescription photos: stored on the phone, uploaded to Firebase Storage when signed in and online.
class PrescriptionsScreen extends ConsumerStatefulWidget {
  const PrescriptionsScreen({super.key});
  @override
  ConsumerState<PrescriptionsScreen> createState() => _State();
}

class _State extends ConsumerState<PrescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _uploadPending());
  }

  /// Uploads any photo that has no remote_url yet (best effort, silent on failure).
  Future<void> _uploadPending() async {
    final s = ref.read(sessionProvider);
    final storage = StorageService();
    if (s == null || s.offline || !storage.available) return;
    try {
      final repo = await ref.read(_rxRepoProvider.future);
      for (final r in await repo.getAll(where: 'user_id = ? AND remote_url IS NULL', args: [s.id])) {
        final path = r['image_path'] as String;
        if (!File(path).existsSync()) continue;
        final url = await storage.upload(s.id, path, 'prescriptions/${r['id']}${path.substring(path.lastIndexOf('.'))}');
        await repo.update(r['id'] as String, {'remote_url': url});
      }
      ref.invalidate(prescriptionsProvider);
    } catch (_) {/* will retry next time the screen opens */}
  }

  Future<void> _add() async {
    final t = AppLocalizations.of(context)!;
    final src = await chooseImageSource(context);
    if (src == null) return;
    try {
      final path = await ImageService().pickAndStore(src);
      if (path == null || !mounted) return;
      final note = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(t.addPrescription),
          content: TextField(controller: note, decoration: InputDecoration(labelText: t.notesOptional)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
            TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.save)),
          ],
        ),
      );
      final text = note.text.trim();
      note.dispose();
      if (ok != true) {
        await ImageService().deleteFile(path);
        return;
      }
      final repo = await ref.read(_rxRepoProvider.future);
      await repo.insert({
        'user_id': ref.read(sessionProvider)!.id,
        'member_id': ref.read(activeMemberProvider),
        'image_path': path,
        'note': text.isEmpty ? null : text,
        'issued_at': DateTime.now().toIso8601String().substring(0, 10),
      });
      ref.invalidate(prescriptionsProvider);
      await _uploadPending();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imageErrorText(t, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final items = ref.watch(prescriptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.prescriptions)),
      floatingActionButton: FloatingActionButton(tooltip: t.addPrescription, onPressed: _add, child: const Icon(Icons.add_a_photo_outlined)),
      body: Column(children: [
        const ProfileSelector(),
        Expanded(
          child: items.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(t.loadError)),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noPrescriptions, style: Theme.of(context).textTheme.bodySmall))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = list[i];
                      final path = r['image_path'] as String;
                      final exists = File(path).existsSync();
                      final uploaded = r['remote_url'] != null;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppDimensions.cardPadding),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56, height: 56,
                              child: exists ? Image.file(File(path), fit: BoxFit.cover) : const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                          title: Text((r['note'] as String?) ?? t.prescriptions),
                          subtitle: Text([
                            if (r['issued_at'] != null) DateFormat.yMMMd(locale).format(DateTime.parse(r['issued_at'] as String)),
                            uploaded ? t.uploadedToCloud : t.notUploaded,
                          ].join(' • ')),
                          onTap: exists
                              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => _FullImage(path: path)))
                              : null,
                          trailing: IconButton(
                            tooltip: t.delete,
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: () async {
                              if (!await confirmDelete(context)) return;
                              await (await ref.read(_rxRepoProvider.future)).softDelete(r['id'] as String);
                              await ImageService().deleteFile(path);
                              ref.invalidate(prescriptionsProvider);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}

class _FullImage extends StatelessWidget {
  const _FullImage({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
      );
}
