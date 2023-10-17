import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
 String? media; // Change the type to List<dynamic>
  bool? seen;
  int? messageType;
  DateTime? createdon;

  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.createdon,
    this.messageType,
    this.media,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    media = map["media"] ; // Convert to List<dynamic>
    seen = map["seen"];
    messageType = map["messageType"] ?? 0;
    createdon = (map["createdon"] as Timestamp).toDate();    
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "media": media,
      "messageType": messageType,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
