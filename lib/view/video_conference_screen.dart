import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/app_constants.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

import '../models/message_model.dart';
// Replace with the actual import path if it's different

class VideoConferenceScreen extends StatefulWidget {
  final ChatRoomModel? chatRoomModel;
  final String? chatRoomId;

  const VideoConferenceScreen({
    Key? key,
    required this.chatRoomModel,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<VideoConferenceScreen> createState() => _VideoConferenceScreenState();
}

class _VideoConferenceScreenState extends State<VideoConferenceScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.chatRoomModel != null) {
      sendNotificationForCall();
    }
  }

  List<String> deviceTokenList = [];

  Future sendNotificationForCall() async {
    for (var userId in widget.chatRoomModel!.usersIds!) {
      if (userId != AppPreferences.getUiId()) {
        UserModel? userStatus = await CommonMethod.getUserModelById(userId);
        if (userStatus != null && userStatus.fcmToken != null) {
          deviceTokenList.add(userStatus.fcmToken!);
        }
      }
    }
    print('----deviceTokenList----${deviceTokenList.toString()}');

    await CommonMethod.sendNotification(
      deviceTokens: deviceTokenList,
      body: "${AppPreferences.getFullName()} started video call",
      title: AppPreferences.getFullName() ?? 'Unknown',
      type: 'videoCall',
      roomId: widget.chatRoomModel!.chatRoomId.toString(),
    );

    MessageModel newMessage = MessageModel(
        sender: null,
        text: '🎥 ${AppPreferences.getFullName()} started video call',
        messageType: 0,
        media: null,
        seen: false,
        chatRoomId: widget.chatRoomId,
        createdAt: DateTime.now(),
        messageId: uuid.v1());
    await CommonMethod.addMessage(newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.chatRoomModel == null) {
          Get.off(() => HomeScreen());
        }
        return widget.chatRoomModel != null;
      },
      child: SafeArea(
        child: ZegoUIKitPrebuiltVideoConference(
          appID: AppConstants
              .zegocloudAppID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
          appSign: AppConstants
              .zegocloudAppSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
          userID: AppPreferences.getUiId() ?? '0',
          userName: AppPreferences.getFullName() ?? '0',
          conferenceID: widget.chatRoomId.toString(),
          config: ZegoUIKitPrebuiltVideoConferenceConfig(
              rootNavigator: true,
              onLeave: () async {
                print("--onLeave---");
                if (widget.chatRoomModel == null) {
                  Get.off(() => HomeScreen());
                } else {
                  await CommonMethod.sendNotification(
                    deviceTokens: deviceTokenList,
                    body: "${AppPreferences.getFullName()} ended video call",
                    title: AppPreferences.getFullName() ?? 'Unknown',
                    type: 'videoCallCut',
                    roomId: widget.chatRoomModel!.chatRoomId.toString(),
                  );
                  Get.back();
                }
              }),
        ),
      ),
    );
  }
}
