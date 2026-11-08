import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment.dart';

final appointmentRepositoryProvider = FutureProvider<AppointmentRepository>(
    (ref) async => AppointmentRepository((await ref.watch(databaseProvider.future)).db));

final appointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final s = ref.watch(sessionProvider);
  if (s == null) return [];
  await ref.watch(localUserProvider(s).future);
  return (await ref.watch(appointmentRepositoryProvider.future)).list(s.id);
});
