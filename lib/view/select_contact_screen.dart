// ignore_for_file: invalid_use_of_protected_member

import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/primary_text_button.dart';
import 'package:chatapp/componet/user_widget.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../componet/image_picker_service.dart';
import '../controller/group_controller.dart';

class SelectContactScreen extends StatefulWidget {
  const SelectContactScreen({Key? key}) : super(key: key);

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  var groupController = Get.put(GroupController());
  final ThemeController themeController=Get.put(ThemeController());

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Select Contacts',
        actionWidget: Obx(
          () => groupController.selectUserList.value.length ==
                  groupController.allUserList.value.length
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    groupController.selectUserList.value.clear();
                    groupController.selectUserList.refresh();
                  },
                )
              : IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    groupController.selectUserList.value =
                        groupController.allUserList.value;
                    groupController.selectUserList.refresh();
                  },
                ),
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ListView(
            children: [
              height10,
              Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: groupController.allUserList
                      .map((element) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Obx(
                              () => UserWidget(
                                user: element,
                                trailing: groupController.selectUserList.value
                                        .contains(element)
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.check_circle_rounded,
                                          color: themeController.isDark.value?primaryWhite:primaryColor,
                                        ),
                                        onPressed: () {
                                          groupController.selectUserList
                                              .remove(element);
                                          groupController.selectUserList
                                              .refresh();
                                        },
                                      )
                                    : IconButton(
                                  color: themeController.isDark.value?primaryWhite:primaryColor,
                                        icon: Icon(Icons.circle_outlined),
                                        onPressed: () {
                                          groupController.selectUserList.value
                                              .add(element);
                                          groupController.selectUserList
                                              .refresh();
                                        },
                                      ),
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
              title: "Done",
              onPressed: () {
                Get.back();
              }),
        )
      ]),
    );
  }
}
