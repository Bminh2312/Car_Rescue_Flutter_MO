import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FireBaseMessageProvider {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Channel',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
    enableVibration: true,
    enableLights: true,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  String? deviceToken;

  Future<String?> getDeviceToken() async {
    try {
      deviceToken = await _firebaseMessaging.getToken();

      print("Device Token: $deviceToken");
      return deviceToken;
    } catch (e) {
      print("Error getting Device Token: $e");
      return null;
    }
  }

  void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  // Hiển thị thông báo ngay khi nhận được tin nhắn trong ứng dụng.
  _showNotification(message.notification);

  // Mở trang notify khi người dùng nhấn vào thông báo.
  Navigator.of(navigatorKey.currentContext!).pushNamed("/notify");
}


  Future<void> initPushNotifications() async {
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
  if (notification != null) {
    _localNotifications.show(
      notification.hashCode,
      notification.title ?? '',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }
});

}


  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const setting = InitializationSettings(android: android);

    await _localNotifications.initialize(
      setting,
      onSelectNotification: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload!));
        handleMessage(message);
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
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

  void _showNotification(RemoteNotification? notification) {
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title ?? '',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher',
        ),
      ),
      payload: jsonEncode(notification.toMap()),
    );
  }
}
