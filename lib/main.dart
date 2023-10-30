import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'utils/common_method.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(MyWidgetsBindingObserver());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await requestNotificationPermission();
  await AppPreferences.init();
  runApp(MyApp());
}

Future<void> requestNotificationPermission() async {
  Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
}
class MyWidgetsBindingObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("-----state----- ${state.toString()}");
    if (state == AppLifecycleState.inactive) {
      CommonMethod.setOfflineStatus();
    } else if (state == AppLifecycleState.resumed) {
      CommonMethod.setOnlineStatus();
    } else if (state == AppLifecycleState.paused) {
      CommonMethod.setOfflineStatus();
    } else if (state == AppLifecycleState.detached) {
      CommonMethod.setOfflineStatus();
    }
  }
}
