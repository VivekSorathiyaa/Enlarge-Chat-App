import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/static_decoration.dart';
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
    final ThemeController themeController = Get.put(ThemeController());
    return Scaffold(
      backgroundColor: themeController.isDark.value
          ? blackThemeColor.withOpacity(0.5)
          : primaryWhite,
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
                style: themeController.isDark.value
                    ? AppTextStyle.regularBold.copyWith(
                        color: primaryWhite.withOpacity(0.99),
                        fontSize: 24,
                        height: 1.3,
                        fontWeight: FontWeight.w700)
                    : AppTextStyle.regularBold.copyWith(
                        color: primaryBlack,
                        fontSize: 24,
                        height: 1.3,
                        fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              height10,
              Text(
                "Verify your phone number",
                style: themeController.isDark.value?AppTextStyle.normalRegular16
                    .copyWith(color: Colors.grey[100]!.withOpacity(0.5), fontWeight: FontWeight.w400):AppTextStyle.normalRegular16
                    .copyWith(color: greyColor, fontWeight: FontWeight.w400),
              ),
              customHeight(35),
              ShadowContainerWidget(
                color:
                    themeController.isDark.value ? darkBlueColor : primaryBlack,
                padding: 0,
                widget: SizedBox(
                    width: 150,
                    child: CountryCodePicker(
                      boxDecoration: themeController.isDark.value
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: primaryBlack),
                              ],
                            )
                          : null,
                      searchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorderColor)),

                        iconColor: themeController.isDark.value
                            ? Colors.white
                            : primaryBlack,
                        hintText: 'Search',
                        prefixIconColor: themeController.isDark.value
                            ? Colors.white
                            : primaryBlack,
                        // Customize the search bar hint text
                        hintStyle: TextStyle(
                          color: themeController.isDark.value
                              ? primaryWhite
                              : primaryBlack,
                        ),
                      ),
                      textStyle: TextStyle(color: primaryWhite),
                      showDropDownButton: true,
                      onChanged: controller.onCountryChange,
                      initialSelection: '+91',
                      favorite: const ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: true,
                      alignLeft: false,
                      padding: EdgeInsets.zero,
                      searchStyle: TextStyle(
                        color: themeController.isDark.value
                            ? primaryWhite
                            : primaryBlack,
                      ),
                      dialogTextStyle: TextStyle(
                          color: themeController.isDark.value
                              ? primaryWhite
                              : primaryBlack),
                      dialogBackgroundColor: themeController.isDark.value
                          ? blackThemeColor
                          : primaryWhite,
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
