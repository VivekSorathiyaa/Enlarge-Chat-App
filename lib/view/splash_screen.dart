import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/login_screen.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage().then(
      (value) {
        print("---getInitialMessage----");
      },
    );

    FirebaseMessaging.onMessage.listen(handleNotifications);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('----onMessageOpenedApp----');

        listenCallEvent();
      },
    );

    startTime();
    super.initState();

  }
  Future getInitialMessage() async {
    RemoteMessage? fcmMessage;


    NotificationAppLaunchDetails? localMessage;
    await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((value) {
      localMessage = value;
    });
    if (
        (localMessage?.didNotificationLaunchApp == false)) {
          
    } else {
      onSelectNotification(json.encode(fcmMessage!.data));
    }
  }



  startTime() async {
    timer = Timer(
      const Duration(milliseconds: 1000),
      () async {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          Get.offAll(() => HomeScreen());
        } else {
          Get.offAll(() => LoginScreen());
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 50,
            color: primaryBlack,
          ),
          height08,
          Text(
            "Chat App",
            style: AppTextStyle.normalBold26,
          )
        ],
      )),
    );
  }
}
