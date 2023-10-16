import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final String _keyUid = '_keyUid';
  static final String _keyFullName = '_keyFullName';
  static final String _keyPhone = '_keyPhone';  
  static final String _keyProfilePic = '_keyProfilePic';  

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getUiId() {
    return _prefs!.getString(_keyUid);
  }
  static String? getFullName() {
    return _prefs!.getString(_keyFullName);
  }
  static String? getPhone() {
    return _prefs!.getString(_keyPhone);
  }
  static String? getProfilePic() {
    return _prefs!.getString(_keyProfilePic);
  }

  static Future<void> setUid(String uId) async {
    await _prefs!.setString(_keyUid, uId);
  }
  static Future<void> setFullName(String fullname) async {
    await _prefs!.setString(_keyFullName, fullname);
  }
  static Future<void> setPhone(String phone) async {
    await _prefs!.setString(_keyPhone, phone);
  }
  static Future<void> setProfilePic(String profilePic) async {
    await _prefs!.setString(_keyProfilePic, profilePic);
  }

  static Future<void> clear() async {
    await _prefs!.clear();
  }


}
