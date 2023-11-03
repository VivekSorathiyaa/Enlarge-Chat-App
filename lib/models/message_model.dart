import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? chatRoomId;
  String? sender;
  String? text;
  String? media; // Change the type to List<dynamic>
  bool? seen;
  int? messageType;
  DateTime? createdAt;

  MessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.sender,
    required this.text,
    required this.seen,
    required this.createdAt,
    required this.messageType,
    required this.media,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    chatRoomId = map["chatRoomId"];
    sender = map["sender"];
    text = map["text"];
    media = map["media"]; // Convert to List<dynamic>
    seen = map["seen"];
    messageType = map["messageType"] ?? 0;
    createdAt = (map["createdAt"] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "chatRoomId": chatRoomId,
      "sender": sender,
      "text": text,
      "media": media,
      "messageType": messageType,
      "seen": seen,
      "createdAt": createdAt,
    };
  }
}
