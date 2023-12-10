import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/notify/notify_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/providers/firebase_message_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/view/splash_screen/splash_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String? userRole;
String? userId;
String? accountId;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void initializeDateFormattingVietnamese() async {
  await initializeDateFormatting('vi_VN', null);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message : ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  // await FireBaseMessageProvider().initLocalNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Intl.defaultLocale = 'vi';
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  initializeDateFormattingVietnamese();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  // Read the 'role' value
  userRole = GetStorage().read('role');
  userId = GetStorage().read('userId');
  accountId = GetStorage().read('accountId');

  print("user role: $userRole");
  print("userId : $userId");
  print("accountId : $accountId");

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: "Inter"),
    navigatorKey: navigatorKey,
    initialRoute: determineInitialRoute(),
    routes: {
      "/splash": (context) => SplashView(),
      "/customer/home": (context) => BottomNavBarView(page: 0),
      "/technician/home": (context) =>
          BottomNavBarTechView(userId: userId!, accountId: accountId!),
      "/vehicleowner/home": (context) =>
          BottomNavBarCarView(userId: userId!, accountId: accountId!),
    },
  ));
}

String determineInitialRoute() {
  if (userRole != null) {
    if (userRole!.contains('Technician')) {
      return '/technician/home';
    } else if (userRole!.contains('Customer')) {
      return '/customer/home';
    } else if (userRole!.contains('Rescuevehicleowner')) {
      return '/vehicleowner/home';
    } else {
      return '/roles';
    }
  } else {
    return '/splash';
  }
}
