import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../componet/custom_dialog.dart';
import '../models/user_model.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';
import 'home_screen.dart';

class EditProfile extends StatefulWidget {
  EditProfile({
    Key? key,
  }) : super(key: key);

  @override
  _EditProfileState createState() => new _EditProfileState();
}

String? fullname = AppPreferences.getFullName();
String? phone = AppPreferences.getPhone();
String? profilePic = AppPreferences.getProfilePic();
TextEditingController fullNameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
File? imageFile;

class _EditProfileState extends State<EditProfile> {
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    ImageCropper imageCropper = ImageCropper();
    CroppedFile? croppedImage = await imageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    CustomDialog.showSimpleDialog(
        context: context,
        title: 'Upload Profile Picture',
        child: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            ),
          ],
        ));
  }

  void checkValues() {
    if (fullNameController.text.isEmpty && imageFile == null) {
      print("Uploading data.trtrrttryty.");
      Get.back(); // This will navigate back to the previous screen
    } else {
      print("Uploading data..");
      uploadData();
      CustomDialog.showAlertDialog(
          context, "Update Profile", "Successfully Update your profile...");
    }
  }

  Future uploadData() async {
    String? uid = await AppPreferences.getUiId();
    String? phone = await AppPreferences.getPhone();

    String? fcmToken = await AppPreferences.getFcmToken();

    if (uid != null) {
      CustomDialog.showLoadingDialog(context, "Updating Profile..");

      if (imageFile != null || fullNameController.text.trim() != fullname) {
        String? imageUrl;
        if (imageFile != null) {
          UploadTask uploadTask = FirebaseStorage.instance
              .ref("profilepictures")
              .child(uid)
              .putFile(imageFile!);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          imageUrl =
              profilePic; // Reuse the existing URL if the image hasn't changed
        }

        UserModel userModel = UserModel(
          uid: uid,
          phone: phone,
          fullname: fullNameController.text.trim(),
          profilepic: imageUrl,
          fcmtoken: fcmToken,
          openRoomId: null,
        );
        await CommonMethod.saveUserData(userModel);
        await AppPreferences.setFullName(fullNameController.text.trim());
        await AppPreferences.setProfilePic(imageUrl!);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel.uid)
            .set(userModel.toMap())
            .then((value) {
          log("Data uploaded!");
          Get.to(() => HomeScreen());
        });
      } else {
        // No changes were made
        CustomDialog.showAlertDialog(
          context,
          "No Changes Made",
          "No changes were made to your profile.",
        );
      }
    }
  }

  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor:
            themeController.isDark.value ? primaryBlack : primaryWhite,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: primaryWhite,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor:
              themeController.isDark.value ? blackThemeColor : primaryBlack,
          centerTitle: true,
          title: Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50),
            alignment: Alignment.center,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showPhotoOptions();
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: (imageFile !=
                                  null) // Check if a local image file exists
                              ? Image.file(
                                  imageFile!) // Display the local image file
                              : Image.network(
                                  profilePic!), // Display the network image
                        ),
                      ),

                      Positioned(
                          bottom: 5,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            width: 35,
                            height: 35,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ))
                    ],
                  ),
                ),
                height30,
                Form(
                    child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Full Name',
                          style: themeController.isDark.value
                              ? AppTextStyle.normalSemiBold15
                                  .copyWith(color: Colors.grey[300])
                              : AppTextStyle.normalSemiBold15,
                        ),
                      ),
                      height05,
                      TextFormFieldWidget(
                        suffixIcon: Icon(
                          Icons.edit,
                          color: primaryBlack,
                        ),
                        controller: fullNameController,
                        hintText: fullname,
                      ),
                      height20,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Phone Name',
                          style: themeController.isDark.value
                              ? AppTextStyle.normalSemiBold15
                                  .copyWith(color: Colors.grey[300])
                              : AppTextStyle.normalSemiBold15,
                        ),
                      ),
                      height05,
                      TextFormFieldWidget(
                        readonly: true,
                        textInputAction: TextInputAction.none,
                        keyboardType: TextInputType.number,
                        controller: null,
                        hintText: phone,
                      ),
                      height30,
                      Padding(
                        padding: const EdgeInsets.all(38.0),
                        child: Center(
                          child: CupertinoButton(
                            borderRadius: BorderRadius.circular(20),
                            onPressed: () {
                              checkValues();
                            },
                            color: themeController.isDark.value
                                ? Colors.blue[900]?.withOpacity(0.8)
                                : Theme.of(context).colorScheme.secondary,
                            child: Text("Submit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      );
    });
  }
}
