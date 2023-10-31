import 'dart:async';
import 'dart:convert';

import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../Change Language/local_string.dart';
import '../controller/theme_controller.dart';
import '../utils/firebase_notification_handler.dart';

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
  final FirebaseNotificationHandler notificationHandler =
      FirebaseNotificationHandler();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  final ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    init();
    WidgetsBinding.instance.addObserver(this);

    _configureSelectNotificationSubject();
    
    // Listen to theme changes and update the theme in the initState
    ever<bool>(themeController.isDark, (isDark) {
      final newTheme = isDark ? themeController.darkTheme : themeController.lightTheme;
      Get.changeTheme(newTheme);
      // If the theme affects the app bar color, set it here too
      // AppBar().copyWith(backgroundColor: newTheme.appBarTheme.backgroundColor);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes (e.g., app going to the background or foreground).
    // You can take appropriate actions here.
  }

  Future<void> init() async {
    await notificationHandler.initialize();
    await notificationConfiguration();
  }

  Future<void> notificationConfiguration() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            selectNotificationStream.add(notificationResponse.payload);
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showNotification(
            notification.title!, notification.body!, json.encode(message.data));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      selectNotificationStream.add(json.encode(message.data));
    });
  }

  void showNotification(String title, String message, dynamic payload) async {
    final android = const AndroidNotificationDetails(
      'channel id',
      'channel NAME',
      channelDescription: 'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max,
      playSound: true,
    );
    final iOS = const DarwinNotificationDetails();
    final platform = NotificationDetails(iOS: iOS, android: android);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platform,
      payload: payload,
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payloadData) {
      print("===payloadData===   $payloadData");
    });
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
