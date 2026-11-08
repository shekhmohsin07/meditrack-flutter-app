class Appointment {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.at,
    this.hospital,
    this.notes,
    this.reminderMinutes = 60,
    this.status = 'upcoming', // upcoming | completed | cancelled
  });
  final String id; // '' when new
  final String doctorName;
  final String? hospital;
  final DateTime at; // local
  final String? notes;
  final int reminderMinutes;
  final String status;

  DateTime get remindAt => at.subtract(Duration(minutes: reminderMinutes));
  bool get isUpcoming => status == 'upcoming' && at.isAfter(DateTime.now());

  factory Appointment.fromMap(Map<String, Object?> m) => Appointment(
        id: m['id'] as String,
        doctorName: (m['doctor_name'] as String?) ?? '',
        hospital: m['hospital'] as String?,
        at: DateTime.parse(m['appointment_at'] as String).toLocal(),
        notes: m['notes'] as String?,
        reminderMinutes: (m['reminder_minutes'] as num?)?.toInt() ?? 60,
        status: m['status'] as String,
      );
}
