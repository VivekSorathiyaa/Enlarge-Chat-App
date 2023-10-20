import 'dart:developer';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../componet/network_image_widget.dart';
import '../utils/app_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen(
      {Key? key})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {


  TextEditingController searchController = TextEditingController();


  Future<ChatRoomModel?> getChatroomModel(List<String> targetUserIds) async {
    final List<QuerySnapshot> userSnapshots =
        await Future.wait(targetUserIds.map((userId) {
      return FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: userId)
          .get();
    }));

    if (userSnapshots.every((snapshot) => snapshot.docs.isNotEmpty)) {
      // All target users exist
      final userMap = userSnapshots
          .map((snapshot) => UserModel.fromMap(
              snapshot.docs.first.data() as Map<String, dynamic>))
          .toList();
      final chatRoomSnapshot = await FirebaseFirestore.instance
          .collection("chatrooms")
          .where('users',
              isEqualTo: userMap.map((user) => user.toMap()).toList())
          .get();

      if (chatRoomSnapshot.docs.isNotEmpty) {
        // Chat room already exists
        final chatRoomData =
            chatRoomSnapshot.docs.first.data() as Map<String, dynamic>;
        return ChatRoomModel.fromMap(chatRoomData);
      } else {
        // Create a new chat room
        final newChatroom = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: null,
          lastSeen: null,
          users: userMap,
        );

        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(newChatroom.chatRoomId!)
          .set(newChatroom.toMap());

        return newChatroom;
      }
    } else {
      return null; // Some of the target users do not exist
    }
  }


  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> phoneQuery = FirebaseFirestore.instance
        .collection("users")
        .where("phone", isGreaterThanOrEqualTo: searchController.text)
        .where("phone", isNotEqualTo: AppPreferences.getPhone())
        .where("phone", isLessThanOrEqualTo: searchController.text + '\uf8ff')
        .snapshots();

    Stream<QuerySnapshot> fullnameQuery = FirebaseFirestore.instance
        .collection("users")
        .where("fullname", isGreaterThanOrEqualTo: searchController.text)
        .where("fullname", isNotEqualTo: AppPreferences.getFullName())
        .where("fullname",
            isLessThanOrEqualTo: searchController.text + '\uf8ff')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Phone Number"),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Search"),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: phoneQuery,
                      builder: (context, phoneSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: fullnameQuery,
                          builder: (context, fullnameSnapshot) {
                            if (phoneSnapshot.hasData &&
                                fullnameSnapshot.hasData) {
                              QuerySnapshot phoneResult = phoneSnapshot.data!;
                              QuerySnapshot fullnameResult =
                                  fullnameSnapshot.data!;              
                              if (phoneResult.docs.length > 0 ||
                                  fullnameResult.docs.length > 0) {
                                List<Map<String, dynamic>> userMap = [];

                                if (phoneResult.docs.length > 0) {
                                  for (var data in phoneResult.docs) {
                                    userMap.add(
                                        data.data() as Map<String, dynamic>);
                                  }
                                } else {
                                  for (var data in fullnameResult.docs) {
                                    userMap.add(
                                        data.data() as Map<String, dynamic>);
                                  }
                                }
                                // phoneResult.docs.length > 0
                                //     ? phoneResult.docs[0].data()
                                //         as Map<String, dynamic>
                                //     : fullnameResult.docs[0].data()
                                //         as Map<String, dynamic>;
              
                                List<UserModel> searchedUser = [];
                                for (var data in userMap) {
                                  searchedUser.add(UserModel.fromMap(data));
                                }
                                
              
                                return Column(
                                  children: searchedUser.map((e) {
                                    var index = searchedUser.indexOf(e);
                                    return ListTile(
                                      onTap: () async {
                                        ChatRoomModel? chatRoomModel =
                                            await getChatroomModel([
                                          searchedUser[index].uid!,
                                          AppPreferences.getUiId()!
                                        ]);
              
                                        if (chatRoomModel != null) {
                                          Navigator.pop(context);
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatRoomScreen(
                                              chatRoomId:
                                                  chatRoomModel.chatRoomId!,
                                              targetUser: searchedUser[index],
                                            );
                                          }));
                                        }
                                      },
                                      leading: NetworkImageWidget(
                                        height: 50,
                                        width: 50,
                                        borderRadius: BorderRadius.circular(50),
                                        imageUrl: searchedUser[index]
                                            .profilepic
                                            .toString()),
                                      // leading: CircleAvatar(
                                      //   backgroundImage: NetworkImage(
                                      //       searchedUser[index].profilepic ?? ""),
                                      //   backgroundColor: Colors.grey[500],
                                      // ),
                                      // CircleAvatar(
                                      //   backgroundImage: NetworkImage(
                                      // searchedUser[index].profilepic ??
                                      //     ""),
                                      //   backgroundColor: Colors.grey[500],
                                      // ),
                                      title: Text(
                                          searchedUser[index]
                                          .fullname
                                          .toString()),
                                      subtitle:
                                          Text(
                                          searchedUser[index].phone.toString()),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                    );
                              
                                  }).toList(),
                                );
                                
                              } else {
                                return Text("No results found!");
                              }
                            } else if (phoneSnapshot.hasError ||
                                fullnameSnapshot.hasError) {
                              return Text(
                                  'Error: ${phoneSnapshot.error ?? fullnameSnapshot.error}');
                            } else {
                              return Center(child: CircularProgressIndicator(color: primaryBlack,strokeWidth: 0.5,));
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
