# MediTrack – Database documentation

MediTrack keeps all data in a local **SQLite** database (`meditrack.db`, via the `sqflite` package), so the app works
without internet. Changes are queued and copied to **Cloud Firestore** by the sync engine (see ARCHITECTURE.md).

Source files: `lib/core/database/schema.dart` (SQL), `migration_manager.dart`, `app_database.dart`, `base_repository.dart`.

## Conventions used by every synced table
| Column | Purpose |
|---|---|
| `id` TEXT PRIMARY KEY | UUID v4, created on the phone (no server needed) |
| `created_at`, `updated_at` | UTC ISO-8601 text with exactly 3 fractional digits, e.g. `2026-03-02T08:00:00.000Z` (sorts correctly as text) |
| `deleted_at` | NULL = active. Not NULL = soft-deleted (a *tombstone*, so deletions can sync) |
| `sync_status` | `pending` (changed on this phone) or `synced` |

`PRAGMA foreign_keys = ON` is set when the database opens. All repositories read with `deleted_at IS NULL`.

## Tables (17)
The 16 required tables plus `stock_history` (needed for "stock history").

| # | Table | Purpose | Key constraints |
|---|---|---|---|
| 1 | `users` | Local copy of the signed-in user (needed for foreign keys) | email, display_name NOT NULL |
| 2 | `family_members` | People managed by the account owner | FK user_id; `caregiver_consent` CHECK IN (0,1); `consent_at` |
| 3 | `medicines` | Medicines | FK user_id, FK member_id (NULL = owner); CHECK on `type`, `food_instruction`, `status`; name not blank |
| 4 | `schedules` | Repeat rule for a medicine | FK medicine_id; CHECK frequency IN (daily, weekly, custom); `days_of_week` "1,2,…7" (1 = Monday) |
| 5 | `schedule_times` | One row per reminder time | FK schedule_id; CHECK `time_of_day` GLOB 'HH:MM' |
| 6 | `medicine_logs` | What happened to each dose | FK medicine_id; **UNIQUE(medicine_id, scheduled_at)** = one log per dose; CHECK status IN (pending, taken, missed, skipped, snoozed) |
| 7 | `inventory` | Stock of a medicine | **UNIQUE(medicine_id)**; CHECK quantities >= 0 |
| 8 | `stock_history` *(extra)* | Every stock change | **UNIQUE(log_id)** = a dose can only deduct stock once; reason IN (initial, intake, manual, refill) |
| 9 | `health_records` | BP, glucose, weight, notes, history | CHECK type; value1/value2 (BP uses both) |
| 10 | `notifications` | Notification history / duplicate guard | **UNIQUE(notification_int_id)** |
| 11 | `doctors` | Doctors | FK user_id |
| 12 | `appointments` | Doctor appointments | FK user_id, doctor_id (SET NULL); status IN (upcoming, completed, cancelled) |
| 13 | `allergies` | Allergy records | FK user_id, member_id |
| 14 | `emergency_contacts` | Emergency contacts | phone NOT NULL |
| 15 | `prescriptions` | Prescription photo records | `image_path` (on phone), `remote_url` (Storage) |
| 16 | `sync_queue` | Pending uploads | **UNIQUE(entity_table, entity_id)** = one entry per row; `attempts`, `last_error` |
| 17 | `app_settings` | Key/value (sync checkpoints, last sync time) | key PRIMARY KEY |

### Indexes
`idx_medicines_user`, `idx_medicines_member`, `idx_schedules_medicine`, `idx_times_schedule`, `idx_logs_scheduled`,
`idx_logs_medicine`, `idx_health_user_type`, `idx_appt_date`, `idx_queue_created`.

### Relationships
See `docs/diagrams/er_diagram.mmd` (also in PROJECT_REPORT.md). In short: a user owns medicines; a medicine has
schedules, which have times; each dose creates at most one `medicine_logs` row; a medicine has at most one `inventory`
row, whose changes are in `stock_history`.

## Transactions
Operations that touch several rows run inside one SQLite transaction:
* saving a schedule + its times (`ScheduleRepository.save`),
* saving an appointment + creating the doctor (`AppointmentRepository.save`),
* creating stock + its first history row, adjusting stock, deducting stock for a taken dose,
* removing a family member + hiding their medicines.

## Duplicate protection
* **Intake**: UNIQUE(medicine_id, scheduled_at). `IntakeRepository.record` updates the existing row instead of inserting.
  An automatic "missed" never overrides taken/skipped.
* **Stock**: UNIQUE(stock_history.log_id). `deductForLog` checks first and runs in a transaction.
* **Notifications**: the Android notification id is a hash of (medicine, dose time), so rescheduling replaces, never duplicates.
* **Sync**: one `sync_queue` row per entity, so ten edits of one medicine upload once.

## Migrations
`Schema.version` is 1. To change the schema: raise `Schema.version`, add `ALTER TABLE …` statements to
`MigrationManager._migrations[<new version>]`, and update `createStatements` for fresh installs.
Upgrades run inside a transaction.

## Firestore mapping
`users/{uid}/{table}/{id}` for 13 tables: family_members, medicines, schedules, schedule_times, medicine_logs, inventory,
stock_history, health_records, doctors, appointments, allergies, emergency_contacts, prescriptions.
Documents contain the same columns as the SQLite row except `sync_status`. `users`, `notifications`, `sync_queue` and
`app_settings` stay on the phone.
