import 'dart:async';
import 'dart:convert';

import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../Change Language/local_string.dart';
import '../controller/theme_controller.dart';
import '../main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ThemeController themeController = Get.put(ThemeController());

  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  @override
  void initState() {
    super.initState();
    notificationConfiguration();
    WidgetsBinding.instance.addObserver(this);
    ever<bool>(themeController.isDark, (isDark) {
      final newTheme =
          isDark ? themeController.darkTheme : themeController.lightTheme;
      Get.changeTheme(newTheme);
    });
    _configureSelectNotificationSubject();
  }

  notificationConfiguration() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        print("-----flutterLocalNotificationsPlugin.initialize----");
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            // if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
            // }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        handleNotifications(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        // onSelectNotification(json.encode(message.data));
        selectNotificationStream.add(json.encode(message.data));
      },
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payLoadData) async {
      print("-------_configureSelectNotificationSubject----");
      onSelectNotification(payLoadData);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    selectNotificationStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      locale: AppPreferences().getLocaleFromPreferences() ?? Locale('en', 'US'),
      title: 'Chat App',
      themeMode:
          themeController.isDark.value ? ThemeMode.dark : ThemeMode.light,
      navigatorKey: navigatorKey,
      theme: themeController.isDark.value
          ? themeController.darkTheme
          : themeController.lightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
