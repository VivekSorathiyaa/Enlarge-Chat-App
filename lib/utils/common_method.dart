import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../componet/custom_dialog.dart';
import '../main.dart';
import '../models/chat_room_model.dart';
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

  

  static Future refreshToken() async {
    firebaseMessaging.getToken().then((token) async {
      if (token != null) {
        await AppPreferences.setFcmToken(token);
        String? currentUserId = await AppPreferences.getUiId();
        if (currentUserId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .update({'fcmtoken': token}).then((value) {
            log("Fcm updated!");
          });
        }
      }
      log('FCM Token: $token');
    });
  }

  static Future updateUserOnlineStatus(bool status) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'online': status}).then((value) {
      log("Fcm updated!");
    });
  }

  static Future updateChatActiveStatus(List<String>? userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'active': userId}).then((value) {
      log("Fcm updated!");
    });
  }

  static Future setOnlineStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'status': 'online'}).then((value) {
      log("Set Status Online!");
    });
  }

  static Future setOfflineStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'status': 'offline'}).then((value) {
      log("Set Status Offline!");
    });
  }

  static Future setTypingStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'status': 'typing'}).then((value) {
      log("Set Status Typing!");
    });
  }

  static Future<void> updateLastMessage({
    required String chatRoomId,
    required String lastMessage,
  }) async {
    final userDocReference =
        FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId);
    await userDocReference.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        // Document exists, update the fields
        userDocReference.update({
          'lastMessage': lastMessage,
          'lastSeen': DateTime.now(),
        }).then((_) {
          log("LastMessage updated! $lastMessage");
        }).catchError((error) {
          log("Error updating lastMessage: $error");
        });
      } else {
        log("User document does not exist.");
      }
    }).catchError((error) {
      log("Error fetching user document: $error");
    });
  }

  static Future<String> getLastMessage(int messageType, String msg) async {
    var message = messageType == 3
        ? ': 🔊 audio'
        : messageType == 2
            ? ' 🎥 video'
            : messageType == 1
                ? "📷 image"
                : messageType == 0
                    ? msg
                    : '*';
    log('--message---$message');
    return message;
  }

  static Future addMessage(MessageModel newMessage) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(newMessage.chatRoomId)
        .collection("messages")
        .doc(newMessage.messageId)
        .set(newMessage.toMap())
        .then((value) => log("Send Message"));
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

static Future<ChatRoomModel?> getChatRoomModel(List<String> targetUserIds) async {
  final List<QuerySnapshot> userSnapshots =
      await Future.wait(targetUserIds.map((userId) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: userId)
        .get();
  }));

  if (userSnapshots.every((snapshot) => snapshot.docs.isNotEmpty)) {
    // All target users exist
    final userMap = userSnapshots
        .map((snapshot) => UserModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>))
        .toList();

    // Query chat rooms with the same set of users
    final chatRoomSnapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where('users', isEqualTo: userMap.map((user) => user.toMap()).toList())
        .get();

    if (chatRoomSnapshot.docs.isNotEmpty) {
      // Chat room already exists, return the first one found
      final chatRoomData =
          chatRoomSnapshot.docs.first.data() as Map<String, dynamic>;
      return ChatRoomModel.fromMap(chatRoomData);
    } else {
      // Create a new chat room
      final newChatroom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: null,
        lastSeen: null,
        users: userMap,
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatRoomId!)
          .set(newChatroom.toMap());

      return newChatroom;
    }
  } else {
    return null; // Some of the target users do not exist
  }
}

  static Future<UserModel?> getTargetUserModel(List<UserModel> users) async {
    for (var data in users) {
      if (data.uid != AppPreferences.getUiId()!) {
        log("==getUserModelById==");
        return await getUserModelById(data.uid!);
      }
    }
    return null;
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