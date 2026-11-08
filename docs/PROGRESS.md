# MediTrack – Build Progress

## Batch 1 (this ZIP) – Phases 1–2
- [x] Project setup: pubspec, analysis options, .gitignore, folder structure
- [x] Theme system (exact palette, light + dark, Inter / Noto Sans Bengali)
- [x] Localization: English + Bangla ARB (starter keys only)
- [x] Shell app: bottom navigation, Settings (dark mode + language, persisted)
- [x] SQLite schema (16 required tables + stock_history), migrations, base repository with sync queue
- [x] Firestore security rules
- [x] Database unit tests (written, NOT yet executed – no Flutter SDK in build environment)

## Batch 2 – Phases 3–4 (partial)
- [x] Authentication: register, login, forgot password, logout, session persistence (Firebase), offline-only mode
- [x] Medicine CRUD with search, filter (all/active/completed), sort, validation, delete confirmation
- [x] English + Bangla strings for the above; unit tests for validators and medicine repository (NOT executed)
- [ ] Not done in auth: profile screen + profile image upload, splash, onboarding
- [ ] Not done in medicines: medicine image, details screen

## Batch 3 – Phases 4–5 (partial)
- [x] Schedules: daily / weekly / custom days, multiple times, start/end dates, pause/resume, edit, delete (transactional)
- [x] Schedule tab: weekly calendar + per-day dose list with Taken / Skip
- [x] Notifications: permission requests, exact-alarm handling, deterministic ids (no duplicates),
      Taken / Snooze / Skip actions, missed-dose marking, notification history, reboot receiver (via tool/patch_android.dart)
- [x] Intake log repository (one log per dose, never downgrades a user decision)
- [x] Tests written (not executed): schedule logic, intake repository, notification ids
- [ ] NOT done: stock deduction on "Taken" (Batch 4), appointment reminders, caregiver missed-dose alerts
- [ ] Known limits: reminders refresh only when app opens (7-day window); needs manual Android setup, see docs/ANDROID_SETUP.md

## Batch 4 – Phase 6 (partial)
- [x] Inventory: set up / edit stock, remaining + low-stock threshold, units per dose, expiry date,
      manual adjust / refill, stock history, status chips (OK / Low / Out / Expiring soon / Expired)
- [x] Automatic stock deduction when a dose is marked Taken (UI or notification button); one deduction per dose
      (UNIQUE log_id), stock returned if Taken is changed, startup safety-net reconcile
- [x] Reports tab: History (day/week/month, filter by medicine and date), Statistics (adherence %, pie + bar charts, fl_chart),
      Calendar (month view with coloured dots)
- [x] Missed-dose marking now looks back 14 days and never before a schedule was last changed
- [x] Tests written (not executed): adherence maths, date ranges, inventory deduction / reversal / floor / reconcile / status
- [ ] NOT done: refill and expiry NOTIFICATIONS (stock alerts are visible in the Stock screen only; dashboard card comes in Batch 5)
- [ ] NOT done: PDF export of history (Batch 5)

## Batch 5 – Phases 7–8 (partial)
- [x] Home dashboard: header, today summary (4 cards), next medicine (Taken / Snooze), timeline, stock alerts, weekly adherence chart, quick actions
- [x] Health records: blood pressure, glucose, weight, notes, medical history; type + date filters; trend chart (fl_chart);
      validation only catches typing mistakes (no "high/low/normal" labels - MediTrack never interprets values)
- [x] Doctor appointments: add / edit / delete, upcoming + history, mark completed / cancelled, reminders (15 min - 1 day before)
- [x] Allergies and emergency contacts (add / edit / delete)
- [x] Profile tab hub (health records, appointments, allergies, contacts, settings, logout)
- [x] PDF report: date range + section choice, adherence summary, medicines, intake history, health records, allergies, contacts;
      preview/print and share (printing package)
- [x] Tests written (not executed): health validation, dashboard summary, health + appointment repositories
- [ ] NOT done: family management (separate profiles, caregiver consent, missed-dose alerts to caregivers) and the dashboard family selector
- [ ] NOT done: profile image upload, splash screen, onboarding, medicine image / prescription image upload, medicine details screen
- [ ] NOT done: refill / expiry notifications
- [ ] PDF limitation: fonts are downloaded on first use (needs internet); offline Bangla PDFs may lack glyphs

## Batch 6 – Phases 7 & 9 (partial)
- [x] Family management: add / edit / remove members, separate medicines, schedules, intake history, health records,
      allergies and prescriptions per profile; "Me / member" selector; explicit consent dialog for caregiver access
- [x] Authorised missed-dose alerts: a local notification on THIS phone, only for members who gave consent, sent once per dose
- [x] Cloud sync (Firestore): upload queue (one entry per row), download by checkpoint, conflict rules, retry with attempt counter,
      tombstones for deletions, per-account isolation on a shared phone, sync status card in Settings
- [x] Images: medicine photo, prescription photos (Firebase Storage upload when online), profile photo; jpg/png/webp, max 5 MB
- [x] Medicine details screen, splash screen, onboarding
- [x] Security: Firestore rules (owner-only, no hard deletes), Storage rules (owner-only, images < 5 MB), firebase.json
- [x] Tests written (not executed): sync engine (fake cloud), conflict rules, family profiles
- [ ] NOT done: caregiver alerts on ANOTHER person's phone (needs a server / Cloud Functions + push messaging)
- [ ] NOT done: deleting images from Firebase Storage when a record is deleted; syncing the profile photo to other devices
- [ ] Known limits: conflict resolution trusts device clocks; stock quantities are last-write-wins (two phones deducting
      at the same time can disagree); data created in "offline account" mode is not moved into a later cloud account;
      reminders are re-created when the app opens, so changes downloaded from another phone are scheduled at the next app open

## Batch 7 – Phase 10–11 (final)
- [x] Widget tests: login, dashboard, medicine list, add medicine form, navigation, theme + language switching, palette
- [x] Integration test scripts: offline flow (no Firebase) and Firebase flow (registration/login/sync, needs a test project)
- [x] Documentation: INSTALLATION (21 steps), FIREBASE_SETUP, DATABASE, ARCHITECTURE, PROJECT_REPORT (24 sections), TESTING, Mermaid diagrams
- [x] Final ZIP

## Fix batch (after first device test)
- [x] Login / Register / Reset buttons were disabled when Firebase was not configured -> now always active; they explain the problem and offer "Continue offline"
- [x] No reminders / app missing from "Alarms & reminders": tool/patch_android.dart rewritten (manifest permissions incl. SCHEDULE_EXACT_ALARM + USE_EXACT_ALARM,
      the 3 notification receivers, minSdk 23, desugaring, no R8 shrinking in release) with a printed report
- [x] Notification status screen: shows permission, exact-alarm state, number of scheduled reminders, last scheduling error; test buttons
- [x] Reminder channel rings at alarm volume (new channel id)
- [x] docs/TROUBLESHOOTING.md

## Remaining (needs your computer)
- Run `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, fix any errors (none of this could be run by the author)
- Run `flutterfire configure`, enable Auth/Firestore, deploy rules
- Android Gradle edits (minSdk 23, desugaring) - docs/ANDROID_SETUP.md
- Fill the results in PROJECT_REPORT.md §20 and the cover page
