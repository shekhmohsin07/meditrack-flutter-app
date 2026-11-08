import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import '../data/family_repository.dart';
import '../domain/family_member.dart';

final familyRepositoryProvider = FutureProvider<FamilyRepository>(
    (ref) async => FamilyRepository((await ref.watch(databaseProvider.future)).db));

final familyMembersProvider = FutureProvider.autoDispose<List<FamilyMember>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  return (await ref.watch(familyRepositoryProvider.future)).list(s.id);
});
