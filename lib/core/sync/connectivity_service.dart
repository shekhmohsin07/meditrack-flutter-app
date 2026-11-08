import 'package:connectivity_plus/connectivity_plus.dart';

/// "Online" = the phone has some network. (It cannot prove the internet works;
/// failed uploads are retried by the sync engine.)
class ConnectivityService {
  final Connectivity _c = Connectivity();
  static bool _has(List<ConnectivityResult> r) => r.any((e) => e != ConnectivityResult.none);

  Future<bool> get isOnline async => _has(await _c.checkConnectivity());
  Stream<bool> get onlineChanges => _c.onConnectivityChanged.map(_has);
}
