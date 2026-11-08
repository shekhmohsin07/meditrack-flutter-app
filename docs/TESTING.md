# MediTrack – Testing

> **Status honesty:** no test in this project has been executed by the author of the code (the build environment had no
> Flutter SDK). Everything below is *written and ready to run*. Do not report results until you have run them.

## How to run
```
flutter test                                              # unit + widget tests (about 61 cases in test/)
flutter test integration_test/offline_flow_test.dart      # real app on emulator/phone, no Firebase
flutter test integration_test/firebase_flow_test.dart --dart-define=FIREBASE_TEST=true --dart-define=TEST_EMAIL=... --dart-define=TEST_PASSWORD=...
flutter analyze
```
Before the integration test: `adb shell pm grant com.meditrack.meditrack android.permission.POST_NOTIFICATIONS`.

## What is covered
| Area | File(s) | Cases |
|---|---|---|
| Database: queue, soft delete, unique dose | `database_test.dart` | 3 |
| Medicine repository (add/search/filter/edit/delete) | `medicine_repository_test.dart` | 1 |
| Scheduling logic | `schedule_logic_test.dart` | 4 |
| Intake log, notification ids | `intake_repository_test.dart` | 4 |
| Inventory deduction, reversal, floor, reconcile, status | `inventory_test.dart` | 6 |
| Adherence, date ranges | `adherence_test.dart` | 5 |
| Validation | `validators_test.dart`, `health_and_dashboard_test.dart` | 3 + 3 |
| Health + appointment repositories, dashboard counts | `health_and_dashboard_test.dart` | 3 |
| Family profiles and consent | `family_test.dart` | 3 |
| Sync engine and conflict rules (fake cloud) | `sync_test.dart` | 13 |
| Widgets: login, dashboard, medicine list, add form | `login_screen_test.dart`, `dashboard_test.dart`, `medicine_screens_test.dart` | 3 + 2 + 4 |
| Widgets: navigation | `widget_test.dart` | 1 |
| Widgets: theme + language switching, palette | `theme_test.dart` | 3 |
| Integration: medicine CRUD, schedule, intake, stock, health record | `integration_test/offline_flow_test.dart` | 1 |
| Integration: registration, login, cloud sync | `integration_test/firebase_flow_test.dart` | 1 (needs Firebase) |

## Manual test cases (fill the last column yourself)
| ID | Test | Expected | Result |
|---|---|---|---|
| TC-01 | Register with valid e-mail/password | Home opens | |
| TC-02 | Login with wrong password | Error message, stays on login | |
| TC-03 | Add medicine without name | "This field is required" | |
| TC-04 | Add medicine with end date before start | "End date cannot be before start date" | |
| TC-05 | Schedule 2 minutes ahead | Notification with 3 buttons | |
| TC-06 | Tap Taken twice (notification then app) | One log, stock −1 only | |
| TC-07 | Tap Snooze | New notification after 10 minutes | |
| TC-08 | Ignore a dose for 60+ minutes, reopen app | Status Missed | |
| TC-09 | Stock at/below threshold | "Low stock" chip + dashboard alert | |
| TC-10 | Expiry in < 30 days / past | "Expiring soon" / "Expired" | |
| TC-11 | Family member without consent, miss a dose | No caregiver alert | |
| TC-12 | Family member with consent, miss a dose | One alert on the owner's phone | |
| TC-13 | Airplane mode: add data, reconnect | Data uploads, no duplicates | |
| TC-14 | Same account on two phones, edit same medicine | Newer edit wins on both | |
| TC-15 | Dark mode / Bangla | Whole app switches, text readable | |
| TC-16 | PDF report with Bangla language, online | Bangla text renders | |
| TC-17 | Restart phone | Reminders still fire | |
| TC-18 | Firestore rules playground, other uid | Denied | |
