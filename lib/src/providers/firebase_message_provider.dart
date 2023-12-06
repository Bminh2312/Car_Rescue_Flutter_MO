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
}
