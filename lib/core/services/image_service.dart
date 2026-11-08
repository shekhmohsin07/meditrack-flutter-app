import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageException implements Exception {
  const ImageException(this.code); // 'tooLarge' | 'unsupported'
  final String code;
}

/// Picks a photo and copies it into the app's private storage (so the path stays valid).
/// Safe-upload rules: only jpg / png / webp, at most 5 MB, resized to 1600 px.
class ImageService {
  static const maxBytes = 5 * 1024 * 1024;
  static const _allowed = {'.jpg', '.jpeg', '.png', '.webp'};
  final ImagePicker _picker = ImagePicker();

  /// Returns the stored file path, or null if the user cancelled.
  Future<String?> pickAndStore(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 75);
    if (picked == null) return null;
    final ext = p.extension(picked.path).toLowerCase();
    if (!_allowed.contains(ext)) throw const ImageException('unsupported');
    if (await picked.length() > maxBytes) throw const ImageException('tooLarge');
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'images'));
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '${const Uuid().v4()}$ext');
    await File(picked.path).copy(dest);
    return dest;
  }

  Future<void> deleteFile(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static String mimeFor(String path) => switch (p.extension(path).toLowerCase()) {
        '.png' => 'image/png',
        '.webp' => 'image/webp',
        _ => 'image/jpeg',
      };
}
