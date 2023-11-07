
import 'dart:developer';
import 'package:chatapp/main.dart';
import 'package:chatapp/view/app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class AppNotification {
  static const notificationChannelId = "Vivek";

  Future initNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      // notificationCategories: darwinNotificationCategories,
    );

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    androidNotificationChannel = const AndroidNotificationChannel(
      notificationChannelId, //'''agenda_boa_notification_channel', // id
      'Vivek', // title
      description: 'Channel to show the app notifications.',
      // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    // create the channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    startBackGroundNotification();
  }

  static final firebaseMsg = FirebaseMessaging.instance;

  Future startBackGroundNotification() async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundmsg);
  }


  late AndroidInitializationSettings initializationSettingsAndroid;

  // create a notification channel in Android
  late AndroidNotificationChannel androidNotificationChannel;
}

//fcm bg. notifications
Future firebaseBackgroundmsg(RemoteMessage message) async {
  log(message.notification!.title.toString());
}
