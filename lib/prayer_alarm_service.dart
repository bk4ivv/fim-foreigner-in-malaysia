import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PrayerAlarmService {
  PrayerAlarmService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'fim_prayer_reminders';
  static const _channelName = 'Prayer reminders';
  static const _channelDescription =
      'Optional daily prayer-time reminders chosen by the user.';

  static const _prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  static Future<void> scheduleDailyPrayerReminders({
    required Map<String, DateTime> prayerTimes,
    required bool isBangla,
  }) async {
    await initialize();
    await _plugin.cancelAll();
    for (var index = 0; index < _prayers.length; index++) {
      final prayer = _prayers[index];
      final time = prayerTimes[prayer];
      if (time == null) continue;
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        index + 1,
        isBangla ? _banglaName(prayer) : prayer,
        isBangla
            ? 'নামাজের সময় হয়েছে।'
            : 'It is time for $prayer prayer.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancelPrayerReminders() async {
    await initialize();
    await _plugin.cancelAll();
  }

  static String _banglaName(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return 'ফজর';
      case 'Dhuhr':
        return 'যোহর';
      case 'Asr':
        return 'আসর';
      case 'Maghrib':
        return 'মাগরিব';
      case 'Isha':
        return 'এশা';
      default:
        return prayer;
    }
  }
}
