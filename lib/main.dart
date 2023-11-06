
//flutter build apk --split-per-abi

import 'dart:convert';
import 'dart:io';

import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'models/user_model.dart';
import 'utils/common_method.dart';
import 'view/video_conference_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      '-----_firebaseMessagingBackgroundHandler-----${message.toMap().toString()}');
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  handleNotifications(message);
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupFlutterNotifications() async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}


var uuid = Uuid();

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupFlutterNotifications();

  await AppPreferences.init();
  // AppNotification().initNotification();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
  WidgetsBinding.instance.addObserver(MyWidgetsBindingObserver());
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
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future handleNotifications(RemoteMessage message) async {
  var data = message.data;
  print("---data--- ${data.toString()}");
  UserModel targetUser = new UserModel.fromMap(json.decode(data['user']));
  if (data['type'] == "message") {
    showNotification(data);
  } else if (data['type'] == "videoCall") {
    showCallkitIncoming(
      targetUser: targetUser,
      id: data['roomId'],
    );
  } else if (data['type'] == "videoCallCut") {
    await FlutterCallkitIncoming.endCall(data['roomId']);
  }
  listenCallEvent();
}

void showNotification(data) async {
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
    data['title'],
    data['body'],
    platform,
  );
}

Future<void> showCallkitIncoming(
    {required UserModel targetUser, required String id}) async {
  listenCallEvent();

  CallKitParams callKitParams = CallKitParams(
    id: id,
    nameCaller: targetUser.fullName,
    appName: 'Enlarge Chat App',
    avatar: targetUser.profilePic,
    handle: targetUser.phone,
    type: 0,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    duration: 30000,
    // extra: <String, dynamic>{'userId': '1a2b3c4d'},
    // headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: targetUser.profilePic,
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call"),
    ios: IOSParams(
      iconName: 'CallKitLogo',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
}

Future listenCallEvent() async {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    print('-----event-----${event.toString()}');
    switch (event!.event) {
      case Event.actionCallIncoming:
        // TODO: received an incoming call
        break;
      case Event.actionCallStart:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
        break;
      case Event.actionCallAccept:
        Get.to(() => VideoConferenceScreen(
              chatRoomModel: null,
              chatRoomId: event.body['id'],
            ));
        break;
      case Event.actionCallDecline:
        await FlutterCallkitIncoming.endCall(event.body['id']);

        break;
      case Event.actionCallEnded:
        break;
      case Event.actionCallTimeout:
        break;
      case Event.actionCallCallback:
        break;
      case Event.actionCallToggleHold:
        break;
      case Event.actionCallToggleMute:
        break;
      case Event.actionCallToggleDmtf:
        break;
      case Event.actionCallToggleGroup:
        // TODO: only iOS
        break;
      case Event.actionCallToggleAudioSession:
        // TODO: only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
        // TODO: only iOS
        break;
      case Event.actionCallCustom:
        // TODO: for custom action
        break;
    }
  });
}
