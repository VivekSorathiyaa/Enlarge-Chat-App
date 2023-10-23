import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/Change%20languige/local_string.dart';
import 'package:chatapp/view/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Change Theme/model_theme.dart';
import '../componet/app_text_style.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/firebase_notification_handler.dart';

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

class _MyAppState extends State<MyApp> {
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

  @override
  void initState() {
    init();
    super.initState();
    _configureSelectNotificationSubject();
  }

  Future init() async {
    await notificationHandler.initialize();
    await notificationConfiguration();
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    selectNotificationStream.close();
    super.dispose();
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
        RemoteNotification? notification = message.notification;
        if (notification != null) {
          // await homeScreenController.getNotificationCount();
          showNotification(notification.title!, notification.body!,
              json.encode(message.data));
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        // onSelectNotification(json.encode(message.data));
        selectNotificationStream.add(json.encode(message.data));
      },
    );
  }

  showNotification(String title, String message, dynamic payload) async {
    var android = const AndroidNotificationDetails(
      'channel id',
      'channel NAME',
      channelDescription: 'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max,
      playSound: true,
    );
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(iOS: iOS, android: android);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platform,
      payload: payload,
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payLoadData) async {
      log("===payLoadData===   $payLoadData");
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedLocale = AppPreferences().getLocaleFromPreferences();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelTheme(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeNotifier = Provider.of<ModelTheme>(context);
          return GetMaterialApp(
            translations: LocaleString(),
            locale: savedLocale ?? Locale('en', 'US'),
            title: 'Chat App',
            themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: themeNotifier.isDark
                ? ThemeData(
                    scaffoldBackgroundColor: primaryBlack,
                    fontFamily: AppTextStyle.fontFamilyInter,
                    appBarTheme: AppBarTheme(backgroundColor: blackThemeColor),
                    primarySwatch: createMaterialColor(Colors.white),
              hintColor: primaryWhite,
                    colorScheme: ColorScheme.fromSwatch()
                        .copyWith(secondary: blackThemeColor),
                   iconTheme: IconThemeData(color: primaryWhite),
                  )
                : ThemeData(
                    scaffoldBackgroundColor: appBackgroundColor,
                    fontFamily: AppTextStyle.fontFamilyInter,
                    hintColor: primaryBlack,
                    appBarTheme: AppBarTheme(backgroundColor: primaryColor),
                    iconTheme: IconThemeData(color: primaryBlack),
                    colorScheme: ColorScheme.fromSwatch()
                        .copyWith(secondary: primaryColor),
                  ),
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
