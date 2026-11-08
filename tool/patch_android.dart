// Fixes the Android project so that reminders and alarms work.
// Run from the project folder, after `flutter create`:
//
//     dart run tool/patch_android.dart
//
// It is safe to run again (it only adds what is missing) and it keeps *.bak copies of changed files.
// What it does:
//   1. AndroidManifest.xml: notification, boot and exact-alarm permissions + the 3 receivers the
//      flutter_local_notifications plugin needs. WITHOUT THESE NO REMINDER EVER APPEARS, and the app is
//      not listed under  Settings > Apps > Special access > Alarms & reminders.
//   2. app/build.gradle(.kts): minSdk 23 (Firebase), core library desugaring (notifications plugin),
//      and "no code shrinking" for release builds (R8 breaks scheduled notifications in release APKs).
import 'dart:io';

final report = <String>[];

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    stderr.writeln('android/app/src/main/AndroidManifest.xml not found.\n'
        'Run this first (in the project folder):\n'
        '  flutter create . --org com.meditrack --platforms android');
    exit(1);
  }
  patchManifest(manifest);
  patchGradle();

  stdout.writeln('\n=== Android fix report ===');
  for (final line in report) {
    stdout.writeln(line);
  }
  stdout.writeln('\nNext: flutter clean && flutter pub get && flutter build apk --release');
  stdout.writeln('Then UNINSTALL the old MediTrack from the phone and install the new APK.');
}

void backup(File f) {
  final bak = File('${f.path}.bak');
  if (!bak.existsSync()) f.copySync(bak.path);
}

// ------------------------------------------------------------------ manifest
void patchManifest(File file) {
  var xml = file.readAsStringSync();
  final original = xml;

  const permissions = <String>[
    'POST_NOTIFICATIONS', // Android 13+ notifications
    'RECEIVE_BOOT_COMPLETED', // re-register reminders after a restart
    'VIBRATE',
    'WAKE_LOCK',
    'SCHEDULE_EXACT_ALARM', // exact reminders; makes the app appear in "Alarms & reminders"
    'USE_EXACT_ALARM', // Android 13+: exact alarms without a user switch (fine for side-loaded apps)
  ];
  final missingPermissions = [for (final p in permissions) if (!xml.contains('android.permission.$p')) p];
  if (missingPermissions.isNotEmpty) {
    final lines = [for (final p in missingPermissions) '    <uses-permission android:name="android.permission.$p"/>'].join('\n');
    final idx = xml.indexOf('<application');
    if (idx < 0) {
      report.add('! Could not find <application> in AndroidManifest.xml - add the permissions by hand (docs/ANDROID_SETUP.md).');
    } else {
      xml = '${xml.substring(0, idx)}$lines\n    ${xml.substring(idx)}';
      report.add('+ manifest: added permissions ${missingPermissions.join(', ')}');
    }
  } else {
    report.add('= manifest: all permissions already present');
  }

  const pkg = 'com.dexterous.flutterlocalnotifications';
  final receivers = <String, String>{
    'ActionBroadcastReceiver': '        <receiver android:exported="false" android:name="$pkg.ActionBroadcastReceiver"/>',
    'ScheduledNotificationReceiver': '        <receiver android:exported="false" android:name="$pkg.ScheduledNotificationReceiver"/>',
    'ScheduledNotificationBootReceiver': '''        <receiver android:exported="false" android:name="$pkg.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>''',
  };
  final missingReceivers = [for (final k in receivers.keys) if (!xml.contains(k)) k];
  if (missingReceivers.isNotEmpty) {
    final close = xml.lastIndexOf('</application>');
    if (close < 0) {
      report.add('! Could not find </application> - add the receivers by hand (docs/ANDROID_SETUP.md).');
    } else {
      final block = [for (final k in missingReceivers) receivers[k]!].join('\n');
      xml = '${xml.substring(0, close)}$block\n    ${xml.substring(close)}';
      report.add('+ manifest: added receivers ${missingReceivers.join(', ')}');
    }
  } else {
    report.add('= manifest: all receivers already present');
  }

  if (xml != original) {
    backup(file);
    file.writeAsStringSync(xml);
  }
}

