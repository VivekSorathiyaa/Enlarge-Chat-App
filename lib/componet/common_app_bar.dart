import 'package:chatapp/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import 'app_text_style.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? hideLeadingIcon;
List<Widget>? actions;
  CommonAppBar({required this.title, this.actions, this.hideLeadingIcon});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController=Get.put(ThemeController());
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: hideLeadingIcon != null && hideLeadingIcon!
          ? null
          : IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: appBarIconColor,
                size: 20,
              ),
            ),
      title: Text(
        title,
        style: AppTextStyle.normalSemiBold18.copyWith(color: appBarIconColor),
      ),
      centerTitle: true,
      actions: actions,
      backgroundColor:
          themeController.isDark.value ? blackThemeColor : primaryBlack,
      // elevation: 0, // Remove AppBar shadow
    );
  }
}
