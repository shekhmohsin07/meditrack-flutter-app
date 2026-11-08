import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/features/appointments/presentation/appointment_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/family/presentation/family_providers.dart';
import 'package:meditrack/features/health_records/presentation/health_providers.dart';
import 'package:meditrack/features/inventory/presentation/inventory_providers.dart';
import 'package:meditrack/features/medicines/presentation/medicine_providers.dart';
import 'package:meditrack/features/reports/presentation/report_providers.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'connectivity_service.dart';
import 'remote_store.dart';
import 'sync_engine.dart';

enum SyncPhase { disabled, idle, syncing, offline, error }

class SyncState {
  const SyncState({this.phase = SyncPhase.disabled, this.waiting = 0, this.failed = 0, this.lastSyncAt, this.lastError});
  final SyncPhase phase;
  final int waiting; // changes not yet uploaded
  final int failed; // changes that failed too often and are parked
  final DateTime? lastSyncAt;
  final String? lastError;

  SyncState copyWith({SyncPhase? phase, int? waiting, int? failed, DateTime? lastSyncAt, String? lastError, bool clearError = false}) =>
      SyncState(
        phase: phase ?? this.phase,
        waiting: waiting ?? this.waiting,
        failed: failed ?? this.failed,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

/// Runs the sync engine: when the app opens, when the network comes back,
/// every minute if something is waiting, and every 5 minutes to download changes.
/// Disabled for offline-only sessions and when Firebase is not configured.
class SyncController extends Notifier<SyncState> {
  final _connectivity = ConnectivityService();
  Timer? _timer;
  StreamSubscription<bool>? _sub;
  bool _running = false;
  int _ticks = 0;

  @override
  SyncState build() {
    final session = ref.watch(sessionProvider);
    final auth = ref.read(authServiceProvider);
    ref.onDispose(() {
      _timer?.cancel();
      _sub?.cancel();
    });
    if (session == null || session.offline || !auth.available) return const SyncState(phase: SyncPhase.disabled);
    Future.microtask(() => _start(session.id));
    return const SyncState(phase: SyncPhase.idle);
  }

  void _start(String uid) {
    _sub = _connectivity.onlineChanges.listen((online) {
      if (online) {
        syncNow();
      } else {
        state = state.copyWith(phase: SyncPhase.offline);
      }
    });
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _ticks++;
      if (_ticks % 5 == 0 || state.waiting > 0) syncNow();
    });
    syncNow();
  }

  Future<SyncEngine?> _engine() async {
    final session = ref.read(sessionProvider);
    if (session == null || session.offline) return null;
    final db = (await ref.read(databaseProvider.future)).db;
    return SyncEngine(db: db, remote: FirestoreRemoteStore(session.id), userId: session.id);
  }

  Future<void> syncNow() async {
    if (_running) return;
    final engine = await _engine();
    if (engine == null) return;
    if (!await _connectivity.isOnline) {
      state = state.copyWith(phase: SyncPhase.offline);
      return;
    }
    _running = true;
    state = state.copyWith(phase: SyncPhase.syncing, clearError: true);
    try {
      final report = await engine.run();
      final (waiting, failed) = await engine.counts();
      state = SyncState(
        phase: report.error == null ? SyncPhase.idle : SyncPhase.error,
        waiting: waiting,
        failed: failed,
        lastSyncAt: report.error == null ? DateTime.now() : state.lastSyncAt,
        lastError: report.error,
      );
      if (report.downloaded > 0 || report.remoteWon > 0) _refreshScreens();
    } catch (e) {
      state = state.copyWith(phase: SyncPhase.error, lastError: e.toString());
    } finally {
      _running = false;
    }
  }

  Future<void> retryFailed() async {
    final engine = await _engine();
    if (engine == null) return;
    await engine.retryFailed();
    await syncNow();
  }

  void _refreshScreens() {
    for (final p in <ProviderOrFamily>[
      medicinesProvider, scheduleEntriesProvider, dayDosesProvider, todayDosesProvider, stockRowsProvider,
      healthRecordsProvider, appointmentsProvider, familyMembersProvider, periodHistoryProvider,
      monthHistoryProvider, weekHistoryProvider,
    ]) {
      ref.invalidate(p);
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);
