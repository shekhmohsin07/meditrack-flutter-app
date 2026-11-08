# Android setup for reminders (do this once)

1. After `flutter create . --org com.meditrack --platforms android`, run:
   `dart run tool/patch_android.dart`
   It adds the notification / boot / exact-alarm permissions and the receivers (without them **no reminder ever appears**
   and the app is not listed under "Alarms & reminders"), and it also makes the Gradle edits below (minSdk 23,
   desugaring, no code shrinking in release builds). It prints a report and keeps `.bak` copies. The manual steps 2 and 3 are
   only needed if the script reports a `!` line.

2. **Minimum Android version.** Firebase needs Android 6.0 (API 23) or newer. In
   `android/app/build.gradle.kts` (or `build.gradle`) find the `minSdk` / `minSdkVersion` line inside
   `defaultConfig` and set it to 23:
   `minSdk = 23` (Kotlin) or `minSdkVersion 23` (Groovy).

3. `flutter_local_notifications` needs "core library desugaring". Open
   `android/app/build.gradle.kts` (newer Flutter) or `android/app/build.gradle` (older) and add:

   **Kotlin (`build.gradle.kts`)**
   ```kotlin
   android {
       compileOptions {
           isCoreLibraryDesugaringEnabled = true
       }
   }
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
   }
   ```
   **Groovy (`build.gradle`)**
   ```groovy
   android {
       compileOptions { coreLibraryDesugaringEnabled true }
   }
   dependencies {
       coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
   }
   ```
   (Keep the other lines already in those blocks; only add the lines above.
   The desugar version is from memory - if Gradle complains, use the version the
   flutter_local_notifications README currently shows.)

4. On the phone: Android 13+ asks for notification permission at first launch.
   Android 12+ also needs "Alarms & reminders" allowed for exact times
   (Schedule tab -> bell icon -> "Allow exact alarms"). Some phone brands
   (Xiaomi, Oppo, Vivo, Huawei...) also kill background apps: set MediTrack's
   battery mode to "No restrictions".

## How reminders work
- Each dose gets a fixed notification id (hash of medicine + dose time), so rescheduling never duplicates.
- Reminders are scheduled 7 days ahead and refreshed every time the app opens or a schedule changes.
  If the app is not opened for more than 7 days, reminders stop (known limitation).
- Taken / Snooze (10 min) / Skip buttons write to the database even when the app is closed.
- Doses with no response after 60 minutes are marked "missed" the next time the app opens.
