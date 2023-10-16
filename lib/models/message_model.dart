import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  List<dynamic>? mediaList; // Change the type to List<dynamic>
  bool? seen;
  DateTime? createdon;

  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.createdon,
    this.mediaList,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    mediaList = map["mediaList"] == null
        ? []
        : List<String>.from(map["mediaList"]); // Convert to List<dynamic>
    seen = map["seen"];
    createdon = (map["createdon"] as Timestamp).toDate();    
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "mediaList": mediaList,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
