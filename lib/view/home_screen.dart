import 'dart:developer';


import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/view/chat_room_screen.dart';
import 'package:chatapp/view/search_screen.dart';
import 'package:chatapp/view/login_screen.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/common_method.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String? currentUserId;

  @override
  void initState() {
    refreshPage();
    super.initState();


  }

  Future refreshPage() async {
   await AppPreferences.getFirebaseMessagingToken();
   await AppPreferences.uploadData();

    currentUserId = await AppPreferences.getUiId();
  }


  @override
  Widget build(BuildContext context) {
    log('---currentUserId---${AppPreferences.getUiId()}');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                  return LoginScreen();
                  }
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${AppPreferences.getUiId()}",
                    isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.active) {
                if(snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);
                      Map<String, dynamic> participants = chatRoomModel.participants!;
                      List<String> participantKeys = participants.keys.toList();
                    
                      participantKeys.remove(AppPreferences.getUiId());

                      // return FutureBuilder(
                      //   future: CommonMethod.getUserModelById(participantKeys[0]),
                      //   builder: (context, userData) {
                      //     if(userData.connectionState == ConnectionState.done) {
                      //       if(userData.data != null) {
                      //         UserModel targetUser = userData.data as UserModel;
                      //         return ShadowContainerWidget(
                      //           padding: 0,
                      //           widget: ListTile(
                      //             onTap: () {
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(builder: (context) {
                      //                   return ChatRoomScreen(
                      //                     chatroom: chatRoomModel,
                      //                     targetUser: targetUser,
                      //                   );
                      //                 }),
                      //               );
                      //             },
                      //             leading: NetworkImageWidget(
                      //               height: 50,
                      //               width: 50,
                      //               borderRadius: BorderRadius.circular(50),
                      //               imageUrl: targetUser.profilepic
                      //             ),
                      //             trailing: Column(children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.only(top: 8.0),
                      //                 child: Text(
                      //                   CommonMethod.formatDateTime(
                      //                       chatRoomModel.lastSeen ??
                      //                           DateTime.now()),
                      //                   style: AppTextStyle.normalRegular12
                      //                       .copyWith(color: greyColor),
                      //                 ),
                      //               ),
                      //             ]),
                      //             title: Text(
                      //               targetUser.fullname.toString(),
                      //               style: AppTextStyle.normalBold16,
                      //             ),
                      //             subtitle: (chatRoomModel.lastMessage
                      //                         .toString() !=
                      //                     "")
                      //                 ? Text(
                      //                     chatRoomModel.lastMessage.toString(),
                      //                     style: AppTextStyle.normalRegular12
                      //                         .copyWith(color: greyColor),
                      //                   )
                      //                 : Text(
                      //                     "Say hi to your new friend!",
                      //                     style: TextStyle(
                      //                       color: Theme.of(context)
                      //                           .colorScheme
                      //                           .secondary,
                      //                     ),
                      //                   ),
                      //           ),
                      //         );
                      //       }
                      //       else {
                      //         return Container();
                      //       }
                      //     }
                      //     else {
                      //       return Container();
                      //     }
                      //   },
                      // );

                      FutureBuilder(
                        future: CommonMethod.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState == ConnectionState.waiting) {
                            // Handle loading state
                            return Container();
                          } else if (userData.connectionState == ConnectionState.done) {
                            if (userData.hasError) {
                              // Handle error state
                              return Text("Error: ${userData.error}");
                            }
                            if (userData.data != null) {
                              // Handle data available state
                              UserModel targetUser = userData.data as UserModel;
                              // return ShadowContainerWidget(
                              //   // ...
                              // );
                              return ShadowContainerWidget(
                                padding: 0,
                                widget: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return ChatRoomScreen(
                                          chatroom: chatRoomModel,
                                          targetUser: targetUser,
                                        );
                                      }),
                                    );
                                  },
                                  leading: NetworkImageWidget(
                                      height: 50,
                                      width: 50,
                                      borderRadius: BorderRadius.circular(50),
                                      imageUrl: targetUser.profilepic
                                  ),
                                  trailing: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        CommonMethod.formatDateTime(
                                            chatRoomModel.lastSeen ??
                                                DateTime.now()),
                                        style: AppTextStyle.normalRegular12
                                            .copyWith(color: greyColor),
                                      ),
                                    ),
                                  ]),
                                  title: Text(
                                    targetUser.fullname.toString(),
                                    style: AppTextStyle.normalBold16,
                                  ),
                                  subtitle: (chatRoomModel.lastMessage
                                      .toString() !=
                                      "")
                                      ? Text(
                                    chatRoomModel.lastMessage.toString(),
                                    style: AppTextStyle.normalRegular12
                                        .copyWith(color: greyColor),
                                  )
                                      : Text(
                                    "Say hi to your new friend!",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Handle data is null state
                              return Container();
                            }
                          }
                          // Handle other connection states (e.g., none)
                          return Container();
                        },
                      );

                    },
                  );
                }
                else if(snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              }
              else {
                return Center(
                  child: CircularProgressIndicator(strokeWidth: 2,color: Colors.black87,),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchScreen();
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}