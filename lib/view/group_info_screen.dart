import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/app_text_style.dart';
import '../componet/network_image_widget.dart';
import '../componet/primary_text_button.dart';
import '../componet/text_form_field_widget.dart';
import '../componet/user_widget.dart';
import '../controller/group_controller.dart';
import '../utils/colors.dart';
import '../utils/static_decoration.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  const GroupInfoScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
    var groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryWhite,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: GestureDetector(
          onTap: () {
            if (widget.chatRoom.isGroup!) {
              Get.to(() => GroupInfoScreen(
                    chatRoom: widget.chatRoom,
                  ));
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NetworkImageWidget(
                width: 42,
                height: 42,
                borderRadius: BorderRadius.circular(42),
                imageUrl: widget.chatRoom.groupImage.toString(),
              ),
              width15,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatRoom.groupName.toString(),
                    style: AppTextStyle.regularBold.copyWith(
                        color: primaryWhite, fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Members : ${(widget.chatRoom.usersIds!.length)}',
                  style: AppTextStyle.normalBold14,
                ),
              ),
              TextButton.icon(
                  onPressed: () {
                    // Get.to(() => SelectContactScreen());
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
            ],
          ),
        ),
        // Expanded(
        //   child: ListView(
        //     children: [
        //       Obx(
        //         () => Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: widget.chatRoom.usersIds.selectUserList
        //               .map((element) => Padding(
        //                     padding: const EdgeInsets.symmetric(
        //                         horizontal: 15, vertical: 5),
        //                     child: UserWidget(
        //                       user: element,
        //                       trailing: IconButton(
        //                         icon: Icon(Icons.close_rounded),
        //                         onPressed: () {
        //                           groupController.selectUserList.value
        //                               .remove(element);
        //                           groupController.selectUserList.refresh();
        //                         },
        //                       ),
        //                     ),
        //                   ))
        //               .toList(),
        //         ),
        //       ),
        //       height30
        //     ],
        //   ),
        // ),
 
      ]),
    );
  }
}
