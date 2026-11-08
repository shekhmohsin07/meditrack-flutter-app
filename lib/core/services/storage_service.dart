import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'image_service.dart';

/// Uploads images to Firebase Storage under users/{uid}/... (see firebase/storage.rules).
class StorageService {
  bool get available => Firebase.apps.isNotEmpty;

  /// Returns the download URL.
  Future<String> upload(String uid, String localPath, String remoteName) async {
    final ref = FirebaseStorage.instance.ref('users/$uid/$remoteName');
    await ref
        .putFile(File(localPath), SettableMetadata(contentType: ImageService.mimeFor(localPath)))
        .timeout(const Duration(seconds: 60));
    return ref.getDownloadURL();
  }
}
