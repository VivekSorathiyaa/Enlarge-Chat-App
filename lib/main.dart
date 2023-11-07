
//flutter build apk --split-per-abi

import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/utils/app_notification.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/app.dart';
import 'package:chatapp/view/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      '-----_firebaseMessagingBackgroundHandler-----${message.toMap().toString()}');
  await Firebase.initializeApp();
  // await setupFlutterNotifications();
  handleNotifications(message);
  print('Handling a background message ${message.messageId}');
}

// late AndroidNotificationChannel channel;
// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

// Future<void> setupFlutterNotifications() async {
//   channel = const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }


var uuid = Uuid();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await setupFlutterNotifications();
  await AppPreferences.init();
  AppNotification().initNotification();
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
    // showNotification(
    //     title: data['title'],
    //     message: data['body'],
    //     payload: json.encode(message.data),
    //     targetUser: targetUser);

    showOrUpdateGroupedMessageNotification(
      roomID: data['roomId'],
      groupTitle: data['title'],
      payload: json.encode(message.data),
      targetUser: targetUser, message:  data['body'],
    );
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
int id = 0;

showNotification(
    {required String title,
    required String message,
    required UserModel targetUser,
    dynamic payload}) async {
  final String largeIconPath = await _downloadAndSaveFile(
      targetUser.profilePic ?? 'https://dummyimage.com/128x128/00FF00/000000',
      'largeIcon');
  var android = AndroidNotificationDetails(
    'channel id',
    'channel NAME',
    channelDescription: 'CHANNEL DESCRIPTION',
    priority: Priority.high,
    importance: Importance.max,
    playSound: true,
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    styleInformation: const MediaStyleInformation(),

  );
  var iOS = const DarwinNotificationDetails();
  var platform = NotificationDetails(iOS: iOS, android: android);
  await flutterLocalNotificationsPlugin.show(
    id++,
    title,
    message,
    platform,
    payload: payload,
  );
}

Map<String, int> notificationIdMap = {};
Future<void> showOrUpdateGroupedMessageNotification({
  required String roomID,
  required String groupTitle,
  required String message,
  required dynamic payload,
  required UserModel targetUser,
}) async {
  final existingNotificationId = notificationIdMap[roomID];
  final String largeIconPath = await _downloadAndSaveFile(
      targetUser.profilePic ?? 'https://dummyimage.com/128x128/00FF00/000000',
      'largeIcon');
  List<String> unReadMessages = await CommonMethod.fetchUnreadMessages(roomID);
  final inboxStyle = InboxStyleInformation(
    unReadMessages.map((message) => message).toList(),
    contentTitle:unReadMessages.isEmpty? message: '${unReadMessages.length} new messages',
    summaryText: 'New messages from $groupTitle',
  );

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    styleInformation: inboxStyle,
    priority: Priority.high,
    playSound: true,
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    importance: Importance.max,
    groupKey: roomID,
    setAsGroupSummary: true,
  );

  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  if (existingNotificationId != null) {
    // Update the existing notification
    await flutterLocalNotificationsPlugin.show(
      existingNotificationId,
      groupTitle,
      'New messages from $groupTitle',
      platformChannelSpecifics,
      payload: payload,
    );
  } else {
    // Create a new notification
    final notificationId = notificationIdMap.length;
    notificationIdMap[roomID] = notificationId;
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      groupTitle,
      unReadMessages.length == 1
          ? unReadMessages.first
          : 'New messages from $groupTitle',
      platformChannelSpecifics,
      payload: payload,
    );

  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
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

Future onSelectNotification(String? payLoadData) async {
  if (payLoadData != null) {
    dynamic payload = await json.decode(payLoadData);
    if (payload['roomId'] != null) {
      ChatRoomModel? chatRoomModel =
          await CommonMethod.getChatRoomModelById(payload['roomId']);
      UserModel? targetUser =
          new UserModel.fromMap(json.decode(payload['user']));

      if (chatRoomModel != null && targetUser != null) {
        Get.to(() =>
            ChatRoomScreen(chatRoom: chatRoomModel, targetUser: targetUser));
      }
    }
  }
  print("----onSelectNotification----$payLoadData");
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
