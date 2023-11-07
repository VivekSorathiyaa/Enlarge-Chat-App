import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/chat_room_model.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';

class HomeController extends GetxController {
  final RxList<ChatRoomModel> chatRooms = RxList<ChatRoomModel>([]);
  StreamSubscription<QuerySnapshot>? chatRoomsStream;

 


  Future<void> refreshPage() async {
    CommonMethod.refreshToken();
    CommonMethod.setOnlineStatus();
    chatRoomsStream = FirebaseFirestore.instance
        .collection("chatrooms")
        .snapshots()
        .listen((querySnapshot) {
      chatRooms.assignAll(querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final users = data['usersIds'] as List<dynamic>;
        if (users.any((uId) => uId == AppPreferences.getUiId())) {
          return ChatRoomModel.fromMap(data);
        }
        return null;
      }).whereType<ChatRoomModel>());
      // chatRooms.refresh();
    });
  }
}
