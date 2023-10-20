import 'dart:developer';

import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart';

class FirebaseNotificationHandler {
  Future<void> initialize() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    } // await CommonMethod.refreshToken();
    // Configure notification handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message.data, true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message.data, false);
    });
  }

  Future<void> _handleNotification(
      Map<String, dynamic> data, bool isForeground) async {
    log('===datav===$data');
    final route = data['route'];

    if (route != null) {
      // Navigate to the appropriate screen based on the route
      // You can use your own routing mechanism (e.g., Navigator) here
      log("Navigate to route: $route");
    }
  }
}
