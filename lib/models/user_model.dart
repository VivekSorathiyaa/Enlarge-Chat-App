class UserModel {
  String? uid;
  String? fullName;
  String? phone;
  String? profilePic;
  String? fcmToken;
  String? status;
  String? openRoomId;


  UserModel({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.profilePic,
    required this.fcmToken,
    required this.openRoomId,
    this.status,

  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"] ?? 'Unknown'; // Use the null-aware operator
    phone = map["phone"];
    profilePic = map["profilePic"] ??
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60';
    fcmToken = map["fcmToken"];
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
      "openRoomId": openRoomId,
      "status": status,

    };
  }
}
