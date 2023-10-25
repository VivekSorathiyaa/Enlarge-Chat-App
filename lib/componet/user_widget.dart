import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../utils/app_preferences.dart';
import '../view/chat_room_screen.dart';
import 'network_image_widget.dart';

class UserWidget extends StatelessWidget {
  final UserModel user;
  UserWidget({Key? key, required this.user}) : super(key: key);
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ShadowContainerWidget(
          padding: 0,
          widget: ListTile(
            onTap: () async {
              final chatRoomModel = await CommonMethod.getChatRoomModel(
                  [user.uid!, AppPreferences.getUiId()!]);

              if (chatRoomModel != null) {
                Get.back();
                Get.to(
                  () => ChatRoomScreen(
                    chatRoomId: chatRoomModel.chatRoomId!,
                    targetUser: user,
                  ),
                );
              }
            },
            leading: NetworkImageWidget(
              height: 50,
              width: 50,
              borderRadius: BorderRadius.circular(50),
              imageUrl: user.profilepic.toString(),
            ),
            title: Text(
              user.fullname.toString(),
              style: themeController.isDark.value
                  ? AppTextStyle.normalBold16.copyWith(color: primaryWhite)
                  : AppTextStyle.normalBold16,
            ),
            subtitle: Text(user.phone.toString(),
                style: themeController.isDark.value? AppTextStyle.normalRegular14.copyWith(color: primaryWhite.withOpacity(0.5)):AppTextStyle.normalRegular14),
            trailing: Icon(Icons.keyboard_arrow_right,color:themeController.isDark.value?  primaryWhite.withOpacity(0.5):primaryBlack),
          )),
    );
  }
}
