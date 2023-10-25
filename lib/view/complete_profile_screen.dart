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

import '../utils/common_method.dart';

class CompleteProfileScreen extends StatefulWidget {

  const CompleteProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();


  
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
    if (fullNameController.text.isEmpty || imageFile == null) {
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
          .putFile(imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String? imageUrl = await snapshot.ref.getDownloadURL();
      UserModel userModel = UserModel(
          uid: uid,
          phone: phone,
          fullname: fullNameController.text.trim(),
          profilepic: imageUrl,
          fcmtoken: fcmToken, active: []);
      await CommonMethod.saveUserData(userModel);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel.uid)
          .set(userModel.toMap())
          .then((value) {
        log("Data uploaded!");
      //  Get.back();
        Get.to(()=>HomeScreen());
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
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
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
