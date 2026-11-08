# Troubleshooting

## 1. Login / Register / Reset-password buttons do nothing
**Cause:** the cloud account needs Firebase, and this build has no Firebase configuration
(`flutterfire configure` was not run, or it failed). Older versions disabled the buttons silently.

**Now:** tapping the button shows "Cloud account is not set up" with the technical reason and a **Continue offline** button.
You can use the whole app offline.

**To get real accounts:** follow `docs/FIREBASE_SETUP.md` (Steps 11-17 of INSTALLATION.md):
`flutterfire configure`, enable Email/Password, create Firestore, rebuild the APK.
After `flutterfire configure`, open `lib/firebase_options.dart`: it must contain `static const FirebaseOptions android`.

## 2. No notification / alarm at the medicine time, and MediTrack is missing from "Alarms & reminders"
**Cause:** the Android project is missing the permissions and receivers that reminders need. The phone only lists an app under
*Settings > Apps > Special access > Alarms & reminders* if the manifest contains `SCHEDULE_EXACT_ALARM`.

**Fix (on your computer, in the project folder):**
```
dart run tool/patch_android.dart
flutter clean
flutter pub get
flutter build apk --release
```
The script prints a report of what it added (manifest permissions, receivers, `minSdk 23`, desugaring, release shrinking off).
Then **uninstall** the old app from the phone, install the new APK, open MediTrack, allow notifications.

**Check it works:** open the **bell icon** (Home or Schedule tab). The *Reminder status* card shows:
* Notifications: on / off - if off, tap **Enable notifications** (or Phone Settings > Apps > MediTrack > Notifications).
* Exact alarms: allowed / not allowed - tap **Allow exact alarms** and switch it on if the phone asks.
* N reminders scheduled - should be at least 1 when you have an active schedule with a time in the next 7 days.
* A red **Problem while scheduling reminders** message - send me this text.

Use **Send test notification** (instant) and **Test reminder in 1 minute** (lock the screen and wait) to test.

**Other reasons reminders can be late or missing**
* Battery saver: Settings > Apps > MediTrack > Battery > **Unrestricted** (Samsung: also remove MediTrack from "Sleeping apps").
* Do Not Disturb / silent mode: the reminder uses the alarm volume, but DND can still block it.
* Date/time of the phone is wrong.
* The schedule is paused, the medicine is "completed", or the schedule start/end dates exclude today.
* After you edit a schedule or add a medicine the reminders are rebuilt automatically; tap **Refresh reminders** to force it.
