import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatRoomId;
  String? lastMessage;
  String? groupName;
  String? groupImage;
  String? createdBy;
  bool? isGroup;
  DateTime? lastSeen;
  List<UserModel>? users;

  ChatRoomModel({
    required this.chatRoomId,
    required this.lastMessage,
    required this.users,
    required this.createdBy,
    required this.groupImage,
    required this.lastSeen,
    required this.groupName,
    required this.isGroup,
  });

   ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    lastMessage = map["lastMessage"];
    createdBy = map["createdBy"];
    groupImage = map["groupImage"];
    groupName = map["groupName"];
    isGroup = map["isGroup"]==null ? false: map["isGroup"];
    users = map['users'] == null
        ? null
        : (map['users'] as List<dynamic>)
            .map((userMap) => UserModel.fromMap(userMap))
            .toList();

    lastSeen = map["lastSeen"] == null
        ? DateTime.now()
        : (map["lastSeen"] as Timestamp)
            .toDate()
            .toLocal(); // Convert to local time
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "groupName": groupName,
      "createdBy": createdBy,
      "isGroup": isGroup,
      "groupImage": groupImage,
      "lastMessage": lastMessage,
      "users":
          users == null ? null : users!.map((user) => user.toMap()).toList(),
      "lastSeen":lastSeen ==null ? null:
          lastSeen!.toUtc(), // Convert to UTC time before saving in Firestore
    };
  }
}
