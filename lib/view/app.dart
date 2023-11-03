import 'dart:async';
import 'dart:convert';

import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/chat_room_screen.dart';
import 'package:chatapp/view/home_screen.dart';
import 'package:chatapp/view/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Change Language/local_string.dart';
import '../controller/theme_controller.dart';
import '../main.dart';
import '../models/user_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ever<bool>(themeController.isDark, (isDark) {
      final newTheme =
          isDark ? themeController.darkTheme : themeController.lightTheme;
      Get.changeTheme(newTheme);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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