// ------------------------------------------------------------------ gradle
void patchGradle() {
  final kts = File('android/app/build.gradle.kts');
  final groovy = File('android/app/build.gradle');
  final isKts = kts.existsSync();
  final file = isKts ? kts : groovy;
  if (!file.existsSync()) {
    report.add('! android/app/build.gradle(.kts) not found - edit minSdk / desugaring by hand (docs/ANDROID_SETUP.md).');
    return;
  }
  var text = file.readAsStringSync();
  final original = text;

  // 1. minSdk 23
  final minRe = isKts ? RegExp(r'minSdk\s*=\s*([^\n]+)') : RegExp(r'minSdk(?:Version)?\s+([^\n]+)');
  final m = minRe.firstMatch(text);
  if (m == null) {
    report.add('! minSdk line not found - set it to 23 by hand.');
  } else {
    final value = int.tryParse(RegExp(r'\d+').firstMatch(m.group(1)!)?.group(0) ?? '');
    final isNumber = RegExp(r'^\s*\d+\s*$').hasMatch(m.group(1)!);
    if (isNumber && value != null && value >= 23) {
      report.add('= gradle: minSdk already $value');
    } else {
      text = text.replaceFirst(minRe, isKts ? 'minSdk = 23' : 'minSdkVersion 23');
      report.add('+ gradle: minSdk set to 23 (was ${m.group(1)!.trim()})');
    }
  }

  // 2. core library desugaring
  final desugarFlag = isKts ? 'isCoreLibraryDesugaringEnabled' : 'coreLibraryDesugaringEnabled';
  if (!text.contains(desugarFlag)) {
    final co = RegExp(r'compileOptions\s*\{').firstMatch(text);
    if (co == null) {
      report.add('! compileOptions block not found - enable core library desugaring by hand.');
    } else {
      final line = isKts ? '\n        isCoreLibraryDesugaringEnabled = true' : '\n        coreLibraryDesugaringEnabled true';
      text = text.replaceRange(co.end, co.end, line);
      report.add('+ gradle: core library desugaring enabled');
    }
  } else {
    report.add('= gradle: desugaring flag already present');
  }
  if (!text.contains('coreLibraryDesugaring(') && !text.contains("coreLibraryDesugaring '")) {
    final dep = isKts
        ? '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")'
        : "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'";
    final d = RegExp(r'^dependencies\s*\{', multiLine: true).firstMatch(text);
    if (d != null) {
      text = text.replaceRange(d.end, d.end, '\n$dep');
    } else {
      text = '$text\ndependencies {\n$dep\n}\n';
    }
    report.add('+ gradle: added coreLibraryDesugaring dependency (version from memory - if Gradle complains, use the version in the flutter_local_notifications README)');
  } else {
    report.add('= gradle: desugaring dependency already present');
  }

  // 3. no code shrinking in release builds
  if (!text.contains('isMinifyEnabled') && !text.contains('minifyEnabled')) {
    final rel = RegExp(r'release\s*\{').firstMatch(text);
    if (rel == null) {
      report.add('! release build type not found - add isMinifyEnabled = false by hand.');
    } else {
      final lines = isKts
          ? '\n            isMinifyEnabled = false\n            isShrinkResources = false'
          : '\n            minifyEnabled false\n            shrinkResources false';
      text = text.replaceRange(rel.end, rel.end, lines);
      report.add('+ gradle: release code shrinking switched off (keeps scheduled notifications working)');
    }
  } else {
    report.add('= gradle: minify setting already present (check it is false)');
  }

  if (text != original) {
    backup(file);
    file.writeAsStringSync(text);
  }
}
