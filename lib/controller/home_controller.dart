import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_room_model.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';

class HomeController extends GetxController {
  final currentUserId = RxString('');
  // final chatRooms = RxList<ChatRoomModel>([]);
  final RxList<ChatRoomModel> chatRooms = RxList<ChatRoomModel>([]);
  StreamSubscription<QuerySnapshot>? chatRoomsStream;


  @override
  void onInit() {
    super.onInit();
    refreshPage();
    chatRoomsStream = FirebaseFirestore.instance
        .collection("chatrooms")
        .snapshots()
        .listen((querySnapshot) {
      chatRooms.assignAll(querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatRoomModel.fromMap(data);
      }).toList());
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    chatRoomsStream?.cancel();

    super.onClose();
  }

  Future<void> refreshPage() async {
    currentUserId.value = (await AppPreferences.getUiId()) ?? ''; // Handle null
    CommonMethod.setOnlineStatus();

    await CommonMethod.refreshToken();
  }

  // Future<void> loadChatRooms() async {
  //     final chatRooms = RxList<ChatRoomModel>([]);

  //   final snapshot =
  //       await FirebaseFirestore.instance.collection("chatrooms").get();
  //   chatRooms.assignAll(snapshot.docs.map((doc) {
  //     final data = doc.data() as Map<String, dynamic>;
  //     return ChatRoomModel.fromMap(data);
  //   }).toList());
  // }
}
