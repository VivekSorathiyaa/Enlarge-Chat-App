import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/video_view_widget.dart';
import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../componet/image_view_widget.dart';
import '../componet/text_form_field_widget.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  // final UserModel userModel;

  const ChatRoomScreen({
    Key? key,
    required this.targetUser,
    required this.chatroom,
    // required this.userModel,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  var controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // CircleAvatar(
            //   backgroundColor: Colors.grey[300],
            //   backgroundImage:
            //       NetworkImage(widget.targetUser.profilepic.toString()),
            // ),

            
            NetworkImageWidget(
              width: 42,
              height: 42,
              borderRadius: BorderRadius.circular(42),
              imageUrl: widget.targetUser.profilepic.toString(),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              // This is where the chats will go
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            bool isCurrentUser = (currentMessage.sender ==
                                AppPreferences.getUiId());
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10),
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isCurrentUser
                                          ? primaryColor
                                          : greenColor),
                                  color:
                                      isCurrentUser ? primaryColor : greenColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: isCurrentUser
                                          ? Radius.circular(10)
                                          : Radius.circular(0),
                                      bottomLeft: Radius.circular(10),
                                      topRight: isCurrentUser
                                          ? Radius.circular(0)
                                          : Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: Get.width * 0.7,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: isCurrentUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (currentMessage.media != null)
                                      Column(
                                        children: [
                                          if (currentMessage.messageType == 3)
                                            audioTypeMessageWidget(
                                                currentMessage, isCurrentUser),
                                          if (currentMessage.messageType == 2)
                                            videoTypeMessageWidget(
                                                currentMessage, isCurrentUser),
                                          if (currentMessage.messageType == 1)
                                            imageTypeMessageWidget(
                                                currentMessage, isCurrentUser)
                                        ],
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (currentMessage.text!.isNotEmpty)
                                            textTypeMessageWidget(
                                                currentMessage),
                                          messageTimeWidget(currentMessage)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              "An error occured! Please check your internet connection."),
                        );
                      } else {
                        return Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormFieldWidget(
                        controller: controller.messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5, //
                        hintText: "Enter message",
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            controller.selectedFile =
                                await CommonMethod.pickFile();
                            if (controller.selectedFile != null) {
                              String? path =
                                  await controller.uploadFile(context);
                              if (path != null) {
                                controller.mediaUrl = path;
                                controller.sendMessage(widget.chatroom);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    width10,
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: primaryWhite,
                        ),
                        onPressed: () {
                          controller.sendMessage(widget.chatroom);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageTimeWidget(MessageModel currentMessage) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        CommonMethod.formatDateToTime(
            currentMessage.createdon ?? DateTime.now()),
        style: AppTextStyle.normalRegular10
            .copyWith(height: 0, color: primaryWhite.withOpacity(.7)),
      ),
    );
  }

  Widget textTypeMessageWidget(MessageModel currentMessage) {
    return Flexible(
      child: Text(
        currentMessage.text.toString(),
        style: AppTextStyle.normalRegular14.copyWith(color: primaryWhite),
      ),
    );
  }

  Widget imageTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ImageViewWidget(
              imageUrl: currentMessage.media!,
              isFile: false,
            ));
      },
      child: NetworkImageWidget(
        width: (Get.width / 2),
        height: (Get.width / 2),
        borderRadius: BorderRadius.only(
            topLeft: isCurrentUser ? Radius.circular(10) : Radius.circular(0),
            bottomLeft: Radius.circular(10),
            topRight: isCurrentUser ? Radius.circular(0) : Radius.circular(10),
            bottomRight: Radius.circular(10)),
        imageUrl: currentMessage.media,
      ),
    );
  }

  Widget audioTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return GestureDetector(
        onTap: () {
          log("---currentMessage.media---${currentMessage.media}");
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.audio_file_rounded,
                color: primaryWhite,
              ),
            ),
            Flexible(
              child: Text(
                "Audio file",
                style: AppTextStyle.normalBold14.copyWith(color: primaryWhite),
              ),
            )
          ],
        ));
  }

  Widget videoTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return FutureBuilder<String>(
      future: CommonMethod.generateThumbnail(currentMessage.media!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () async {
              Get.to(() =>
                  VideoViewWidget(url: currentMessage.media!, isFile: false));
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
}
