class UserModel {
  String? uid;
  String? fullname;
  String? phone;
  String? profilepic;
  String? fcmtoken;
  List<dynamic>? active;
  String? status;

  UserModel({
    required this.uid,
    required this.fullname,
    required this.phone,
    required this.profilepic,
    required this.fcmtoken,
    required this.active, // Make the 'active' parameter optional
    this.status, // Make the 'active' parameter optional
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"] ?? 'Unknown'; // Use the null-aware operator
    phone = map["phone"];
    profilepic = map["profilepic"] ??
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60';
    fcmtoken = map["fcmtoken"];
    status = map["status"];
    active = map["active"] == null
        ? null
        : (map["active"] as List<dynamic>?) ??
            null; // Ensure 'active' is a list
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "phone": phone,
      "profilepic": profilepic,
      "fcmtoken": fcmtoken,
      "active": active,
      "status": status,
    };
  }
}
