
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/common_app_bar.dart';
import '../componet/primary_text_button.dart';
import '../componet/text_form_field_widget.dart';
import '../controller/auth_controller.dart';
import '../utils/static_decoration.dart';

class VerifyCodeScreen extends StatefulWidget {
String verificationId;

  VerifyCodeScreen(this.verificationId);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  var controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: CommonAppBar(
        title: "Verification Code",
        hideLeadingIcon: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormFieldWidget(
                controller: controller.otpTxtController,
                prefixIcon: Icon(Icons.password),
                keyboardType: TextInputType.number,
                hintText: 'Phone Number',
              ),
              height20,
              PrimaryTextButton(
                onPressed: () {
                  controller.signInWithSmsCode(context,widget.verificationId);
                },
                title: 'Verify Code',
              ),
            ],
          ),
        ),
      ),
    );
    

  }
}
