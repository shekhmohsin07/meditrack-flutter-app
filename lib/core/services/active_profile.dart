import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whose data is on screen: null = the account owner ("Me"), otherwise a family member's id.
final activeMemberProvider = StateProvider<String?>((ref) => null);
