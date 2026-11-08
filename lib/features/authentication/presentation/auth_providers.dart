import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import '../data/auth_service.dart';
import '../domain/session.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

Session _fromUser(User u) => Session(
    id: u.uid, email: u.email ?? '', name: (u.displayName?.isNotEmpty ?? false) ? u.displayName! : (u.email ?? 'User'));

/// Holds the current session. Firebase restores it automatically on app start (session persistence).
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final svc = ref.read(authServiceProvider);
    final sub = svc.changes.listen((u) => state = u == null ? (state?.offline == true ? state : null) : _fromUser(u));
    ref.onDispose(sub.cancel);
    final u = svc.currentUser;
    return u == null ? null : _fromUser(u);
  }

  void useOffline() =>
      state = const Session(id: 'local-user', email: '', name: 'Local user', offline: true);

  Future<void> logout() async {
    if (state?.offline != true) await ref.read(authServiceProvider).logout();
    ref.read(activeMemberProvider.notifier).state = null;
    state = null;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

/// Makes sure a row for this user exists in SQLite (needed by foreign keys).
final localUserProvider = FutureProvider.family<void, Session>((ref, s) async {
  final db = (await ref.watch(databaseProvider.future)).db;
  final exists = await db.query('users', where: 'id = ?', whereArgs: [s.id], limit: 1);
  if (exists.isEmpty) {
    await BaseRepository(db, 'users').insert({'id': s.id, 'email': s.email, 'display_name': s.name});
  }
});
