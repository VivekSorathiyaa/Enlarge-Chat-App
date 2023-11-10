import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? chatRoomId;
  String? sender;
  String? text;
  String? media;
  bool? seen;
  int? messageType;
  DateTime? createdAt;
  MessageModel? replyMessage;

  MessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.sender,
    required this.text,
    required this.seen,
    required this.createdAt,
    required this.messageType,
    required this.media,
    required this.replyMessage,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    chatRoomId = map["chatRoomId"];
    sender = map["sender"];
    media = map["media"];
    text = map["text"];
    seen = map["seen"];
    replyMessage = map["replyMessage"] != null
        ? MessageModel.fromMap(map["replyMessage"])
        : null;
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
      "replyMessage": replyMessage?.toMap(),
      "messageType": messageType,
      "seen": seen,
      "createdAt": createdAt,
    };
  }
}
