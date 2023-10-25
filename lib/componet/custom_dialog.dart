import 'dart:developer';
import 'dart:ui';

import 'package:chatapp/componet/primary_text_button.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_asset.dart';
import '../utils/colors.dart';
import '../utils/static_decoration.dart';
import 'app_text_style.dart';

class CustomDialog {
  static Future<void> showConfirmationDialog(
      {String? title,
      String? message,
      Widget? bodyWiget,
      TextStyle? messageTextStyle,
      TextStyle? titleTextStyle,
      required Function() onOkPress,
      required BuildContext context,
      Function()? onBackPress}) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.all(15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: Center(
              child: Text(
            title ?? 'Confirmation',
            style: titleTextStyle ??
                AppTextStyle.normalBold18.copyWith(color: primaryColor),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bodyWiget ??
                  AspectRatio(
                    aspectRatio: 2 / 2,
                    child: Image.asset(
                      AppAsset.agreeBg,
                      // width: 100,
                      // height: 100,
                    ),
                  ),
              height20,
              Center(
                child: Text(
                  message ?? "Are you sure ?",
                  style: messageTextStyle ??
                      AppTextStyle.lightNormalBold16
                          .copyWith(color: primaryColor, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              height20,
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onBackPress ??
                            () {
                              Get.back();
                            },
                        child: ShadowContainerWidget(
                            padding: 0,
                            blurRadius: 1,
                            borderColor: primaryColor,
                            shadowColor: primaryColor,
                            radius: 8,
                            widget: SizedBox(
                              height: 36,
                              child: Center(
                                child: Text(
                                  "No",
                                  style: AppTextStyle.normalBold14
                                      .copyWith(color: primaryColor),
                                ),
                              ),
                            )),
                      ),
                    ),
                    width15,

                    Expanded(
                      child: InkWell(
                        onTap: onOkPress,
                        child: ShadowContainerWidget(
                            padding: 0,
                            blurRadius: 1,
                            radius: 8,
                            borderColor: primaryColor,
                            color: primaryColor,
                            widget: SizedBox(
                              height: 36,
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: AppTextStyle.normalBold14
                                      .copyWith(color: primaryWhite),
                                ),
                              ),
                            )),
                      ),
                    ),
                    // Expanded(
                    //   child: InkWell(
                    //     onTap: onOkPress,
                    //     child: Container(
                    //       height: 36,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(8),
                    //           color: primaryColor),
                    //       child: Center(
                    //         child: Text(
                    //           "Yes",
                    //           style: AppTextStyle.normalBold14
                    //               .copyWith(color: whiteColor),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showSimpleDialog({
    String? title,
    bool? hideContent,
    Widget? titleWidget,
    required Widget child,
    required BuildContext context,
  }) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: primaryBlack.withOpacity(.3),
      
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          title: title == null ? null : Text(title),
          insetPadding: EdgeInsets.symmetric(horizontal: 15),
          // contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          contentPadding: EdgeInsets.symmetric(
              horizontal: hideContent != null && hideContent ? 0 : 15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),

          content: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: hideContent != null && hideContent ? 0 : 20),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  static Future<void> showLoadingDialog(BuildContext context, String title) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: primaryBlack.withOpacity(.3),
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15),
          // contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),

          content: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loading...',
                  style: AppTextStyle.lightNormalBold16,
                ),
                height30,
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                height30,
                Text(
                  title,
                  style: AppTextStyle.normalRegular14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showAlertDialog(
      BuildContext context, String title, String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: primaryBlack.withOpacity(.3),
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15),
          // contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),

          content: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyle.lightNormalBold16,
                ),
                height10,
                Text(
                  content,
                  style: AppTextStyle.normalRegular14.copyWith(height: 1.5),
                ),
                height15,
                PrimaryTextButton(
                    title: 'Ok',
                    onPressed: () {
                      Get.back();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future showNoInternetConnectionDialog() async {
    log("--showNoInternetConnectionDialog--");
    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Material(
          color: primaryWhite,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAsset.noInternet,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Text(
                    "No internet connection",
                    style: AppTextStyle.normalBold20,
                  ),
                  height20,
                  Text(
                    "Please Check your internet connection and try again.",
                    style: AppTextStyle.normalRegular16
                        .copyWith(color: primaryBlack.withOpacity(0.40)),
                    textAlign: TextAlign.center,
                  ),
                  customHeight(30),
                  height15,
                ],
              ),
            ),
          ),
        ),
      ),

      barrierDismissible:
          false, // Set to true if you want to allow tapping outside to close the dialog
    );
  }
}
