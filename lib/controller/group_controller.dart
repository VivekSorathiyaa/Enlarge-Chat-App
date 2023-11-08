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

Rx<UserModel?> currentUser = Rx<UserModel?>(null);


 
  Future getCurrentUser() async {
    final fcmToken = await AppPreferences.getFcmToken();
    final fullName = await AppPreferences.getFullName();
    final phone = await AppPreferences.getPhone();
    final profilePic = await AppPreferences.getProfilePic();
    final uid = await AppPreferences.getUiId();
    final deviceToken = await AppPreferences.getDeviceToken();

    currentUser.value = UserModel(
      openRoomId: null,
      fcmToken: fcmToken,
      fullName: fullName,
      phone: phone,
      profilePic: profilePic,
      uid: uid,
      deviceToken: deviceToken as String,
    );
    currentUser.value =
        await CommonMethod.getUserModelById(await AppPreferences.getUiId()!);
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
    });
  }
}