import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../componet/app_text_style.dart';
import '../utils/colors.dart';
import '../Change Theme/mytheme_preference.dart';

class ThemeController extends GetxController {
  late MyThemePreferences _preferences;


  final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: appBackgroundColor,
    fontFamily: AppTextStyle.fontFamilyInter,
    hintColor: primaryBlack,
    appBarTheme: AppBarTheme(backgroundColor: primaryColor),
    iconTheme: IconThemeData(color: primaryBlack),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColor),
  );

  final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: primaryBlack,
    fontFamily: AppTextStyle.fontFamilyInter,
    appBarTheme: AppBarTheme(backgroundColor: blackThemeColor),
    primarySwatch: createMaterialColor(Colors.white),
    hintColor: primaryWhite,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: blackThemeColor),
    iconTheme: IconThemeData(color: primaryWhite),
  );

  final RxBool isDark = false.obs; // Use the GetX observable for isDark

  @override
  void onInit() {
    super.onInit();
    _preferences = MyThemePreferences();
    getPreferences();
  }

  // Switching the themes
  void toggleTheme(bool value) {
    isDark(value);
    _preferences.setTheme(value);
  }


  void getPreferences() async {
    isDark(await _preferences.getTheme());
  }
}
