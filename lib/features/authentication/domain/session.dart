/// The signed-in user (or the offline local user).
class Session {
  const Session({required this.id, required this.email, required this.name, this.offline = false});
  final String id;
  final String email;
  final String name;
  final bool offline;
}
