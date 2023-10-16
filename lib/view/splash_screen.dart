import 'dart:async';
import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/view/login_screen.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    return Timer(
      const Duration(seconds: 2),
      () async {
        navigationPage();
      },
    );
  }

  void navigationPage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // UserModel? thisUserModel =
      //     await FirebaseHelper.getUserModelById(currentUser.uid);
      // if (thisUserModel != null) {
        Get.offAll(() =>
            HomeScreen(
              // userModel: thisUserModel,
              //  firebaseUser: currentUser
               ));
      // } else {
      //   Get.offAll(() => LoginScreen());
      // }
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 50,
            color: primaryBlack,
          ),
          height08,
          Text(
            "Chat App",
            style: AppTextStyle.normalBold26,
          )
        ],
      )),
    );
  }
}
