import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/componet/network_image_widget.dart';
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                              MessageModel currentMessage =
                                  MessageModel.fromMap(dataSnapshot.docs[index]
                                      .data() as Map<String, dynamic>);
                              bool isCurrentUser = (currentMessage.sender ==
                                  AppPreferences.getUiId());
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                alignment: isCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  // padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? primaryColor
                                        : greenColor,
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
                                    maxWidth: Get.width * 0.8,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: isCurrentUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (currentMessage.mediaList != null &&
                                          currentMessage.mediaList!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: NetworkImageWidget(
                                            borderRadius: BorderRadius.only(
                                                topLeft: isCurrentUser
                                                    ? Radius.circular(10)
                                                    : Radius.circular(0),
                                                bottomLeft: Radius.circular(10),
                                                topRight: isCurrentUser
                                                    ? Radius.circular(0)
                                                    : Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            imageUrl: widget
                                                .targetUser.profilepic
                                                .toString(),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                currentMessage.text.toString(),
                                                style: AppTextStyle
                                                    .normalRegular14
                                                    .copyWith(
                                                        color: primaryWhite),
                                              ),
                                            ),
                                            // width15,
                                            // Text(
                                            //   CommonMethod.formatDateToTime(
                                            //       currentMessage.createdon ??
                                            //           DateTime.now()),
                                            //   style: AppTextStyle
                                            //       .normalRegular10
                                            //       .copyWith(
                                            //           height: 0,
                                            //           color: primaryWhite
                                            //               .withOpacity(.7)),
                                            // ),
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
                            controller.selectedFileList.value.clear();
                            File? file = await CommonMethod.pickFile();
                            if (file != null) {
                              String? path =
                                  await controller.uploadFile(context, file);
                              if (path != null) {
                                controller.selectedFileList.value.add(path);
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

              // Container(
              //   color: Colors.grey[200],
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 15,
              //     vertical: 5
              //   ),
              //   child: Row(
              //     children: [

              //       Flexible(
              //         child: TextField(
              //           controller: messageController,
              //           maxLines: null,
              //           decoration: InputDecoration(
              //             border: InputBorder.none,
              //             hintText: "Enter message"
              //           ),
              //         ),
              //       ),

              //       Row(
              //         children: [
              //           IconButton(
              //             onPressed: () {
              //               // sendMessage();
              //               // CustomDialog.showSimpleDialog(
              //               //     child: Row(
              //               //       children: [
              //               //         IconButton(
              //               //           onPressed: () {},
              //               //           icon: Icon(Icons.image),
              //               //         ),
              //               //       ],
              //               //     ),
              //               //     context: context);
              //             },
              //             icon: Icon(
              //               Icons.attach_file,
              //               color: Colors.black,
              //             ),
              //           ),
              //           IconButton(
              //             onPressed: () {
              //               // sendMessage();
              //               // CustomDialog.showSimpleDialog(
              //               //     child: Row(
              //               //       children: [
              //               //         IconButton(
              //               //           onPressed: () {},
              //               //           icon: Icon(Icons.image),
              //               //         ),
              //               //       ],
              //               //     ),
              //               //     context: context);
              //             },
              //             icon: Icon(
              //               Icons.attach_file,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ],
              //       ),

              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
