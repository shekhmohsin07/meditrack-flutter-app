/// Tables that are synchronised to Firestore (collection name = table name).
/// Listed parents-first. `users`, `notifications`, `sync_queue` and `app_settings` stay on the device.
const syncTables = <String>[
  'family_members', 'medicines', 'schedules', 'schedule_times', 'medicine_logs', 'inventory',
  'stock_history', 'health_records', 'doctors', 'appointments', 'allergies', 'emergency_contacts', 'prescriptions',
];

/// SQL that returns the owning user_id of one row (`?` = row id). Used so that a queue entry
/// created by account A is never uploaded into account B's cloud space on a shared phone.
const ownerSql = <String, String>{
  'family_members': 'SELECT user_id FROM family_members WHERE id = ?',
  'medicines': 'SELECT user_id FROM medicines WHERE id = ?',
  'health_records': 'SELECT user_id FROM health_records WHERE id = ?',
  'doctors': 'SELECT user_id FROM doctors WHERE id = ?',
  'appointments': 'SELECT user_id FROM appointments WHERE id = ?',
  'allergies': 'SELECT user_id FROM allergies WHERE id = ?',
  'emergency_contacts': 'SELECT user_id FROM emergency_contacts WHERE id = ?',
  'prescriptions': 'SELECT user_id FROM prescriptions WHERE id = ?',
  'schedules': 'SELECT m.user_id FROM schedules s JOIN medicines m ON m.id = s.medicine_id WHERE s.id = ?',
  'schedule_times':
      'SELECT m.user_id FROM schedule_times t JOIN schedules s ON s.id = t.schedule_id JOIN medicines m ON m.id = s.medicine_id WHERE t.id = ?',
  'medicine_logs': 'SELECT m.user_id FROM medicine_logs l JOIN medicines m ON m.id = l.medicine_id WHERE l.id = ?',
  'inventory': 'SELECT m.user_id FROM inventory i JOIN medicines m ON m.id = i.medicine_id WHERE i.id = ?',
  'stock_history':
      'SELECT m.user_id FROM stock_history h JOIN inventory i ON i.id = h.inventory_id JOIN medicines m ON m.id = i.medicine_id WHERE h.id = ?',
};

/// Tables that carry their own user_id column (remote documents are checked against it).
const tablesWithUserId = <String>{
  'family_members', 'medicines', 'health_records', 'doctors', 'appointments', 'allergies', 'emergency_contacts', 'prescriptions',
};

enum Winner { local, remote }

/// Conflict rules (same result on every device, so devices converge):
/// 1. Intake logs: a dose the user decided (taken / skipped) beats an automatic "missed".
/// 2. Otherwise the newest updated_at wins (last-write-wins).
/// 3. Exact tie: the larger id wins.
/// Deletions are rows with deleted_at set (tombstones), so they follow the same rules.
class SyncConflict {
  SyncConflict._();

  static Winner resolve(String table, Map<String, Object?> local, Map<String, Object?> remote) {
    if (table == 'medicine_logs') {
      bool decided(Object? s) => s == 'taken' || s == 'skipped';
      if (local['status'] == 'missed' && decided(remote['status'])) return Winner.remote;
      if (remote['status'] == 'missed' && decided(local['status'])) return Winner.local;
    }
    final c = (local['updated_at'] as String).compareTo(remote['updated_at'] as String);
    if (c != 0) return c > 0 ? Winner.local : Winner.remote;
    return (local['id'] as String).compareTo(remote['id'] as String) >= 0 ? Winner.local : Winner.remote;
  }
}

/// Row <-> Firestore document.
class SyncMapper {
  SyncMapper._();
  static Map<String, Object?> toDoc(Map<String, Object?> row) => {
        for (final e in row.entries)
          if (e.key != 'sync_status') e.key: e.value,
      };
}
