import 'dart:io';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/primary_text_button.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/componet/user_widget.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:chatapp/view/select_contact_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/group_controller.dart';
import '../controller/image_picker_controller.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/common_method.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  var groupController = Get.put(GroupController());
  var imagePickerController = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController=Get.put(ThemeController());
    return Scaffold(
      backgroundColor: themeController.isDark.value?primaryBlack:primaryWhite,
      appBar: CommonAppBar(
        title: 'Create Group',
      ),
      body:
      
       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  imagePickerController.pickImage(context);
                },
                child: Obx(
                  () => Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: greyBorderColor,
                        backgroundImage:
                            (imagePickerController.selectedImage.value != null)
                                ? FileImage(
                                    imagePickerController.selectedImage.value!)
                                : null,
                        child:
                            (imagePickerController.selectedImage.value == null)
                                ? Icon(
                                    Icons.image,
                                    color: greyColor,
                                  )
                                : null,
                      ),
                      Positioned(
                        bottom:5,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeController.isDark.value?Colors.blue:null,
                          ),

                          child: Icon(
                            CupertinoIcons.camera_circle_fill,
                            color: themeController.isDark.value?Colors.grey[100]:primaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              width15,
              Expanded(
                child: TextFormFieldWidget(
                  controller: groupController.nameTextController,
                  prefixIcon: Icon(Icons.edit),
                  hintText: "Enter Group Name",
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Members : ${(groupController.selectUserList.value.length + 1)}',
                  style: themeController.isDark.value?AppTextStyle.normalBold14.copyWith(color: primaryWhite):AppTextStyle.normalBold14,
                ),
              ),
              TextButton.icon(
                  onPressed: () {
                    Get.to(() => SelectContactScreen());
                  },
                  style: ButtonStyle(
                    backgroundColor: themeController.isDark.value?MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return darkBlueColor
                              .withOpacity(.9); // Color for the pressed state
                        }
                        return darkBlueColor; // Default color
                      },
                    ):MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return primaryColor
                              .withOpacity(.8); // Color for the pressed state
                        }
                        return primaryColor; // Default color
                      },
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.add,
                    color: primaryWhite,
                  ),
                  label: Text(
                    'Add Member',
                    style:
                        AppTextStyle.normalBold14.copyWith(color: primaryWhite),
                  ))
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: PrimaryTextButton(
              //       title: "Add Member",
              //       onPressed: () {
              //
              //       }),
              // ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Obx(
                  () => UserWidget(
                    user: groupController.currentUser.value,
                    trailing: IconButton(
                        onPressed: () {},
                        icon: Text(
                          'You',
                          style: AppTextStyle.normalBold14
                              .copyWith(color: greyColor),
                        )),
                  ),
                ),
              ),
              Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: groupController.selectUserList
                      .map((element) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: UserWidget(
                              user: element,
                              trailing: IconButton(
                                icon: Icon(Icons.close_rounded, color: themeController.isDark.value?greyColor:primaryColor,),
                                onPressed: () {
                                  groupController.selectUserList.value
                                      .remove(element);
                                  groupController.selectUserList.refresh();
                                },
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              height30
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: PrimaryTextButton(
              title: "Create Group",
              onPressed: () async {
                String? mediaUrl;
                if (groupController.nameTextController.text.isEmpty) {
                  CommonMethod.getXSnackBar(
                      "Error", "Please enter group name", redColor);
                } else {
                  if (imagePickerController.selectedImage.value != null) {
                    String? path = await CommonMethod.uploadFile(
                        context, imagePickerController.selectedImage.value!);
                    if (path != null) {
                      mediaUrl = path;
                    }
                  }

                  List<String> idList = groupController.selectUserList.value
                      .map((user) => user.uid.toString())
                      .toList();

                  await CommonMethod.createGroup(
                      groupName: groupController.nameTextController.text,
                      usersIds: [
                        AppPreferences.getUiId().toString(),
                        ...idList
                      ],
                      groupImage: mediaUrl);
                  Get.back();
                }
              }),
        ),
      ]),
    );
  }
}
