import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import '../data/health_repository.dart';
import '../domain/health_record.dart';

final healthRepositoryProvider = FutureProvider<HealthRepository>(
    (ref) async => HealthRepository((await ref.watch(databaseProvider.future)).db));

final healthTypeFilterProvider = StateProvider<HealthType>((ref) => HealthType.bloodPressure);
final healthRangeProvider = StateProvider<DateTimeRange?>((ref) => null); // null = all time

final healthRecordsProvider = FutureProvider.autoDispose<List<HealthRecord>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  final range = ref.watch(healthRangeProvider);
  return (await ref.watch(healthRepositoryProvider.future)).list(
    s.id,
    memberId: ref.watch(activeMemberProvider),
    type: ref.watch(healthTypeFilterProvider),
    from: range?.start,
    to: range == null ? null : DateTime(range.end.year, range.end.month, range.end.day + 1),
  );
});
