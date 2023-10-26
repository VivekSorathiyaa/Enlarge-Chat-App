import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../componet/custom_dialog.dart';
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

  Future sendMessage(
      {required ChatRoomModel chatRoom}) async {
    CommonMethod.setOnlineStatus();

    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "" || mediaUrl != null) {
      MessageModel newMessage = MessageModel(
          sender: AppPreferences.getUiId(),
          text: msg,
          messageType: selectedFile != null
              ? GetUtils.isImage(selectedFile!.path)
                  ? 1
                  : GetUtils.isVideo(selectedFile!.path)
                      ? 2
                      : GetUtils.isAudio(selectedFile!.path)
                          ? 3
                          : 0
              : 0,
          media: mediaUrl,
          seen: false,
          chatRoomId: chatRoom.chatRoomId,
          createdAt: DateTime.now(),
          messageId: uuid.v1());
      await CommonMethod.addMessage(newMessage);
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
          UserModel? userStatus =
              await CommonMethod.getUserModelById(userId);
          if (userStatus != null &&userStatus.fcmToken != null && (userStatus.openRoomId == null) ||
              (userStatus!.openRoomId != chatRoom.chatRoomId)) {
                deviceTokenList.add(userStatus.fcmToken!);}
        }
      }
      if(deviceTokenList.isNotEmpty){
          await sendNotification(
            deviceTokens: deviceTokenList,
            textMessage: lastMessage,
            title: AppPreferences.getFullName() ?? 'Unknown',
          );
      }

      
      clearForm();
      log("Message Sent!");
    }
  }


  Future<void> sendNotification(
      {required List<String> deviceTokens,
      required String title,
      required String textMessage}) async {
    final serverKey =
        'AAAAJj823eM:APA91bGYdfLlg9MJSVrJdk7gVPCtCxvCdT6-_qfa-Qb2sLbbb0tjaBKHs5wSgNq13QyWBUlsjIx4d6uXdR90jgCECZ6-3Mud8kemX2VRq9Jt14h32Iv3jwo9sAnWJq6yP_V9i8PcQw1N'; // Replace with your Firebase project's server key
    final url = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
    final message = {
      'registration_ids': deviceTokens,
      'notification': {
        'title': '$title',
        'body': textMessage,
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(message));
    if (response.statusCode == 200) {
      print('Notification sent successfully to multiple users');
    } else {
      print('Failed to send notification');
    }
}



}
