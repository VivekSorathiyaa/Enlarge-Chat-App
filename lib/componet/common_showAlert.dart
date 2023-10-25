import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../utils/colors.dart';
import '../view/login_screen.dart';

class MyAlertDialog {
  static void showLogoutDialog(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: themeController.isDark.value ?MaterialStateProperty.all<Color>(primaryWhite.withOpacity(0.8)):MaterialStateProperty.all<Color>(primaryWhite.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'cancel'.tr,
          style: TextStyle( color: greyColor, fontWeight: FontWeight.w500),
        ),
      ),
      onPressed: () {
        Get.back();
      },
    );

    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(primaryBlack.withOpacity(0.9)),
      ),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return LoginScreen();
          }),
        );
      },
      child: Text(
        'continue'.tr,
        style: TextStyle(color: primaryWhite, fontWeight: FontWeight.w500),
      ),
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: themeController.isDark.value ? blackThemeColor : primaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
      ),
      alignment: Alignment.center,
      content: Text("logout_desc".tr),
      contentTextStyle:TextStyle(color:  themeController.isDark.value ?primaryWhite:primaryBlack),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showLanguageDialog(BuildContext context, List<Map<String, dynamic>> locale, Locale selectedLocale, Function(Locale) updateLanguage) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.start,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 15,
          title: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlack.withOpacity(0.9), greyColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'chooseLang'.tr,
                style: TextStyle(color: primaryWhite),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(locale.length, (index) {
              return ListTile(
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(locale[index]['name']),
                ),
                leading: Radio<Locale>(
                  value: locale[index]['locale'],
                  groupValue: selectedLocale,
                  onChanged: (value) {
                    updateLanguage(value!);
                    Navigator.of(context).pop(); // Close the dialog after selection
                  },
                ),
                splashColor: Colors.grey,
                onTap: () {
                  updateLanguage(locale[index]['locale']);
                  Navigator.of(context).pop(); // Close the dialog after selection
                },
              );
            }),
          ),
        );
      },
    );
  }



}
class LanguageDialog {
  static void showLanguageDialog(BuildContext context, List<Map<String, dynamic>> locale, Locale selectedLocale, Function(Locale) updateLanguage) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.start,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 15,
          title: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlack.withOpacity(0.9), greyColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'chooseLang'.tr,
                style: TextStyle(color: primaryWhite),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(locale.length, (index) {
              return ListTile(
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(locale[index]['name']),
                ),
                leading: Radio<Locale>(
                  value: locale[index]['locale'],
                  groupValue: selectedLocale,
                  onChanged: (value) {
                    updateLanguage(value!);
                    Navigator.of(context).pop(); // Close the dialog after selection
                  },
                ),
                splashColor: Colors.grey,
                onTap: () {
                  updateLanguage(locale[index]['locale']);
                  Navigator.of(context).pop(); // Close the dialog after selection
                },
              );
            }),
          ),
        );
      },
    );
  }
}
