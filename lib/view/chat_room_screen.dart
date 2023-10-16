import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  TextEditingController messageController = TextEditingController();
String? currentUserId;
  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  Future refreshPage() async {
    currentUserId = await AppPreferences.getUiId();
  }


 
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      //TYPE-1-simple message
      //TYPE-2-media message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: currentUserId,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
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
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(dataSnapshot.docs[index]
                                      .data() as Map<String, dynamic>);

                              return Row(
                                mainAxisAlignment:
                                    (currentMessage.sender == currentUserId)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                currentUserId)
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        currentMessage.text.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
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
                        controller: messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5, //
                        hintText: "Enter message",
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            File? file = await CommonMethod.pickFile();
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
                          sendMessage();
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
