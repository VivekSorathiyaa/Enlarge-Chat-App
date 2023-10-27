
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppPreferences {
  static final String _keyUid = '_keyUid';
  static final String _keyFullName = '_keyFullName';
  static final String _keyPhone = '_keyPhone';
  static final String _keyProfilePic = '_keyProfilePic';
  static final String _keyFcmToken = '_keyFcmToken';
  static final String _keyLocal = '_keyLocal';
  static final String _languageKey = '_languageKey';
  static final String _countryCodeKey = '_countryCodeKey';
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

  static String? getFcmToken() {
    return _prefs!.getString(_keyFcmToken);
  }

  Locale? getLocaleFromPreferences() {
    final languageCode = _prefs!.getString(_languageKey);
    final countryCode = _prefs!.getString(_countryCodeKey);
    if (languageCode != null && countryCode != null) {
      return Locale(languageCode, countryCode);
    } else {
      return Locale('en', 'US');
    }
  }
  

  static Future<void> setLocal(Locale locale) async {
    await _prefs!.setString(_languageKey, locale.languageCode);
    await _prefs!.setString(_countryCodeKey, locale.countryCode!);
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
}
