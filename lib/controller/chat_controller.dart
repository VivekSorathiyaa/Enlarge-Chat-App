import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/custom_dialog.dart';
import '../main.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../utils/app_preferences.dart';

class ChatController extends GetxController {
  TextEditingController messageController = TextEditingController();
  File? selectedFile;
  String? mediaUrl;

  Future clearForm() async {
    messageController.clear();
    mediaUrl = null;
    selectedFile = null;
  }

  Future sendMessage(ChatRoomModel chatRoomModel) async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "" || mediaUrl != null) {
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: await AppPreferences.getUiId(),
          createdon: DateTime.now(),
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
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomModel.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      chatRoomModel.lastMessage = msg.isEmpty ? 'media' : msg;
      chatRoomModel.lastSeen = DateTime.now();
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomModel.chatroomid)
          .set(chatRoomModel.toMap());
      clearForm();
      log("Message Sent!");
    }
  }

  Future<String?> uploadFile(BuildContext context) async {
    String? imageUrl;
    CustomDialog.showLoadingDialog(context, "Uploading...");
    UploadTask uploadTask =
        FirebaseStorage.instance
        .ref("media")
        .child(uuid.v1())
        .putFile(selectedFile!);
    TaskSnapshot snapshot = await uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL();
Get.back();
    return imageUrl;
   
  }
}
