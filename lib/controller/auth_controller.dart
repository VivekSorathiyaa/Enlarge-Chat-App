import 'dart:developer';

import 'package:chatapp/view/complete_profile_screen.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/custom_dialog.dart';
import '../models/user_model.dart';
import '../view/home_screen.dart';
import '../view/verify_code_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneTxtController = new TextEditingController();
  TextEditingController otpTxtController = new TextEditingController();
  String _countryCode = '+91';

  onCountryChange(CountryCode value) {
    if (value.code != null) {
      _countryCode = value.dialCode!;
    }
    phoneTxtController.text = _countryCode;
  }

  void validateCountryCode(String value) {
    if (value.length < _countryCode.length) {
      phoneTxtController.text = _countryCode;
    }
    // set the cursor to end of text
    phoneTxtController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneTxtController.text.length));
  }

  Future verifyPhoneNumber(BuildContext context) async {
    CustomDialog.showLoadingDialog(context, "OTP Send..");
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneTxtController.text,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          UserCredential? credential =
              await auth.signInWithCredential(phoneAuthCredential);
          if (credential != null) {
            log('Phone number verified');
            String uid = credential.user!.uid;
            DocumentSnapshot userData = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            UserModel userModel =
                UserModel.fromMap(userData.data() as Map<String, dynamic>);
            await CommonMethod.saveUserData(userModel);
            log("Log In Successful!");
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                return HomeScreen();
              }),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification failed: $e');
          Navigator.pop(context);
          CustomDialog.showAlertDialog(
              context, "An error occured", e.message.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (ex) {
      log('Phone authentication error: $ex');
      Navigator.pop(context);
      CustomDialog.showAlertDialog(
          context, "An error occurred", ex.message.toString());
    }
  }

  Future<void> signInWithSmsCode(
      BuildContext context, String verificationId) async {
    CustomDialog.showLoadingDialog(context, "Verify SMS Code..");

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpTxtController.text,
      );

      UserCredential? credential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      if (credential != null) {
        log('Phone number verified first');
        String uid = credential.user!.uid;
        UserModel newUser = UserModel(
            uid: uid,
            phone: phoneTxtController.text,
            fullname: null,
            profilepic: null);
        await CommonMethod.saveUserData(newUser);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set(newUser.toMap())
            .then((value) {
          print("New User Created!");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return CompleteProfileScreen();
            }),
          );
        });
      }
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      CustomDialog.showAlertDialog(context, "An error occurred", ex.toString());
      log('Sign in with SMS code error: $ex');
    }
  }
}
