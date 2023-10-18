import 'dart:async';
import 'dart:io';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
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

    if (userModel.fcmtoken != null) {
      await AppPreferences.setFcmToken(userModel.fcmtoken!);
    }
  }

  static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    return result.docs.isNotEmpty;
  }

  static String formatDateToTime(DateTime dateTime) {
    var formatter = DateFormat.jm(); // 'jm' format for 12-hour time with AM/PM
    return formatter.format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat.jm().format(dateTime); // Format time as "10:30 AM/PM"
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy')
          .format(dateTime); // Format date as "14/10/2023"
    }
  }

  static String getFileNameFromUrl(String url) {
  List<String> urlSegments = url.split('/');
  String fileName = urlSegments.last;
  return Uri.decodeFull(fileName);
}

 static Future<String> generateThumbnail(String url) async {
    Completer<String> comp = Completer();
    final String name = url.split("/").last.split(".").first;
    if (name.contains(' ')) {
      String thumbnailPath = await genThumbnailFile(url);
      return thumbnailPath;
    } else {
      String path = "${(await getTemporaryDirectory()).path}/$name.jpg";
      if (File(path).existsSync()) {
        return path;
      }
      final ffex = await FFmpegKit.executeAsync(
        '-i $url -ss 00:00:01.000 -vframes 1 -y $path',
        (session) async {
          if ((await session.getReturnCode())!.getValue() == 0) {
            comp.complete(path);
          }
        },
      );

      ffex.getCompleteCallback();
      return comp.future;
    }
  }

 static Future<String> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
    );
    return fileName!;
  }

}
