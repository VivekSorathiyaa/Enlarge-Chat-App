import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/view/home_screen.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/image_picker_controller.dart';
import '../utils/colors.dart';
import '../utils/common_method.dart';

class CompleteProfileScreen extends StatefulWidget {

  const CompleteProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  TextEditingController fullNameController = TextEditingController();

  var imagePickerController = Get.put(ImagePickerController());

  
  

  void checkValues() {
    if (fullNameController.text.isEmpty || imagePickerController.selectedImage.value == null) {
      print("Please fill all the fields");
      CustomDialog.showAlertDialog(context, "Incomplete Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      log("Uploading data..");
      uploadData();
    }
  }

  Future uploadData() async {
    String? uid = await AppPreferences.getUiId();
    String? phone = await AppPreferences.getPhone();
    String? fcmToken = await AppPreferences.getFcmToken();

    if (uid != null) {
      CustomDialog.showLoadingDialog(context, "Uploading image..");
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profilepictures")
          .child(uid)
          .putFile(imagePickerController.selectedImage.value!);
      TaskSnapshot snapshot = await uploadTask;
      String? imageUrl = await snapshot.ref.getDownloadURL();
      UserModel userModel = UserModel(
          uid: uid,
          phone: phone,
          fullName: fullNameController.text.trim(),
          profilePic: imageUrl,
          fcmToken: fcmToken, openRoomId: null);
      await CommonMethod.saveUserData(userModel);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel.uid)
          .set(userModel.toMap())
          .then((value) {
        log("Data uploaded!");
      //  Get.back();
        Get.offAll(()=>HomeScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
              onPressed: () async {
imagePickerController.pickImage(context);
              },
              child: Obx(
                () => CircleAvatar(
                  radius: 40,
                  backgroundColor: greyBorderColor,
                  backgroundImage: (imagePickerController.selectedImage.value !=
                          null)
                      ? FileImage(imagePickerController.selectedImage.value!)
                      : null,
                  child: (imagePickerController.selectedImage.value == null)
                      ? Icon(
                          Icons.image,
                          color: greyColor,
                          // size: 60,
                        )
                      : null,
                ),
              ),
            ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
