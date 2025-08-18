// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);
//     await _localNotificationsPlugin.initialize(initSettings);
//
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//         await _showLocalNotification(message);
//         await _storeNotificationLocally(message);
//       });
//
//       FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler,
//       );
//
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         await _saveTokenToPrefs(token);
//       }
//
//       _firebaseMessaging.onTokenRefresh.listen((newToken) async {
//         await _saveTokenToPrefs(newToken);
//       });
//     }
//   }
//
//   static Future<void> _saveTokenToPrefs(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("fcmtoken", token);
//
//   }
//
//   static Future<String?> getTokenFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("fcmtoken");
//   }
//
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     const androidDetails = AndroidNotificationDetails(
//       'main_channel',
//       'General Notifications',
//       channelDescription: 'For all app notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const notificationDetails = NotificationDetails(android: androidDetails);
//
//     await _localNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'New Message',
//       message.notification?.body ?? '',
//       notificationDetails,
//     );
//   }
//
//   static Future<void> _storeNotificationLocally(RemoteMessage message) async {
//     final prefs = await SharedPreferences.getInstance();
//     final oldList = prefs.getStringList("local_notifications") ?? [];
//
//     final newEntry =
//         "${message.notification?.title ?? ''}|${message.notification?.body ?? ''}|${DateTime.now().toString()}";
//     oldList.add(newEntry);
//     await prefs.setStringList("local_notifications", oldList);
//   }
//
//   static Future<List<Map<String, String>>> getLocalNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("local_notifications") ?? [];
//     return data.map((e) {
//       final parts = e.split("|");
//       return {'title': parts[0], 'body': parts[1], 'date': parts[2]};
//     }).toList();
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await NotificationService._showLocalNotification(message);
//   await NotificationService._storeNotificationLocally(message);
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotificationsPlugin.initialize(initSettings);

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _showLocalNotification(message);
        await _storeNotificationLocally(message);
      });

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await _fetchAndSaveToken();

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        print("FCM Token: $newToken");
        await _saveTokenToPrefs(newToken);
      });
    } else {
      print("Notification permissions denied!");
    }
  }

  static Future<String?> _fetchAndSaveToken({
    int retries = 3,
    int delay = 2,
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print("Fresh FCM Token: $token");
          await _saveTokenToPrefs(token);
          return token;
        } else {
          print("FCM Token null hai, retry attempt ${i + 1}/$retries");
        }
      } catch (e) {
        print("FCM Token fetch error: $e");
      }
      await Future.delayed(Duration(seconds: delay));
    }
    print("FCM Token fetch failed after $retries attempts");
    return null;
  }

  static Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmtoken", token);
    print("FCM Token saved to SharedPreferences: $token");
  }

  static Future<String?> getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("fcmtoken");
    if (token != null) {
      print("Saved FCM Token: $token");
      return token;
    }

    return await _fetchAndSaveToken();
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      channelDescription: 'For all app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  static Future<void> _storeNotificationLocally(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final oldList = prefs.getStringList("local_notifications") ?? [];

    final newEntry =
        "${message.notification?.title ?? ''}|${message.notification?.body ?? ''}|${DateTime.now().toString()}";
    oldList.add(newEntry);
    await prefs.setStringList("local_notifications", oldList);
  }

  static Future<List<Map<String, String>>> getLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("local_notifications") ?? [];
    return data.map((e) {
      final parts = e.split("|");
      return {'title': parts[0], 'body': parts[1], 'date': parts[2]};
    }).toList();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._showLocalNotification(message);
  await NotificationService._storeNotificationLocally(message);
}