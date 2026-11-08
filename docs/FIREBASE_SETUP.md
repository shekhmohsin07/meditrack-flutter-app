# Firebase setup (beginner guide)

MediTrack works **without** Firebase ("Continue offline" on the login screen). Do this guide to get accounts and cloud sync.

> Never put service-account JSON files or passwords into the project. `flutterfire configure` only creates
> *client* settings (they are not secrets, but access is protected by the security rules below).

## 1. Create the project
1. Go to https://console.firebase.google.com and sign in with a Google account.
2. **Create a project** → name it `MediTrack` → Analytics is optional (you can turn it off) → **Create project**.

## 2. Connect the app (FlutterFire)
In the VS Code terminal, inside the project folder:
```
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
Choose your project, select **android** only. This overwrites `lib/firebase_options.dart` and adds
`android/app/google-services.json` (both are in `.gitignore`).

If `flutterfire` is "not recognized", add `%LOCALAPPDATA%\Pub\Cache\bin` to your PATH and reopen the terminal.

## 3. Authentication
Console → **Build → Authentication → Get started → Sign-in method → Email/Password → Enable → Save**.
Password reset e-mails work automatically.

## 4. Firestore
Console → **Build → Firestore Database → Create database** → pick a region near you → **Production mode** → Enable.
Production mode starts closed; the next step opens it only for the signed-in owner.

## 5. Security rules
Rules files: `firebase/firestore.rules` and `firebase/storage.rules` (listed in `firebase.json`).

Deploy from the terminal:
```
firebase use --add            (choose your project)
firebase deploy --only firestore:rules
```
Or paste the file into Console → Firestore → **Rules** → **Publish**.

**Test the rules** (Console → Firestore → Rules → *Rules Playground*): a read of `/users/ABC/medicines/1` with
"Authenticated" and uid `ABC` must be **allowed**; with uid `XYZ` or unauthenticated it must be **denied**.

## 6. Storage (optional, for prescription / profile photos in the cloud)
Console → **Build → Storage → Get started**. **Check the current Firebase pricing page:** for new projects Cloud Storage may
require the pay-as-you-go (Blaze) plan with a billing account, even though small usage has a free allowance.
If you do not want that, skip this step: photos simply stay on the phone ("Only on this phone" is shown).
After enabling: `firebase deploy --only storage`.

## 7. Check it works
Run the app → Register → Profile → Settings → **Sync now** → "All changes are saved to the cloud."
Add a medicine → Sync now → Console → Firestore → `users/<uid>/medicines` shows the document.

## Troubleshooting
| Problem | Fix |
|---|---|
| App says "Firebase not initialised" in the log and login is disabled | `flutterfire configure` was not run (or `lib/firebase_options.dart` was overwritten by the placeholder) |
| `permission-denied` in the sync card | Rules not deployed, or you are signed out |
| `[firebase_auth/operation-not-allowed]` | Email/Password sign-in is not enabled (step 3) |
| Build error about `minSdkVersion` | Set `minSdk = 23` (docs/ANDROID_SETUP.md) |
| Sync card says "No internet" on an emulator | Check the emulator's network, then tap Sync now |
| Cost worries | Firestore has a free daily allowance; MediTrack syncs only changed documents |
