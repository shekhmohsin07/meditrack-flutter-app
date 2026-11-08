import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditrack/core/database/app_database.dart';
import 'package:meditrack/features/medicine_logs/data/intake_repository.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// New channel ID: Android keeps channel sound settings once created.
const _channelId = 'medicine_alarm_v3';

const snoozeMinutes = 10;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _ready = false;

  static String? lastError;

  // Same dose + same medicine = same notification ID.
  static int idFor(String medicineId, DateTime at, [String salt = '']) {
    var h = 0x811c9dc5;

    for (final c
        in '$medicineId|${at.toUtc().toIso8601String()}|$salt'.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }

    return h & 0x7FFFFFFF;
  }

  Future<void> init() async {
    if (_ready) return;

    tzdata.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // Android 13+ notification permission.
  Future<bool> requestNotificationPermission() async {
    await init();
    return await _android?.requestNotificationsPermission() ?? false;
  }

  // Android 12+ exact alarm permission.
  Future<bool> requestExactAlarmPermission() async {
    await init();
    return await _android?.requestExactAlarmsPermission() ?? false;
  }

  // Android 14+ full-screen intent permission.
  Future<bool> requestFullScreenIntentPermission() async {
    await init();
    return await _android?.requestFullScreenIntentPermission() ?? false;
  }

  // Request all required permissions from a user-initiated settings button.
  Future<void> requestAlarmPermissions() async {
    await init();

    final notifications = await requestNotificationPermission();
    debugPrint('Notification permission: $notifications');

    final exact = await requestExactAlarmPermission();
    debugPrint('Exact alarm permission request: $exact');

    final fullScreen = await requestFullScreenIntentPermission();
    debugPrint('Full-screen permission request: $fullScreen');

    final exactGranted = await canScheduleExact();
    debugPrint('Can schedule exact alarms: $exactGranted');
  }

  Future<bool> canScheduleExact() async {
    await init();
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  Future<bool> notificationsEnabled() async {
    await init();
    return await _android?.areNotificationsEnabled() ?? false;
  }

  // Alarm notification details.
  NotificationDetails _alarmDetails({
    required Map<String, String> labels,
    required bool withActions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Medicine alarms',
        channelDescription: 'Rings like an alarm at medicine time',

        importance: Importance.max,
        priority: Priority.max,

        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,

        playSound: true,

        // Android default alarm ringtone.
        sound: const UriAndroidNotificationSound(
          'content://settings/system/alarm_alert',
        ),

        audioAttributesUsage: AudioAttributesUsage.alarm,

        enableVibration: true,

        vibrationPattern: Int64List.fromList(
          <int>[0, 800, 500, 800, 500, 800],
        ),

        // Android FLAG_INSISTENT = 4.
        // Requests repeating notification sound.
        additionalFlags: Int32List.fromList(<int>[4]),

        fullScreenIntent: true,

        // Automatically removes the notification after 2 minutes.
        timeoutAfter: 120000,

        actions: withActions
            ? [
                AndroidNotificationAction(
                  'taken',
                  labels['taken'] ?? 'Taken',
                ),
                AndroidNotificationAction(
                  'snooze',
                  labels['snooze'] ?? 'Snooze',
                ),
                AndroidNotificationAction(
                  'skip',
                  labels['skip'] ?? 'Skip',
                ),
              ]
            : null,
      ),
    );
  }

  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String payload,
    required Map<String, String> labels,
    bool withActions = true,
  }) async {
    await init();

    try {
      final exact = await canScheduleExact();

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.UTC),
        _alarmDetails(
          labels: labels,
          withActions: withActions,
        ),
        payload: payload,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      lastError = null;

      debugPrint(
        'Alarm scheduled: $title | $when | Exact: $exact',
      );
    } catch (e) {
      lastError = e.toString();
      debugPrint('Alarm scheduling failed: $e');
      rethrow;
    }
  }

  // Number of reminders currently waiting in Android.
  Future<int> pendingCount() async {
    await init();
    return (await _plugin.pendingNotificationRequests()).length;
  }

  // Immediate alarm-style test notification.
  Future<void> showTestNow(String title, String body) async {
    await init();

    await _plugin.show(
      999001,
      title,
      body,
      _alarmDetails(
        labels: const {},
        withActions: false,
      ),
    );
  }

  // Real scheduled alarm test.
  Future<void> scheduleTest(
    Duration delay,
    String title,
    String body,
    Map<String, String> labels,
  ) async {
    await scheduleAt(
      id: 999002,
      when: DateTime.now().add(delay),
      title: title,
      body: body,
      payload: '{"test":true}',
      labels: labels,
      withActions: false,
    );
  }

  // Immediate notification for caregiver missed-dose alerts.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'missed_dose_alerts',
          'Missed dose alerts',
          channelDescription: 'Alerts when a family member misses a dose',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }
}

// Handles Taken / Snooze / Skip actions.
Future<void> handleNotificationResponse(NotificationResponse r) async {
  final action = r.actionId;

  if (action == null || action.isEmpty || r.payload == null) {
    return;
  }

  try {
    final p = jsonDecode(r.payload!) as Map<String, dynamic>;

    // Ignore test notifications.
    if (p['test'] == true) {
      if (r.id != null) {
        await NotificationService.instance.cancel(r.id!);
      }
      return;
    }

    final medicineId = p['m'] as String;
    final scheduledAt = DateTime.parse(p['s'] as String);

    final intake = IntakeRepository(
      (await AppDatabase.open()).db,
    );

    switch (action) {
      case 'taken':
        await intake.record(
          medicineId: medicineId,
          scheduledAt: scheduledAt,
          status: IntakeStatus.taken,
        );

      case 'skip':
        await intake.record(
          medicineId: medicineId,
          scheduledAt: scheduledAt,
          status: IntakeStatus.skipped,
        );

      case 'snooze':
        await intake.record(
          medicineId: medicineId,
          scheduledAt: scheduledAt,
          status: IntakeStatus.snoozed,
        );

        final when = DateTime.now().add(
          const Duration(minutes: snoozeMinutes),
        );

        await NotificationService.instance.scheduleAt(
          id: NotificationService.idFor(
            medicineId,
            scheduledAt,
            'snooze',
          ),
          when: when,
          title: p['t'] as String,
          body: p['b'] as String,
          payload: r.payload!,
          labels: Map<String, String>.from(p['l'] as Map),
        );
    }

    if (r.id != null) {
      await NotificationService.instance.cancel(r.id!);
    }
  } catch (e) {
    debugPrint('Notification action failed: $e');
  }
}

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse r) {
  handleNotificationResponse(r);
}
