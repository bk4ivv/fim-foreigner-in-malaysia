import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Initializes FCM without requesting permission automatically.
/// The app should request notification permission only after the user opts in.
class FirebaseNotificationService {
  FirebaseNotificationService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || (!Platform.isAndroid && !Platform.isIOS)) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
      _initialized = true;
    } catch (_) {
      // Keep FIM usable if Firebase is unavailable during offline startup.
    }
  }

  static Future<bool> requestPermission() async {
    await initialize();
    if (!_initialized) return false;
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<String?> token() async {
    await initialize();
    if (!_initialized) return null;
    return FirebaseMessaging.instance.getToken();
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
