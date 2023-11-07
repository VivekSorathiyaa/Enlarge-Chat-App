class UserModel {
  String? uid;
  String? fullName;
  String? phone;
  String? profilePic;
  String? fcmToken;
  String? status;
  String? openRoomId;
  String? deviceToken;


  UserModel({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.profilePic,
    required this.fcmToken,
    required this.openRoomId,
    required this.deviceToken,
    this.status,

  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"] ?? 'Unknown'; // Use the null-aware operator
    phone = map["phone"];
    profilePic = map["profilePic"] ??
        'https://i.pravatar.cc/500';
    fcmToken = map["fcmToken"];
    deviceToken = map["deviceToken"];
    status = map["status"];

    openRoomId = map["openRoomId"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "phone": phone,
      "profilePic": profilePic,
      "fcmToken": fcmToken,
      "deviceToken":deviceToken,
      "openRoomId": openRoomId,
      "status": status,

    };
  }
}
