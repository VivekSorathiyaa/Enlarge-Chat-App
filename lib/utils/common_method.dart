import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'colors.dart';

class CommonMethod {
  static getXSnackBar(String title, String message, Color? color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: primaryWhite,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      duration: const Duration(seconds: 2),
      borderRadius: 10,
      barBlur: 10,
    );
  }


  static Future<File?> pickFile() async {
    List<File> files = [];
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      files = await result.paths.map((path) => File(path!)).toList();
      return files.first;
    } else {
      return null;
    }
  }
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if(docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
  static Future saveUserData(UserModel userModel) async {
    if (userModel.uid != null) {
      await AppPreferences.setUid(userModel.uid!);
    }
    if (userModel.fullname != null) {
      await AppPreferences.setFullName(userModel.fullname!);
    }
    if (userModel.phone != null) {
      await AppPreferences.setPhone(userModel.phone!);
    }
    if (userModel.profilepic != null) {
      await AppPreferences.setProfilePic(userModel.profilepic!);
    }
  }

 static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
  final QuerySnapshot result = await FirebaseFirestore.instance
      .collection('users')
      .where('phone', isEqualTo: phoneNumber)
      .get();

  return result.docs.isNotEmpty;
}


  static  String formatDateToTime(DateTime dateTime) {
  var formatter = DateFormat.jm(); // 'jm' format for 12-hour time with AM/PM
  return formatter.format(dateTime);
}
static String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();

  if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
    return DateFormat.jm().format(dateTime); // Format time as "10:30 AM/PM"
  } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
    return "Yesterday";
  } else {
    return DateFormat('dd/MM/yyyy').format(dateTime); // Format date as "14/10/2023"
  }
}
}
