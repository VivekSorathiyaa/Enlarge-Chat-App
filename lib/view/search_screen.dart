import 'dart:developer';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/view/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen(
      {Key? key})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? currentUserId;
  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  Future refreshPage() async {
    currentUserId = await AppPreferences.getUiId();
  }
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${currentUserId}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          currentUserId!: true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> phoneQuery = FirebaseFirestore.instance
        .collection("users")
        .where("phone", isGreaterThanOrEqualTo: searchController.text)
        .where("phone", isLessThanOrEqualTo: searchController.text + '\uf8ff')
        .snapshots();

    Stream<QuerySnapshot> fullnameQuery = FirebaseFirestore.instance
        .collection("users")
        .where("fullname", isGreaterThanOrEqualTo: searchController.text)
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
                            if (phoneSnapshot.hasData ||
                                fullnameSnapshot.hasData) {
                              QuerySnapshot phoneResult = phoneSnapshot.data!;
                              QuerySnapshot fullnameResult =
                                  fullnameSnapshot.data!;
              
                              // QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
              
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
                                        ChatRoomModel? chatroomModel =
                                            await getChatroomModel(
                                                searchedUser[index]);
              
                                        if (chatroomModel != null) {
                                          Navigator.pop(context);
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatRoomScreen(
                                              targetUser: searchedUser[index],
                                              chatroom: chatroomModel,
                                            );
                                          }));
                                        }
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            searchedUser[index].profilepic ?? ""),
                                        backgroundColor: Colors.grey[500],
                                      ),
                                      title: Text(
                                          searchedUser[index].fullname ?? ''),
                                      subtitle:
                                          Text(searchedUser[index].phone ?? ''),
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
                              return CircularProgressIndicator();
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
