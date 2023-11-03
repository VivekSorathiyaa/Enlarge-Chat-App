
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatRoomId;
  String? lastMessage;
  String? groupName;
  String? groupImage;
  String? createdBy;
  bool? isGroup;
  DateTime? lastSeen;
  List<String>? usersIds;

  ChatRoomModel({
    required this.chatRoomId,
    required this.lastMessage,
    required this.usersIds,
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
    isGroup = map["isGroup"] == null ? false : map["isGroup"];
    usersIds =
        map['usersIds'] == null
        ? null
        : List<String>.from(map['usersIds']);

    lastSeen = map["lastSeen"] == null
        ? DateTime.now()
        : (map["lastSeen"] as Timestamp).toDate().toLocal();


  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "groupName": groupName,
      "createdBy": createdBy,
      "isGroup": isGroup,
      "groupImage": groupImage,
      "lastMessage": lastMessage,
      "usersIds": usersIds == null ? null : usersIds!.map((e) => e).toList(),
      "lastSeen": lastSeen == null ? null : lastSeen!.toUtc(),

    };
  }
}
