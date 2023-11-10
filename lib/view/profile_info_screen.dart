import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:chatapp/componet/video_view_widget.dart';
import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:chatapp/view/video_conference_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../componet/app_text_style.dart';
import '../componet/image_view_widget.dart';
import '../models/chat_room_model.dart';
import '../utils/colors.dart';
import '../utils/common_method.dart';

class ProfileInfoScreen extends StatefulWidget {
  ProfileInfoScreen(
      {Key? key,
      required this.name,
      required this.img,
      required this.phone,
      this.chatRoomModel,
      this.chatRoomId});
  final String name;
  final String img;
  final String phone;
  final ChatRoomModel? chatRoomModel;
  final String? chatRoomId;
  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  @override
  Widget build(BuildContext context) {
    var chatController = Get.put(ChatController());

    var themeController = Get.put(ThemeController());

    List<MessageModel> allMessages = [];

    chatController.messages.forEach((message) {
      if (message.messageType == 1) {
        allMessages.add(message);
      } else if (message.messageType == 2) {
        allMessages.add(message);
      }
    });

    Widget buildIconButton(
        IconData icon, double iconSize, void Function()? onTap, String title) {
      return Column(
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              size: iconSize,
              color: themeController.isDark.value ? primaryWhite : primaryBlack,
            ),
          ),
          height08,
          Text(
            title,
            style: themeController.isDark.value
                ? AppTextStyle.normalRegular13.copyWith(color: Colors.grey[300])
                : AppTextStyle.normalRegular13,
          ),
        ],
      );
    }
    void shareContact(String name, String phoneNumber) {
      final contactInfo = '''
    Contact Name: $name
    Phone Number: $phoneNumber
  ''';

      Share.share(contactInfo);
    }

    return Scaffold(
      backgroundColor: themeController.isDark.value
          ? primaryBlack
          : Colors.grey[50]!.withOpacity(0.99),
      body: Column(
        children: [
          Card(
            color: themeController.isDark.value
                ? blackThemeColor.withOpacity(0.5)
                : primaryWhite,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: themeController.isDark.value
                          ? primaryWhite
                          : primaryBlack,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: GestureDetector(
                        onTap: (){
                         Get.to(()=>ImageViewWidget(imageUrl:widget.img  , isFile: false,profileImg: true,text: widget.name,));
                        },
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: PhotoView(
                              imageProvider: NetworkImage(widget.img),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        widget.name,
                        style: themeController.isDark.value
                            ? AppTextStyle.normalSemiBold18
                                .copyWith(color: Colors.grey[300])
                            : AppTextStyle.normalSemiBold18,
                      ),
                    ),
                    Text(
                      widget.phone,
                      style: themeController.isDark.value
                          ? AppTextStyle.normalRegular15
                              .copyWith(color: Colors.grey)
                          : AppTextStyle.normalRegular13,
                    ),
                    height15,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildIconButton(Icons.video_call, 30, () {
                          Get.to(() => VideoConferenceScreen(
                                chatRoomModel: widget.chatRoomModel,
                                chatRoomId: widget.chatRoomId,
                              ));
                        }, 'Video'),
                        width30,
                        buildIconButton(Icons.message_rounded, 28, () {
                          Get.back();
                        }, 'Text'),
                        width30,
                        buildIconButton(Icons.share, 26, () {
                         shareContact(widget.name,widget.phone);
                        }, 'Share'),
                      ],
                    ),
                    height20
                  ],
                ),
                height10,
              ],
            ),
          ),
          height08,
          Container(
            color: themeController.isDark.value
                ? blackThemeColor.withOpacity(0.5)
                : primaryWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10),
                  child: Text(
                    allMessages.length == 0
                        ? 'No Media shares here.....'
                        : 'Media Images & Videos',
                    style: themeController.isDark.value
                        ? AppTextStyle.normalRegular13
                            .copyWith(color: Colors.grey[300]?.withOpacity(0.5))
                        : AppTextStyle.normalSemiBold15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                color: themeController.isDark.value
                    ? blackThemeColor.withOpacity(0.5)
                    : primaryWhite,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount:
                      allMessages.length, // Display all filtered messages
                  itemBuilder: (context, index) {
                    var message = allMessages[index];
                    if (message.messageType == 1) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ImageViewWidget(
                              imageUrl: message.media!, isFile: false));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(message.media!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else if (message.messageType == 2) {
                      return FutureBuilder<String>(
                        future: CommonMethod.generateThumbnail(message.media!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return GestureDetector(
                              onTap: () async {
                                Get.to(() => VideoViewWidget(
                                    url: message.media!, isFile: false));
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(snapshot.data!),
                                        width: (Get.width / 2),
                                        height: (Get.width / 2),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 50,
                                    color: primaryWhite.withOpacity(.8),
                                  )
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const SizedBox();
                          }
                          return const SizedBox();
                        },
                      );
                    }
                    return SizedBox(); // Return an empty widget if message type is unknown.
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
