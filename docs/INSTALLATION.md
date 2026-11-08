# MediTrack – Installation guide (Windows 10/11, beginner)

Follow the steps **in order**. "Terminal" means the VS Code terminal (Ctrl + `) unless stated.
Times are estimates; downloads are large (about 5–6 GB in total).

---
## STEP 1 – Install Flutter SDK
* **Where:** your web browser.
* Install **Git for Windows** first: https://git-scm.com/download/win (keep all default options).
* Download the Flutter SDK for Windows (zip) from https://docs.flutter.dev/get-started/install/windows
* Extract the zip to **`C:\src\`** so you get `C:\src\flutter\bin\flutter.bat`.
  Do **not** use `C:\Program Files` or a folder with spaces or that needs admin rights.
* **Expected:** the folder `C:\src\flutter` exists and contains `bin`, `packages`, …
* **Common error:** "Path too long" while extracting → extract with 7-Zip, or move the zip to `C:\` first.

## STEP 2 – Add Flutter to PATH
1. Press the Windows key, type **"environment variables"**, open **Edit environment variables for your account**.
2. Select **Path** → **Edit** → **New** → type `C:\src\flutter\bin` → **OK** → **OK**.
3. **Close and reopen** any terminal, then run (Command Prompt or PowerShell):
```
flutter --version
```
* **Expected:** `Flutter 3.x.x • channel stable …` (first run downloads Dart; wait).
* **Error:** "'flutter' is not recognized" → the PATH entry is wrong or the terminal was not reopened.

## STEP 3 – Install Visual Studio Code
Download from https://code.visualstudio.com → run installer → tick **"Add to PATH"** and **"Open with Code"**.

## STEP 4 – Install the Flutter and Dart extensions
VS Code → Extensions icon (Ctrl+Shift+X) → search **Flutter** (publisher: Dart Code) → **Install**.
The Dart extension installs automatically with it. **Expected:** after a restart, `Ctrl+Shift+P` → typing "Flutter" shows Flutter commands.

## STEP 5 – Install Android Studio
Download from https://developer.android.com/studio → install → on first start choose **Standard** setup (it downloads the Android SDK).
You only need Android Studio for the SDK and the emulator; you will code in VS Code.

## STEP 6 – Configure the Android SDK and emulator
Android Studio → **More Actions → SDK Manager**:
* **SDK Platforms:** tick the newest stable **Android (API 34 or 35)**.
* **SDK Tools:** tick **Android SDK Command-line Tools (latest)**, **Android SDK Platform-Tools**, **Android Emulator** → **Apply**.

Create an emulator: **More Actions → Virtual Device Manager → Create Device** → *Pixel 6* → system image *API 34, x86_64* (download) → Finish → press ▶ to start it.
* **Error:** "VT-x / virtualization is disabled" → enable virtualization in BIOS and the Windows feature **Windows Hypervisor Platform**.
* Using a real phone instead: Settings → About phone → tap *Build number* 7 times → Developer options → enable **USB debugging** → plug in via USB → accept the prompt.

## STEP 7 – Verify Flutter installation
```
flutter doctor --android-licenses
flutter doctor
```
Press `y` to accept licences.
* **Expected:** green ✓ for *Flutter*, *Windows Version*, *Android toolchain*, *Chrome*, *Android Studio*, *VS Code*, *Connected device*.
  (The "Visual Studio" line is only for Windows desktop apps – ignore it.)
* **Error "cmdline-tools component is missing"** → install *Android SDK Command-line Tools* (Step 6).
* **Error "Unable to locate Android SDK"** → `flutter config --android-sdk "C:\Users\<you>\AppData\Local\Android\Sdk"`.
* **Error "Android licenses not accepted"** → run the first command again.

## STEP 8 – Extract the MediTrack ZIP
Right-click `MediTrack_Flutter_Complete_Project.zip` → **Extract All** → e.g. `C:\Projects\`.
**Check:** the folder you will open must contain `pubspec.yaml`, `lib`, `test`, `docs` **directly**
(if you see `meditrack\meditrack\pubspec.yaml`, use the inner folder).

## STEP 9 – Open the project in VS Code
VS Code → **File → Open Folder…** → choose the folder with `pubspec.yaml` → **Yes, I trust the authors**.
Open the terminal: **Terminal → New Terminal**. **Expected:** the prompt ends with the project folder name.

## STEP 10 – Prepare Android and install packages
This ZIP has no `android` folder (it is created on your computer). In the terminal:
```
flutter create . --org com.meditrack --platforms android
dart run tool/patch_android.dart
flutter pub get
flutter gen-l10n
```
* **Expected:** "Wrote … files", "AndroidManifest.xml patched.", "Got dependencies!", and `lib/l10n/app_localizations.dart` appears.
* After `flutter create`, check that `lib/main.dart` still starts with `import 'package:cloud_firestore/…` and `pubspec.yaml` still lists
  `flutter_riverpod`. If either was replaced, extract the ZIP again over them.
* **Two edits are still needed** in `android/app/build.gradle.kts` (or `build.gradle`): set **`minSdk = 23`** and enable
  **core library desugaring** – exact lines are in `docs/ANDROID_SETUP.md`.
* **Error "version solving failed"** → run `flutter pub upgrade --major-versions` and send me the message if it persists
  (package versions were chosen without being able to test them).

## STEP 11 – Create the Firebase project
Follow **docs/FIREBASE_SETUP.md §1**: https://console.firebase.google.com → Create project `MediTrack`.
*(Skip Steps 11–17 to try the app first in offline mode – use "Continue offline" on the login screen.)*

## STEP 12 – Install Firebase CLI
Install Node.js LTS from https://nodejs.org (default options), reopen the terminal, then:
```
npm install -g firebase-tools
firebase --version
firebase login
```
* **Expected:** a version number; a browser opens to sign in.
* **Error:** "running scripts is disabled" (PowerShell) → run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once, or use Command Prompt.

## STEP 13 – Install FlutterFire CLI
```
dart pub global activate flutterfire_cli
flutterfire --version
```
* **Error:** "'flutterfire' is not recognized" → add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH (as in Step 2) and reopen the terminal.

## STEP 14 – Configure Firebase
```
flutterfire configure
```
Select your Firebase project (arrow keys + Enter), choose **android** only (Space to toggle).
* **What happens:** it **overwrites `lib/firebase_options.dart`** with your project's settings and adds `android/app/google-services.json`
  and the Google-services Gradle plugin lines.
* **Check:** open `lib/firebase_options.dart` – it should now contain `static const FirebaseOptions android = FirebaseOptions(…)`.
* **Error:** "Failed to fetch Firebase projects" → run `firebase login` again.

## STEP 15 – Enable Email/Password authentication
Firebase Console → **Build → Authentication → Get started → Sign-in method → Email/Password → Enable → Save**.

## STEP 16 – Create Firestore
Firebase Console → **Build → Firestore Database → Create database** → choose a region → **Production mode** → **Enable**.

## STEP 17 – Deploy and test the security rules
```
firebase use --add
firebase deploy --only firestore:rules
```
Select your project and give it an alias (e.g. `default`).
**Expected:** "Deploy complete!". Test in Console → Firestore → Rules → *Rules Playground* (see FIREBASE_SETUP.md §5).
Optional photo storage: enable Storage in the Console (may need the Blaze plan – see FIREBASE_SETUP.md §6), then `firebase deploy --only storage`.

## STEP 18 – Run the Android application
Start the emulator (Step 6) or plug in your phone. In VS Code check the bottom-right device name, then:
```
flutter run
```
* **Expected:** the first build takes 5–15 minutes; the app opens on the onboarding screen.
* **Build errors and fixes:**
  * "minSdkVersion 21 cannot be smaller than 23" → set `minSdk = 23`.
  * "Dependency … requires core library desugaring" → add the desugaring lines (docs/ANDROID_SETUP.md).
  * "Execution failed for task ':app:…'" → run `flutter clean`, then `flutter pub get`, then `flutter run`.
  * Gradle/JDK errors → in Android Studio use *Settings → Build Tools → Gradle → Gradle JDK = embedded JDK*, then `flutter doctor -v`.
* On Android 13+ allow notifications when asked; for exact times open **Schedule → bell icon → Allow exact alarms**.

## STEP 19 – Test all modules (checklist)
Tick each item:
1. Splash → onboarding (Skip / Next) → login screen.
2. Register (needs Firebase) or **Continue offline**; log out and log in again; Forgot password sends an e-mail.
3. **Medicines:** add (with photo), edit, search, filter Active/Completed, sort, open details, delete.
4. **Schedule:** add a schedule 2 minutes ahead → notification appears with **Taken / Snooze / Skip** → press Taken.
5. **History** (Reports tab): the dose shows as Taken; try Day / Week / Month and the medicine filter; Statistics charts; Calendar dots.
6. **Stock:** set stock 10 → mark a dose taken → stock is 9 (and not 8 if you tap Taken twice). Low-stock and expiry chips.
7. **Family:** add a member with consent → switch to them → add a medicine → switch back to *Me* (lists are separate).
8. **Health records:** add blood pressure, glucose, weight, a note; chart appears; date filter.
9. **Appointments:** add one 5 minutes ahead → reminder; mark completed; history tab.
10. **Allergies, emergency contacts, prescriptions** add / edit / delete.
11. **Settings:** dark mode, English ↔ বাংলা; **PDF report:** Reports tab → PDF icon → preview and share.
12. **Offline:** turn on airplane mode, add data, turn it off → Settings → **Sync now** → check Firestore Console.
13. Restart the phone: reminders should still fire (open the app once afterwards).

Run the automated tests too:
```
flutter test
flutter test integration_test/offline_flow_test.dart     (emulator running)
```

## STEP 20 – Build a release APK
```
flutter build apk --release
```
* **Expected:** "✓ Built build\app\outputs\flutter-apk\app-release.apk (xx MB)".
* This APK is signed with the *debug* key, which is fine for a university demo. A Play Store release needs your own keystore
  (**never put keystores or `key.properties` in the ZIP or in Git**).
* **Error:** out of memory → close other programs, run `flutter clean` and retry.

## STEP 21 – Locate and install the APK on a phone
* File: `<project>\build\app\outputs\flutter-apk\app-release.apk`.
* **By cable:** enable USB debugging, then `adb install -r build\app\outputs\flutter-apk\app-release.apk`
  (adb is in `%LOCALAPPDATA%\Android\Sdk\platform-tools`).
* **By file:** copy the APK to the phone (USB / Google Drive), tap it, allow **Install unknown apps** for that file manager, install.
* On the phone: allow notifications; set MediTrack's battery usage to **Unrestricted** (needed on Xiaomi, Oppo, Vivo, Huawei, Samsung "sleeping apps").
* **Error:** "App not installed" → uninstall the debug version first.
