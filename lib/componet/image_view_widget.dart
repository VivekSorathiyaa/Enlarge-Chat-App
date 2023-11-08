import 'dart:io';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/app_asset.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import 'app_text_style.dart';

// ignore: must_be_immutable
class ImageViewWidget extends StatelessWidget {
  bool isFile;
  String imageUrl;
  String? text;
  bool? profileImg;

  ImageViewWidget(
      {Key? key,
      required this.imageUrl,
      required this.isFile,
      this.text,
      this.profileImg})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeController = Get.put(ThemeController());
    return Scaffold(
      body: Stack(
        children: [
          isFile
              ? PhotoView(
                  imageProvider: FileImage(File(imageUrl)),
                )
              : PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                ),
          SafeArea(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {

                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: primaryWhite),
                ),
                profileImg == true
                    ? Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Text(
                          text!,
                          style: themeController.isDark.value
                              ? AppTextStyle.darkNormalBold16
                                  .copyWith(color: primaryWhite)
                              : AppTextStyle.lightNormalBold16
                                  .copyWith(color: primaryWhite),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
