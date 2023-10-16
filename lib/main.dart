import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/view/complete_profile_screen.dart';
import 'package:chatapp/view/home_screen.dart';

import 'package:chatapp/view/login_screen.dart';
import 'package:chatapp/view/splash_screen.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'componet/app_text_style.dart';
import 'utils/colors.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
await AppPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: appBackgroundColor,
        fontFamily: AppTextStyle.fontFamilyInter,
        hintColor: primaryBlack,
        appBarTheme: AppBarTheme(backgroundColor: primaryColor),
        iconTheme: IconThemeData(color: primaryBlack),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColor),
      ),
      home: SplashScreen(),
    );

  }
}

