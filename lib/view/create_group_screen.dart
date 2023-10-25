import 'dart:io';

import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/group_controller.dart';
import '../utils/colors.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  var groupController = Get.put(GroupController());
  Rx<File?> selectedFile =
      Rx<File?>(null); // Initialize with null or any other default value.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Create Group',
      ),
      body: Column(children: [
        Row(
          children: [
            CupertinoButton(
              onPressed: () async {
                // File? file =
                //     await ImagePickerService().showPhotoOptions(context);
                // if (file != null) {
                //   selectedFile.value = file;
                //   log("---file----$file");
                // }
                // log("---file-filefilefile---$file");
              },
              child: Obx(
                () => CircleAvatar(
                  radius: 40,
                  backgroundColor: greyBorderColor,
                  backgroundImage: (selectedFile.value != null)
                      ? FileImage(selectedFile.value!)
                      : null,
                  child: (selectedFile.value == null)
                      ? Icon(
                          Icons.image,
                          color: greyColor,
                          // size: 60,
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: TextFormFieldWidget(
                controller: groupController.nameTextController,
                hintText: "Enter Group Name",
              ),
            )
          ],
        ),
      ]),
    );
  }
}
