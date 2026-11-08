import 'package:cloud_firestore/cloud_firestore.dart';

/// The cloud side of synchronisation. The engine only talks to this interface,
/// so it can be tested with an in-memory fake.
abstract class RemoteStore {
  Future<Map<String, Object?>?> get(String collection, String id);
  Future<void> set(String collection, String id, Map<String, Object?> data);

  /// Documents whose updated_at >= [since] (oldest first). [since] == null means everything.
  Future<List<Map<String, Object?>>> changedSince(String collection, String? since, {int limit = 500});
}

/// Firestore layout: users/{uid}/{collection}/{docId}
class FirestoreRemoteStore implements RemoteStore {
  FirestoreRemoteStore(this.uid, [FirebaseFirestore? firestore]) : _fs = firestore ?? FirebaseFirestore.instance;
  final String uid;
  final FirebaseFirestore _fs;
  static const _timeout = Duration(seconds: 20);

  CollectionReference<Map<String, dynamic>> _col(String c) => _fs.collection('users').doc(uid).collection(c);

  @override
  Future<Map<String, Object?>?> get(String collection, String id) async {
    final snap = await _col(collection).doc(id).get(const GetOptions(source: Source.server)).timeout(_timeout);
    return snap.exists ? Map<String, Object?>.from(snap.data()!) : null;
  }

  @override
  Future<void> set(String collection, String id, Map<String, Object?> data) =>
      _col(collection).doc(id).set(data).timeout(_timeout);

  @override
  Future<List<Map<String, Object?>>> changedSince(String collection, String? since, {int limit = 500}) async {
    Query<Map<String, dynamic>> q = _col(collection).orderBy('updated_at');
    if (since != null) q = q.where('updated_at', isGreaterThanOrEqualTo: since);
    final snap = await q.limit(limit).get(const GetOptions(source: Source.server)).timeout(_timeout);
    return [for (final d in snap.docs) Map<String, Object?>.from(d.data())];
  }
}
