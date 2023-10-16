class UserModel {
  String? uid;
  String? fullname;
  String? phone;
  String? profilepic;

  UserModel({required this.uid,required this.fullname,required this.phone,required this.profilepic});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    phone = map["phone"];
    profilepic = map["profilepic"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "phone": phone,
      "profilepic": profilepic,
    };
  }
}