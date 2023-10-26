import 'dart:async';
import 'dart:io';

import 'package:chatapp/utils/common_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../utils/app_preferences.dart';

class GroupController extends GetxController{
  TextEditingController nameTextController = TextEditingController();
  TextEditingController searchTextController = TextEditingController();
  final allUserList = <UserModel>[].obs;
  final selectUserList = <UserModel>[].obs;
  // final usersResultsStream = StreamController<List<UserModel>>();
  Rx<UserModel> currentUser = UserModel(
          openRoomId: null,
          fcmToken: AppPreferences.getFcmToken(),
          fullName: AppPreferences.getFullName(),
          phone: AppPreferences.getPhone(),
          profilePic: AppPreferences.getProfilePic(),
          uid: AppPreferences.getUiId())
      .obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    searchUsers();
    // usersResultsStream.stream.listen((results) {
    //   allUserList.assignAll(results);
    // });
  }
 
  getCurrentUser() async {
    currentUser.value =
        await CommonMethod.getUserModelById(AppPreferences.getUiId()!) ??
            currentUser.value;
  }

  @override
  void onClose() {
    // usersResultsStream.close();
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
        final userFullname = userData['fullName'].toString().toLowerCase();
        if (userPhone.contains(searchText) ||
            userFullname.contains(searchText)) {
          final searchedUser = UserModel.fromMap(userData);
          searchedUserList.add(searchedUser);
        }
      }
            allUserList.assignAll(searchedUserList);


      // usersResultsStream.add(searchedUserList);
    });
  }
}