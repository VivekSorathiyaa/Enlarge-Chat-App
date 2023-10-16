import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final String _keyUid = '_keyUid';
  static final String _keyFullName = '_keyFullName';
  static final String _keyPhone = '_keyPhone';  
  static final String _keyProfilePic = '_keyProfilePic';
  static final String _keyFcmToken = '_keyFcmToken';

  static SharedPreferences? _prefs;


  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await getFirebaseMessagingToken();
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
  static String? getFcmToken() {
    return _prefs!.getString(_keyFcmToken);
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

  static Future<void> setFcmToken(String fcmToken) async {
    await _prefs!.setString(_keyFcmToken, fcmToken);
  }

  static Future<void> clear() async {
    await _prefs!.clear();
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {

      setFcmToken(t);
        log('Push Token: $t');
      }
    });



  }
}