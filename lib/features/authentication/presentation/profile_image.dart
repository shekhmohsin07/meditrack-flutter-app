import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditrack/core/services/image_service.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/core/services/storage_service.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'auth_providers.dart';

/// Local path of the current user's profile photo (kept per account in SharedPreferences).
class ProfileImageNotifier extends Notifier<String?> {
  String get _key => 'profile_image_${ref.read(sessionProvider)?.id ?? 'none'}';

  @override
  String? build() {
    ref.watch(sessionProvider);
    final path = ref.read(sharedPrefsProvider).getString(_key);
    return path != null && File(path).existsSync() ? path : null;
  }

  /// Picks a photo, stores it, and uploads a copy to Firebase Storage when signed in (best effort).
  Future<void> change(ImageSource source) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    final images = ImageService();
    final path = await images.pickAndStore(source);
    if (path == null) return;
    final old = state;
    await ref.read(sharedPrefsProvider).setString(_key, path);
    state = path;
    await images.deleteFile(old);
    final storage = StorageService();
    if (!session.offline && storage.available) {
      try {
        await storage.upload(session.id, path, 'profile${path.substring(path.lastIndexOf('.'))}');
      } catch (_) {/* stays local; not critical */}
    }
  }
}

final profileImageProvider = NotifierProvider<ProfileImageNotifier, String?>(ProfileImageNotifier.new);

/// Circle avatar: profile photo if set, otherwise the first letter of the name.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, this.radius = 24});
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(sessionProvider)?.name ?? '';
    final path = ref.watch(profileImageProvider);
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightBlue,
      backgroundImage: path == null ? null : FileImage(File(path)),
      child: path != null
          ? null
          : Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: radius * 0.8)),
    );
  }
}

/// "Camera / Gallery" bottom sheet; returns the chosen source or null.
Future<ImageSource?> chooseImageSource(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: Text(t.takePhoto), onTap: () => Navigator.pop(c, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: Text(t.chooseFromGallery), onTap: () => Navigator.pop(c, ImageSource.gallery)),
      ]),
    ),
  );
}

/// Shows a friendly message for [ImageException].
String imageErrorText(AppLocalizations t, Object e) =>
    e is ImageException ? (e.code == 'tooLarge' ? t.imageTooLarge : t.imageUnsupported) : t.loadError;
