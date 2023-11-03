import 'dart:developer';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../utils/app_preferences.dart';

class ChatController extends GetxController {
  TextEditingController messageController = TextEditingController();
  File? selectedFile;
  String? mediaUrl;
  final RxList<MessageModel> messages = <MessageModel>[].obs;


  void updateMessages(List<MessageModel> newMessages) {
    messages.assignAll(newMessages);
  }

  Future clearForm() async {
    messageController.clear();
    mediaUrl = null;
    selectedFile = null;
  }

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  playMessageSentSound() {
    // assetsAudioPlayer.open(
    //   Audio("assets/audio/sent_message.mp3"),
    // );
    // log('----------------------------play sound');
  }

  playMessageReceiveSound() {
    // assetsAudioPlayer.open(
    //   Audio("assets/audio/receive_message.mp3"),
    // );
    // log('----------------------------recieve sound');
  }

  Future sendMessage({required ChatRoomModel chatRoom}) async {
    CommonMethod.setOnlineStatus();

    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "" || mediaUrl != null) {
      MessageModel newMessage = MessageModel(
          sender: AppPreferences.getUiId(),
          text: msg,
          messageType: selectedFile != null
              ? CommonMethod.detectFileType(selectedFile!.path) == 'image'
                  ? 1
                  : CommonMethod.detectFileType(selectedFile!.path) == 'video'
                      ? 2
                      : CommonMethod.detectFileType(selectedFile!.path) ==
                              'audio'
                          ? 3
                          : 0
              : 0,
          media: mediaUrl,
          seen: false,
          chatRoomId: chatRoom.chatRoomId,
          createdAt: DateTime.now(),
          messageId: uuid.v1());
      await CommonMethod.addMessage(newMessage);
      playMessageSentSound();
      var lastMessage =
          await CommonMethod.getLastMessage(newMessage.messageType ?? 0, msg);
      CommonMethod.updateLastMessage(
          chatRoomId: chatRoom.chatRoomId!,
          lastMessage: (chatRoom.isGroup!
                  ? "${AppPreferences.getFullName().toString()}: "
                  : "") +
              lastMessage);
      List<String> deviceTokenList = [];
      for (var userId in chatRoom.usersIds!) {
        if (userId != AppPreferences.getUiId()) {
          UserModel? userStatus = await CommonMethod.getUserModelById(userId);
          if (userStatus != null &&
                  userStatus.fcmToken != null &&
                  (userStatus.openRoomId == null) ||
              (userStatus!.openRoomId != chatRoom.chatRoomId)) {
            deviceTokenList.add(userStatus.fcmToken!);
          }
        }
      }
      if (deviceTokenList.isNotEmpty) {
        await CommonMethod.sendNotification(
          deviceTokens: deviceTokenList,
          body: lastMessage,
          title: AppPreferences.getFullName() ?? 'Unknown',
          type: 'message',
          roomId: chatRoom.chatRoomId.toString(),
        );
      }
      clearForm();
      log("Message Sent!");
    }
  }

  
}
