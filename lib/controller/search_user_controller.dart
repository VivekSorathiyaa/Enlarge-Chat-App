import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../utils/app_preferences.dart';

class SearchUserController extends GetxController {
    final Rx<TextInputType> keyboardType = TextInputType.text.obs;

  final TextEditingController searchTextController = TextEditingController();
  final searchResults = <UserModel>[].obs;
  final searchResultsStream = StreamController<List<UserModel>>();
  @override
  void onInit() {
    super.onInit();
    searchUsers();
    searchResultsStream.stream.listen((results) {
      searchResults.assignAll(results);
    });
  }

  @override
  void onClose() {
    searchResultsStream.close();
    super.onClose();
  }

  Future<void> searchUsers() async {
    final searchText = searchTextController.text.toLowerCase();
    final phoneQuery = FirebaseFirestore.instance
        .collection("users")
        .where("phone", isNotEqualTo: AppPreferences.getPhone())
        .get();

    phoneQuery.then((phoneSnapshot) {
      final searchedUserList = <UserModel>[];
      for (final QueryDocumentSnapshot doc in phoneSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final userPhone = userData['phone'].toString().toLowerCase();
        final userFullname = userData['fullname'].toString().toLowerCase();
        if (userPhone.contains(searchText) ||
            userFullname.contains(searchText)) {
          final searchedUser = UserModel.fromMap(userData);
          searchedUserList.add(searchedUser);
        }
      }

      searchResultsStream.add(searchedUserList);
    });
  }

}
