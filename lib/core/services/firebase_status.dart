/// Remembers why Firebase could not start (shown in the "cloud account is not set up" dialog).
class FirebaseStatus {
  FirebaseStatus._();
  static String? initError;
}
