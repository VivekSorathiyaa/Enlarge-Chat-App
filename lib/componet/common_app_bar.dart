import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import 'app_text_style.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actionWidget;
  final bool? hideLeadingIcon;

  CommonAppBar({required this.title, this.actionWidget, this.hideLeadingIcon});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
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

        //     GestureDetector(
        //   onTap: () {
        //     Get.back();
        //   },
        //   child: Container(
        //     margin: EdgeInsets.all(12),
        //     child: Image.asset(
        //       AppAsset.arrowLeft,
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        title: Text(
          title,
          style: AppTextStyle.normalSemiBold18.copyWith(color: appBarIconColor),
        ),
        centerTitle: true,
        actions: [if (actionWidget != null) actionWidget!],
        backgroundColor:
            Colors.transparent, // Make the AppBar background transparent
        elevation: 0, // Remove AppBar shadow
      ),
    );
  }
}
