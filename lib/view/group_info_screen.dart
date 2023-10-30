import 'package:chatapp/componet/custom_dialog.dart';
import 'package:chatapp/componet/user_widget.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/select_contact_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/app_text_style.dart';
import '../componet/network_image_widget.dart';
import '../controller/group_controller.dart';
import '../utils/colors.dart';
import '../utils/static_decoration.dart';

class GroupInfoScreen extends StatefulWidget {
  final String chatRoomId;
  const GroupInfoScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  Stream<ChatRoomModel?>? chatRoomStream;
  var controller = Get.put(GroupController());

  @override
  void initState() {
    super.initState();

    // Initialize the chatRoomStream with a Firestore stream
    chatRoomStream = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoomId)
        .snapshots()
        .map((snapshot) => ChatRoomModel.fromMap(snapshot.data()!));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatRoomModel?>(
        stream: chatRoomStream!,
        builder: (context, chatRoomSnapshot) {
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
              title: chatRoomSnapshot.data == null
                  ? SizedBox()
                  : GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NetworkImageWidget(
                            width: 42,
                            height: 42,
                            borderRadius: BorderRadius.circular(42),
                            imageUrl:
                                chatRoomSnapshot.data!.groupImage.toString(),
                          ),
                          width15,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatRoomSnapshot.data!.groupName.toString(),
                                style: AppTextStyle.regularBold.copyWith(
                                    color: primaryWhite,
                                    fontSize: 16,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
            body: chatRoomSnapshot.data == null
                ? SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Members : ${(chatRoomSnapshot.data!.usersIds!.length)}',
                                  style: AppTextStyle.normalBold14,
                                ),
                              ),
                              TextButton.icon(
                                  onPressed: () {
                                    Get.to(() => SelectContactScreen())!
                                        .then((value) {
                                      print(
                                          '---controller.selectUserList.value----${controller.selectUserList.value}');
                                      for (var data
                                          in controller.selectUserList.value) {
                                        addUserToChatroom(widget.chatRoomId,
                                            data.uid.toString());
                                      }
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return primaryColor.withOpacity(
                                              .8); // Color for the pressed state
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
                                    style: AppTextStyle.normalBold14
                                        .copyWith(color: primaryWhite),
                                  ))
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              FutureBuilder<List<UserModel>>(
                                future: CommonMethod.getUserListByIds(
                                    chatRoomSnapshot.data!.usersIds!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: snapshot.data!.map((element) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: UserWidget(
                                            user: element,
                                            trailing: IconButton(
                                              icon: Icon(Icons.close_rounded),
                                              onPressed: () {
                                                CustomDialog
                                                    .showConfirmationDialog(
                                                        onOkPress: () {
                                                          removeUserFromChatroom(
                                                              chatRoomSnapshot
                                                                  .data!
                                                                  .chatRoomId
                                                                  .toString(),
                                                              element.uid
                                                                  .toString());
                                                          Get.back();
                                                        },
                                                        context: context);
                                                // groupController.selectUserList.value
                                                //     .remove(element);
                                                // groupController.selectUserList.refresh();
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                              height30
                            ],
                          ),
                        ),
                      ]),
          );
        }
    );
  }
}
Future<void> removeUserFromChatroom(
    String chatroomID, String userIdToRemove) async {
  try {
    final chatroomRef =
        FirebaseFirestore.instance.collection('chatrooms').doc(chatroomID);

    await chatroomRef.update({
      'usersIds': FieldValue.arrayRemove([userIdToRemove]),
    });

    print('User $userIdToRemove removed from the chatroom.');
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> addUserToChatroom(String chatroomID, String userIdToAdd) async {
  print("====addUserToChatroom====");
  try {
    final chatroomRef =
        FirebaseFirestore.instance.collection('chatrooms').doc(chatroomID);

    await chatroomRef.update({
      'usersIds': FieldValue.arrayUnion([userIdToAdd]),
    });

      //     MessageModel newMessage = MessageModel(
      //     sender: AppPreferences.getUiId(),
      //     text: '',
      //     messageType:  0,
      //     media: null,
      //     seen: false,
      //     chatRoomId: chatroomID,
      //     createdAt: DateTime.now(),
      //     messageId: uuid.v1());
      // await CommonMethod.addMessage(newMessage);
    print('User $userIdToAdd added to the chatroom.');
  } catch (e) {
    print('Error: $e');
  }
}
