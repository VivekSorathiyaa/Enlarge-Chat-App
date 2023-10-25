import 'dart:io';

import 'package:chatapp/componet/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage(BuildContext context) async {
    CustomDialog.showSimpleDialog(
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                final XFile? pickedFile =
                    await _imagePicker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final File? croppedImage = await _cropImage(pickedFile.path);
                  if (croppedImage != null) {
                    selectedImage.value = croppedImage;
                    Get.back();
                  }
                }
              },
              leading: Icon(Icons.image),
              title: Text("Select Image from Gallery"),
            ),
            ListTile(
              onTap: () async {
                final XFile? pickedFile =
                    await _imagePicker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  final File? croppedImage = await _cropImage(pickedFile.path);
                  if (croppedImage != null) {
                    selectedImage.value = croppedImage;

                    Get.back();
                  }
                }
              },
              leading: Icon(Icons.camera),
              title: Text("Take a Photo"),
            ),
          ],
        ),
        context: context);
  }

  Future<File?> _cropImage(String imagePath) async {
    ImageCropper imageCropper = ImageCropper();
    final croppedFile = await imageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    return File(croppedFile!.path);
  }
}
