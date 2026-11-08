import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected bottom-navigation tab (0 Home, 1 Medicines, 2 Schedule, 3 Reports, 4 Profile).
final shellIndexProvider = StateProvider<int>((ref) => 0);
