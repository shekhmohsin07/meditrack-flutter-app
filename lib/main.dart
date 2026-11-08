
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/core/notifications/notification_service.dart';
import 'package:meditrack/core/services/firebase_status.dart';
import 'package:meditrack/core/services/settings_providers.dart';
import 'package:meditrack/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // SQLite is our offline store.
    // Disable Firestore's local persistence.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );

  } catch (e) {
    // Firebase not configured -> run offline-only.
    FirebaseStatus.initError = e.toString();

    debugPrint('Firebase not initialised: $e');
  }

  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notifications not initialised: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MediTrackApp(),
    ),
  );
}
