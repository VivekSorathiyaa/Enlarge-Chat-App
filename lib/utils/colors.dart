import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF000000);
const Color greyColor = Color(0xff6A6E83);
const Color appBackgroundColor = Color(0xffF9F9FB);
const Color redColor = Color(0xffF34336);
const Color primaryBlack = Color(0xFF000000);
const Color primaryWhite = Color(0xFFFFFFFF);
const Color hintTextColor = Color(0xff9CA3AF);
const Color greenColor = Color(0xff14C25A);
const Color greyBorderColor = Color(0xffD1D5DB);
// const Color appBarColor = Color(0xffD9D9D9);
const Color appBarTitleColor = Color(0xFFFFFFFF);
const Color appBarIconColor = Color(0xFFFFFFFF);
const Color greyContainerColor = Color(0xffEBEBEB);
const Color lightGreyColor = Color(0xffF5F5F5);

const Color darkBlueColor=Color(0xFF004294);
const Color lightYellowColor = Color(0xfff8f38d);
const Color lightRedColor = Color(0xffff6961);
const Color lightOrangeColor = Color(0xffffb480);
const Color lightGreenColor = Color(0xff42d6a4);
const Color lightNeonColor = Color(0xff08cad1);
const Color lightBlueColor = Color(0xff59adf6);
const Color lightPurpleColor = Color(0xff9d94ff);
const Color lightPinkColor = Color(0xffc780e8);
const blackThemeColor=Color(0xFF2E2E2E);



MaterialColor createMaterialColor(Color color) {
  List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  Map<int, Color> swatch = <int, Color>{};
  final int primary = color.value;
  for (int index = 0; index < strengths.length; index++) {
    final int weight = strengths[index];
    final double blend = 1 - (index / 10);
    final int finalColor = primary;
    swatch[weight] = Color(finalColor);
  }
  return MaterialColor(color.value, swatch);
}
