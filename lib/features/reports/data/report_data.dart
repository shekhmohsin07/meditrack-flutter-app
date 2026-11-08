import 'package:meditrack/core/database/base_repository.dart';
import 'package:meditrack/features/health_records/data/health_repository.dart';
import 'package:meditrack/features/health_records/domain/health_record.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/data/medicine_repository.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:sqflite/sqflite.dart';

class ReportOptions {
  const ReportOptions({this.medicines = true, this.history = true, this.health = true, this.personal = true});
  final bool medicines;
  final bool history;
  final bool health;
  final bool personal; // allergies + emergency contacts
}

/// Everything the PDF needs, loaded from SQLite for one user and date range.
class ReportData {
  const ReportData({
    required this.userName,
    required this.from,
    required this.to,
    required this.generatedAt,
    required this.medicines,
    required this.history,
    required this.health,
    required this.allergies,
    required this.contacts,
  });
  final String userName;
  final DateTime from;
  final DateTime to; // inclusive last day
  final DateTime generatedAt;
  final List<Medicine> medicines;
  final List<HistoryEntry> history; // oldest first
  final List<HealthRecord> health; // oldest first
  final List<Map<String, Object?>> allergies;
  final List<Map<String, Object?>> contacts;

  static Future<ReportData> load(
    Database db, {
    required String userId,
    required String userName,
    String? memberId,
    required DateTime from,
    required DateTime to,
    ReportOptions options = const ReportOptions(),
  }) async {
    final end = DateTime(to.year, to.month, to.day + 1); // make the range inclusive of the last day
    final start = DateTime(from.year, from.month, from.day);
    return ReportData(
      userName: userName,
      from: start,
      to: to,
      generatedAt: DateTime.now(),
      medicines: options.medicines ? await MedicineRepository(db).list(userId, memberId: memberId) : const [],
      history: options.history
          ? (await IntakeRepository(db).historyBetween(userId, start, end, memberId: memberId)).reversed.toList()
          : const [],
      health: options.health ? (await HealthRepository(db).list(userId, memberId: memberId, from: start, to: end)).reversed.toList() : const [],
      allergies: options.personal
          ? await BaseRepository(db, 'allergies').getAll(
              where: memberId == null ? 'user_id = ? AND member_id IS NULL' : 'user_id = ? AND member_id = ?',
              args: [userId, if (memberId != null) memberId],
              orderBy: 'name COLLATE NOCASE')
          : const [],
      contacts: options.personal
          ? await BaseRepository(db, 'emergency_contacts').getAll(where: 'user_id = ?', args: [userId], orderBy: 'name COLLATE NOCASE')
          : const [],
    );
  }
}
