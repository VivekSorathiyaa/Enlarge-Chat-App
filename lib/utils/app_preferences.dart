
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppPreferences {
  static final String _keyUid = '_keyUid';
  static final String _keyFullName = '_keyFullName';
  static final String _keyPhone = '_keyPhone';
  static final String _keyProfilePic = '_keyProfilePic';
  static final String _keyFcmToken = '_keyFcmToken';
  static final String _keyDeviceToken='_keyDeviceToken';
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
  // static String? getDeviceToken() {
  //   return _prefs!.getString(_keyDeviceToken);
  // }
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

  // static Future<void> setDeviceToken(String deviceToken) async {
  //   await _prefs!.setString(_keyDeviceToken, deviceToken);
  // }
 static Future<String> getDeviceToken() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceToken = '';

    // Get the device information
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceToken = androidInfo.product; // This is the device token for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceToken = iosInfo.identifierForVendor!; // This is the device token for iOS
    }

    // Save the device token
    await setDeviceToken(deviceToken);

    return deviceToken;
  }

  static Future<void> setDeviceToken(String deviceToken) async {
    await _prefs!.setString(_keyDeviceToken, deviceToken);
  }


  static Future<void> clear() async {
    await _prefs!.clear();
  }


}

