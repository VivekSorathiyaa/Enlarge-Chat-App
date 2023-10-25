// ignore_for_file: must_be_immutable



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../utils/colors.dart';

class ShadowContainerWidget extends StatelessWidget {
  final Widget widget;
  double? padding;
  double? radius;
  BorderRadiusGeometry? customRadius;
  double? blurRadius;
  Color? shadowColor;
  Color? borderColor;
  Color? color;

  ShadowContainerWidget(
      {Key? key,
      required this.widget,
      this.padding,
      this.radius,
      this.blurRadius,
      this.customRadius,
      this.borderColor,
      this.shadowColor,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =Get.put(ThemeController());
    return Container(
        padding: EdgeInsets.all(padding ?? 15.0),
        decoration: BoxDecoration(
          color: color ?? (themeController.isDark.value ? primaryBlack : primaryWhite),

          boxShadow: [
            BoxShadow(
              blurRadius: blurRadius ?? 9,
              // spreadRadius: 1,
              color: shadowColor ??  (themeController.isDark.value ? blackThemeColor : greyBorderColor.withOpacity(.5)),
            ),
          ],
          borderRadius: customRadius ?? BorderRadius.circular(radius ?? 8),
          border: Border.all(color: borderColor ?? (themeController.isDark.value ? primaryBlack : greyBorderColor.withOpacity(.5)),width: 1),

        ),
        child: widget);
  }
}
