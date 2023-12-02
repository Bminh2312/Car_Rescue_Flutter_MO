
import 'dart:convert';

import 'package:CarRescue/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Tilte: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FireBaseMessageProvider {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChanel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Improtance Channel',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  String? deviceToken;

  Future<String?> getDeviceToken() async {
    try {
      deviceToken = await _firebaseMessaging.getToken();

      print("Device Token: $deviceToken");
      return deviceToken;
    } catch (e) {
      print("Lỗi khi lấy Device Token: $e");
      return null;
    }
  }

  

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed("/notify");
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChanel.id, _androidChanel.name,
                channelDescription: _androidChanel.description,
                icon: '@drawable/ic_launcher'),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const setting = InitializationSettings(android: android);

    await _localNotifications.initialize(setting,
        onSelectNotification: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload!));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChanel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotifications();
    initLocalNotifications();
  }
}
