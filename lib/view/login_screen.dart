import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:chatapp/utils/validators.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../componet/app_text_style.dart';
import '../componet/primary_text_button.dart';
import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var controller = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Login",
        hideLeadingIcon: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customHeight(20),
              Text(
                'Hello !',
                style: AppTextStyle.regularBold.copyWith(
                    color: primaryBlack,
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              height10,
              Text(
                "Verify your phone number",
                style: AppTextStyle.normalRegular16
                    .copyWith(color: greyColor, fontWeight: FontWeight.w400),
              ),
              customHeight(35),
              ShadowContainerWidget(
                padding: 0,
                widget: SizedBox(
                    width: 150,
                    child: CountryCodePicker(
                      showDropDownButton: true,
                      onChanged: controller.onCountryChange,
                      initialSelection: '+91',
                      favorite: const ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: true,
                      alignLeft: false,
                      padding: EdgeInsets.zero,
                    )),
              ),
              customHeight(35),
              TextFormFieldWidget(
                controller: controller.phoneTxtController,
                onChanged: (value) => controller.validateCountryCode(value!),
                prefixIcon: Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                hintText: 'Phone Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is Required";
                  }
                  if (!value.isPhoneNumber) {
                    return "Only Numbers expected";
                  }
                  return null;
                },
              ),
              customHeight(35),
              PrimaryTextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.verifyPhoneNumber(context);
                  }
                },
                title: 'Send Verification Code',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
