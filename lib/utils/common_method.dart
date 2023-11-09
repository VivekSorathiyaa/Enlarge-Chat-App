import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/app_constants.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/view/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';

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

  // static Future<File?> pickFile() async {
  //   List<File> files = [];
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (result != null) {
  //     files = await result.paths.map((path) => File(path!)).toList();
  //     return files.first;
  //   } else {
  //     return null;
  //   }
  // }
  static Future<File?> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      if (result.files.isNotEmpty) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          File pickedFile = File(filePath);
          if (CommonMethod.detectFileType(filePath) == 'image') {
            // If the selected file is an image, open the crop image screen
            final croppedImage = await CommonMethod().cropImage(filePath);
            return croppedImage;
          } else {
            return pickedFile;
          }
        }
      }
    } else {
      return null;
    }
  }

  static Future logoutUser() async {
    await FirebaseAuth.instance.signOut();
    AppPreferences.clear();
    Get.offAll(() => LoginScreen());
  }

  Future<File?> cropImage(String imagePath) async {
    ImageCropper imageCropper = ImageCropper();
    final croppedFile = await imageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    return File(croppedFile!.path);
  }

  static Future refreshToken() async {
    FirebaseMessaging.instance.getToken().then((token) async {
      if (token != null) {
        await AppPreferences.setFcmToken(token);

        String? currentUserId = await AppPreferences.getUiId();
        if (currentUserId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .update({'fcmToken': token}).then((value) {
            print("Fcm updated!");
          });
        }
      }
      print('FCM Token: $token');
    });
  }

  static Future refreshDeviceToken() async {
    FirebaseMessaging.instance.getToken().then((token) async {
      if (token != null) {
        await AppPreferences.setFcmToken(token);

        String? currentUserId = await AppPreferences.getUiId();
        if (currentUserId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .update({'fcmToken': token}).then((value) {
            print("Fcm updated!");
          });
        }
      }
      print('FCM Token: $token');
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

  static Future updateChatActiveStatus(String? openRoomId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'openRoomId': openRoomId}).then((value) {});
  }

  static Future setOnlineStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'status': 'online'}).then((value) {
      log("Set Status Online!");
    });
  }

  static Future<UserModel> getCurrentUser() async {
    UserModel currentUser = UserModel(
        openRoomId: null,
        fcmToken: AppPreferences.getFcmToken(),
        fullName: AppPreferences.getFullName(),
        phone: AppPreferences.getPhone(),
        profilePic: AppPreferences.getProfilePic(),
        uid: AppPreferences.getUiId(),
        deviceToken: '');

    currentUser =
        await CommonMethod.getUserModelById(AppPreferences.getUiId()!) ??
            currentUser;

    return currentUser;
  }

  static Future setOfflineStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AppPreferences.getUiId())
        .update({'status': 'offline'}).then((value) {
      updateChatActiveStatus(null);
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

  static Future<String> getLastMessage(
      int messageType, String msg, ChatRoomModel chatRoom) async {
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
    return ((chatRoom.isGroup!
            ? "${AppPreferences.getFullName().toString()}: "
            : "") +
        message);
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

  static Future<void> updateMessage(MessageModel message) async {
    try {
      final messageCollection =
          FirebaseFirestore.instance.collection('messages');

      // Update the message document with the new data
      await messageCollection.doc(message.messageId).update({
        'text': message.text,
        'media': message.media,
        'seen': message.seen,

        // Add other properties you want to update
      });
    } catch (e) {
      print('Error updating message: $e');
    }
  }

  static Future<bool> checkIfMessageIsSeenByTargetUser(
      String messageId, String targetUserId) async {
    try {
      final messageCollection =
          FirebaseFirestore.instance.collection('chatrooms');

      // Query for the message with the specified ID in the chat room.
      final messageDoc = await messageCollection
          .doc(targetUserId) // Replace with the chat room ID
          .collection('messages')
          .doc(messageId)
          .get();

      // Check if the message document exists.
      if (messageDoc.exists) {
        final messageData = messageDoc.data() as Map<String, dynamic>;

        // Check if the message has a "seen" property.
        if (messageData['seen'] != null) {
          // Check if the target user has seen the message.
          if (messageData['seen'][targetUserId] == true) {
            return true; // The message is seen by the target user.
          }
        }
      }
    } catch (e) {
      print('Error checking if message is seen: $e');
    }

    return false; // The message is not seen by the target user or there was an error.
  }

  static Future<void> sendNotification(
      {required List<String> deviceTokens,
      required String title,
      required String roomId,
      required String type,
      required String body}) async {
    var currentUser = await getCurrentUser();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=${AppConstants.firebaseServerKey}',
    };
    final message = {
      'registration_ids': deviceTokens,
      'data': {
        'title': title,
        'body': body,
        'type': type,
        'user': currentUser.toMap(),
        'roomId': roomId,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
    final response = await http.post(Uri.parse(AppConstants.fcmGoogleApiUrl),
        headers: headers, body: json.encode(message));

    print('----response----${response.body.toString()}');
    if (response.statusCode == 200) {
      print('Notification sent successfully to multiple users');
    } else {
      print('Failed to send notification');
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

  static Future<ChatRoomModel?> getChatRoomModelById(String roomId) async {
    ChatRoomModel? chatRoomModel;
    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(roomId)
        .get();
    if (docSnap.data() != null) {
      chatRoomModel =
          ChatRoomModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return chatRoomModel;
  }

  static Future<List<String>> retrieveMessagesWithSeenStatusFalse(
    String chatRoomId,
  ) async {
    try {
      final messageCollection = FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("messages");

      final querySnapshot =
          await messageCollection.where('seen', isEqualTo: false).get();

      final List<String> messageIds = [];

      for (final messageDoc in querySnapshot.docs) {
        messageIds.add(messageDoc.id);
      }
      return messageIds;
    } catch (e) {
      print('Error retrieving messages with seen status false: $e');
      return [];
    }
  }

  static Future<void> updateMessagesToSeenStatusTrue(
      String chatRoomId, List<String> messageIds, String currentUserId) async {
    try {
      final messageCollection = FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("messages");

      for (final messageId in messageIds) {
        final messageDoc = await messageCollection.doc(messageId).get();
        final messageData = messageDoc.data() as Map<String, dynamic>;

        // Check if the message sender is not the current user
        if (messageData['sender'] != currentUserId) {
          await messageCollection.doc(messageId).update({'seen': true});
        }
      }
    } catch (e) {
      print('Error updating message seen status to true: $e');
    }
  }

static Future<List<MessageModel>> fetchUnreadMessages(String roomID) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(roomID)
      .collection("messages")
      .orderBy("createdAt", descending: true)
      .get(); // Use get() instead of snapshots() to wait for the query to complete
  final newMessages = querySnapshot.docs.map((doc) {
    return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
  }).toList();
  final messages = <MessageModel>[];
  for (final message in newMessages) {
    if (message.chatRoomId == roomID &&
          message.sender != await AppPreferences.getUiId() &&
        message.seen == false) {
      messages.add(message);
    }
  }
  return messages;
}

static Stream<List<MessageModel>> unreadMessagesStream(String roomID) async* {
  final querySnapshot = await FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(roomID)
      .collection("messages")
      .orderBy("createdAt", descending: true)
      .snapshots();

  await for (QuerySnapshot snapshot in querySnapshot) {
    final newMessages = snapshot.docs.map((doc) {
      return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    
    final uiId = await AppPreferences.getUiId();
    final messages = newMessages.where((message) =>
        message.chatRoomId == roomID &&
        message.sender != uiId &&
        message.seen ==false).toList();

    yield messages;
  }
}

// static StreamController<List<MessageModel>> unreadMessagesStreamController =
//       StreamController<List<MessageModel>>.broadcast();

//   static Stream<List<MessageModel>> get unreadMessagesStream =>
//       unreadMessagesStreamController.stream;
//   static Future<List<MessageModel>> fetchUnreadMessages(String roomID) async {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(roomID)
//         .collection("messages")
//         .orderBy("createdAt", descending: true)
//         .get();

//     final newMessages = querySnapshot.docs.map((doc) {
//       return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
//     }).toList();

//     final messages = <MessageModel>[];
//     final uiId = await AppPreferences.getUiId();

//     for (final message in newMessages) {
//       if (message.chatRoomId == roomID &&
//           message.sender != uiId &&
//           message.seen == false) {
//         messages.add(message);
//       }
//     }
//     // Add the new unread messages to the stream
//     unreadMessagesStreamController.add(messages);
//     return messages;
//   }



  static Future<List<String>> getMessageLines(
      {required List<MessageModel> unReadMessages,
      required ChatRoomModel chatRoomModel}) async {
    List<String> lines = [];
    for (var message in unReadMessages) {
      UserModel? senderUser =
          await CommonMethod.getUserModelById(message.sender!);
      String line = (chatRoomModel.isGroup! && senderUser != null
              ? "${senderUser.fullName}: "
              : "") +
          message.text.toString();

      lines.add(line);
    }
    return lines;
  }

  static Future<ChatRoomModel?> getChatRoomModel(
      List<String> targetUserIds) async {
    final List<QuerySnapshot> userSnapshots =
        await Future.wait(targetUserIds.map((userId) {
      return FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: userId)
          .get();
    }));
    if (userSnapshots.every((snapshot) => snapshot.docs.isNotEmpty)) {
      // final userMap = userSnapshots
      //     .map((snapshot) => UserModel.fromMap(
      //         snapshot.docs.first.data() as Map<String, dynamic>))
      //       .toList();
      final chatRoomSnapshot = await FirebaseFirestore.instance
          .collection("chatrooms")
          .where('usersIds', isEqualTo: targetUserIds.map((e) => e).toList())
          //  userMap.map((user) => user.toMap()).toList())
          .get();

      if (chatRoomSnapshot.docs.isNotEmpty) {
        final chatRoomData =
            chatRoomSnapshot.docs.first.data() as Map<String, dynamic>;
        return ChatRoomModel.fromMap(chatRoomData);
      } else {
        final newChatroom = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: null,
          lastSeen: null,
          usersIds: targetUserIds,
          groupName: null,
          isGroup: false,
          createdBy: AppPreferences.getUiId(),
          groupImage: null,
        );
        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(newChatroom.chatRoomId!)
            .set(newChatroom.toMap());
        return newChatroom;
      }
    } else {
      return null;
    }
  }

  static Future<String?> uploadFile(
      BuildContext context, File selectedFile) async {
    String? imageUrl;
    CustomDialog.showLoadingDialog(context, "Uploading...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("media")
        .child(uuid.v1())
        .putFile(selectedFile!);
    TaskSnapshot snapshot = await uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL();
    Get.back();
    return imageUrl;
  }

  static String detectFileType(String filePath) {
    print('----filePath----$filePath');
    // Get the file extension from the filePath
    String fileExtension = filePath.split('.').last.toLowerCase();

    // Define a list of common video and audio file extensions
    List<String> videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv'];
    List<String> audioExtensions = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'];

    // Check the file extension to determine the file type
    if (videoExtensions.contains(fileExtension)) {
      return 'video';
    } else if (audioExtensions.contains(fileExtension)) {
      return 'audio';
    } else if (fileExtension == 'jpg' ||
        fileExtension == 'png' ||
        fileExtension == 'gif'||fileExtension == 'jpeg') {
      return 'image';
    } else if (fileExtension == 'pdf') {
      return 'pdf';
    } else if (fileExtension == 'doc' ||
        fileExtension == 'docx' ||
        fileExtension == 'txt') {
      return 'document';
    } else {
      return 'Unknown'; // Unknown file type
    }
  }

  static DateTime currentUtcTime(String utcTime) {
    DateTime utcDateTime = DateTime.parse(utcTime.toString()).toUtc().toLocal();
    String formattedDateTime = utcDateTime.toString();
    return DateTime.parse(formattedDateTime);
  }

  static Future<String> getMembersName(List<String> usersIds) async {
    List<UserModel> users = [];
    for (String userId in usersIds) {
      UserModel? user = await getUserModelById(userId);
      if (user != null) {
        users.add(user);
      }
    }

    users
        .sort((a, b) => a.fullName.toString().compareTo(b.fullName.toString()));

    List<String> names = users.map((user) {
      if (user.uid == AppPreferences.getUiId()) {
        return "You";
      }
      return user.fullName.toString();
    }).toList();

    String concatenatedNames = names.join(', ');
    return concatenatedNames;
  }

  static Future<ChatRoomModel?> createGroup(
      {required String groupName,
      required List<String>? usersIds,
      required String? groupImage}) async {
    final newChatroom = ChatRoomModel(
      chatRoomId: uuid.v1(),
      lastMessage: null,
      lastSeen: null,
      usersIds: usersIds,
      groupName: groupName,
      isGroup: true,
      createdBy: AppPreferences.getUiId(),
      groupImage: groupImage,
    );
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(newChatroom.chatRoomId!)
        .set(newChatroom.toMap());
    return newChatroom;
  }

  static Future<UserModel?> getTargetUserModel(List<String> usersIds) async {
    for (var uid in usersIds) {
      if (uid != AppPreferences.getUiId()!) {
        return await getUserModelById(uid);
      }
    }
    return null;
  }

  static Future<List<UserModel>> getUserListByIds(List<String> usersIds) async {
    List<UserModel> list = [];
    for (var uid in usersIds) {
      var data = await getUserModelById(uid);
      list.add(data!);
    }
    return list;
  }

  static Future saveUserData(UserModel userModel) async {
    if (userModel.uid != null) {
      await AppPreferences.setUid(userModel.uid!);
    }
    if (userModel.fullName != null) {
      await AppPreferences.setFullName(userModel.fullName!);
    }
    if (userModel.phone != null) {
      await AppPreferences.setPhone(userModel.phone!);
    }
    if (userModel.profilePic != null) {
      await AppPreferences.setProfilePic(userModel.profilePic!);
    }

    if (userModel.fcmToken != null) {
      await AppPreferences.setFcmToken(userModel.fcmToken!);
    }
  }

  static Future<bool> checkDeviceTokenChange(
      String uid, String newDeviceToken) async {
    // Query your database to retrieve the user's current device token
    // This can vary depending on your database structure (Firestore, Realtime Database, etc.)

    // For example, if you are using Firestore, you can do something like this:
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final currentDeviceToken = userDoc.data()?['deviceToken'];

        // Compare the current device token with the new device token
        return currentDeviceToken != newDeviceToken;
      }
    } catch (e) {
      // Handle any potential database errors
      print('Error checking device token change: $e');
    }

    // Return true by default if there was an error or the user doesn't exist in the database
    return true;
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

  Future<String> getDeviceToken() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceToken = '';

    // Get the device information
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceToken = androidInfo.id; // This is the device token for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceToken =
          iosInfo.identifierForVendor!; // This is the device token for iOS
    }

    return deviceToken;
  }


 static Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      log('chatroom id:$chatRoomId');
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .delete();

      await FirebaseFirestore.instance
          .collection('chatMessages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });


    } catch (e) {
      log('========================Error deleting chat room: $e');
      // Handle any error that occurs during deletion.
    }
  }


 static Future  <void> deleteChatroom(String chatroomId) async {
    // Initialize Firebase if not already initialized
    await Firebase.initializeApp();

    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Reference to the chatroom document you want to delete
      DocumentReference chatroomRef = firestore.collection('chatrooms').doc(chatroomId);

      // Delete the chatroom document
      await chatroomRef.delete();

      await FirebaseFirestore.instance
          .collection('chatMessages')
          .where('chatRoomId', isEqualTo: chatroomId)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });

      print('Chatroom with ID $chatroomId deleted successfully.');
    } catch (e) {
      print('Error deleting chatroom: $e');
    }
  }

}
