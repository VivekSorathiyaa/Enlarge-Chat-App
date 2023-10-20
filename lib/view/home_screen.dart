// import 'dart:developer';

// import 'package:chatapp/componet/app_text_style.dart';
// import 'package:chatapp/componet/network_image_widget.dart';
// import 'package:chatapp/componet/shadow_container_widget.dart';
// import 'package:chatapp/models/chat_room_model.dart';
// import 'package:chatapp/models/user_model.dart';
// import 'package:chatapp/utils/colors.dart';
// import 'package:chatapp/utils/static_decoration.dart';
// import 'package:chatapp/view/chat_room_screen.dart';
// import 'package:chatapp/view/search_screen.dart';
// import 'package:chatapp/view/login_screen.dart';
// import 'package:chatapp/utils/app_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../utils/common_method.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   String? currentUserId;

//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);

//     CommonMethod.updateChatActiveStatus(null);
//     CommonMethod.setOnlineStatus();
//     refreshPage();
//     super.initState();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed) {
//       print("=========App is back to the foreground");
//       CommonMethod.setOnlineStatus();
//     } else if (state == AppLifecycleState.paused) {
//       // App is going into the background
//       print("=========App is back to the background");
//       CommonMethod.setOfflineStatus();
//     } else if (state == AppLifecycleState.inactive) {
//       // App is inactive (e.g., during phone call)
//       print("========App is back to the inactive");
//       CommonMethod.setOfflineStatus();
//     } else if (state == AppLifecycleState.detached) {
//       // App is closed or terminated
//       CommonMethod.setOfflineStatus();

//       print("=======App is back to the terminated");
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future refreshPage() async {
//     currentUserId = await AppPreferences.getUiId();
//     await CommonMethod.refreshToken();
//   }

//   @override
//   Widget build(BuildContext context) {
//     log('---currentUserId---${AppPreferences.getUiId()}');
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Chat App - ${AppPreferences.getFullName()}"),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.popUntil(context, (route) => route.isFirst);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) {
//                   return LoginScreen();
//                 }),
//               );
//             },
//             icon: Icon(Icons.exit_to_app),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Container(
//           child: StreamBuilder(
//             stream:
//                 FirebaseFirestore.instance.collection("chatrooms").snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.active) {
//                 if (snapshot.hasData) {
//                   QuerySnapshot chatRoomSnapshot =
//                       snapshot.data as QuerySnapshot;
//                   return ListView.builder(
//                     itemCount: chatRoomSnapshot.docs.length,
//                     itemBuilder: (context, index) {
//                       ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
//                           chatRoomSnapshot.docs[index].data()
//                               as Map<String, dynamic>);

//                       return chatRoomModel.users == null
//                           ? SizedBox()
//                           : FutureBuilder(
//                               future: CommonMethod.getTargetUserModel(
//                                   chatRoomModel.users!),
//                               builder: (context, userData) {
//                                 if (userData.connectionState ==
//                                     ConnectionState.waiting) {
//                                   // Handle loading state
//                                   return Center(
//                                     child: CircularProgressIndicator(
//                                       color: primaryColor,
//                                     ),
//                                   );
//                                 } else if (userData.connectionState ==
//                                     ConnectionState.done) {
//                                   if (userData.hasError) {
//                                     // Handle error state
//                                     return Text("Error: ${userData.error}");
//                                   }
//                                   if (userData.data != null) {
//                                     // Handle data available state
//                                     UserModel targetUser =
//                                         userData.data as UserModel;

// return ShadowContainerWidget(
//   padding: 0,
//   widget: ListTile(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) {
//             return ChatRoomScreen(
//               chatRoomId:
//                   chatRoomModel.chatRoomId!,
//               targetUser: targetUser,
//             );
//           }),
//         );
//       },
//       leading: NetworkImageWidget(
//           height: 50,
//           width: 50,
//           isProfile: true,
//           borderRadius:
//               BorderRadius.circular(50),
//           imageUrl:
//               targetUser.profilepic ?? ''),
//       trailing: Column(children: [
//         Padding(
//           padding: const EdgeInsets.only(
//               top: 8.0),
//           child: Text(
//             CommonMethod.formatDateTime(
//                 chatRoomModel.lastSeen ??
//                     DateTime.now()),
//             style: AppTextStyle
//                 .normalRegular12
//                 .copyWith(color: greyColor),
//           ),
//         ),
//         height08,
//         Text(
//           targetUser.status == 'typing'
//               ? "typing..."
//               : targetUser.status ==
//                       "online"
//                   ? "online"
//                   : targetUser.status ==
//                           "offline"
//                       ? "offline"
//                       : '-',
//           style: AppTextStyle
//               .normalRegular12
//               .copyWith(
//                   color:
//                       targetUser.status ==
//                               'offline'
//                           ? redColor
//                           : greenColor),
//         ),
//       ]),
//       title: Row(
//         children: [
//           Flexible(
//             child: Text(
//               targetUser.fullname
//                   .toString(),
//               style:
//                   AppTextStyle.normalBold16,
//             ),
//           ),
//         ],
//       ),
//       subtitle: Text(
//         chatRoomModel.lastMessage ??
//             "Say hi to your new friend!",
//         style: AppTextStyle.normalRegular12
//             .copyWith(color: greyColor),
//       )),
// );
//                                   } else {
//                                     // Handle data is null state
//                                     return Container();
//                                   }
//                                 }
//                                 // Handle other connection states (e.g., none)
//                                 return Container();
//                               },
//                             );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text(snapshot.error.toString()),
//                   );
//                 } else {
//                   return Center(
//                     child: Text("No Chats"),
//                   );
//                 }
//               } else {
//                 return Container();
//               }
//             },
//           ),
//         ),
//       ),
//   floatingActionButton: FloatingActionButton(
//     onPressed: () {
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return SearchScreen();
//       }));
//     },
//     child: Icon(Icons.search),
//   ),
// );
//   }
// }

import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/app_text_style.dart';
import '../componet/network_image_widget.dart';
import '../componet/shadow_container_widget.dart';
import '../controller/home_controller.dart';
import '../models/user_model.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/static_decoration.dart';
import 'chat_room_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    // Configure the background fetch
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 2, // Time in minutes
          stopOnTerminate: false,
          startOnBoot: true,
        ),
        onBackgroundFetch);
  }

  void onBackgroundFetch(String taskId) async {
    // Check if the app is terminated

    if (taskId == "myTask") {
      // This is your custom task ID
      // The app is in a background state
      // Perform your background tasks here
      BackgroundFetch.finish(taskId);
    } else {
      // This is a terminated state
      await CommonMethod.setOfflineStatus();
    }
    // Perform your background tasks here
    // This code will run even when the app is terminated
    BackgroundFetch.finish(taskId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is back to the foreground
      CommonMethod.setOnlineStatus();
    } else if (state == AppLifecycleState.paused) {
      // App is going into the background
      CommonMethod.setOfflineStatus();
    } else if (state == AppLifecycleState.detached) {
      // App is closed or terminated
      CommonMethod.setOfflineStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App - ${AppPreferences.getFullName()}"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => LoginScreen());
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            return ListView.builder(
              itemCount: controller.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoomModel = controller.chatRooms[index];
                return chatRoomModel.users == null
                    ? SizedBox()
                    : FutureBuilder(
                        future: CommonMethod.getTargetUserModel(
                            chatRoomModel.users!),
                        builder: (context, snapshots) {
                          UserModel? targetUser;
                          if (snapshots.data != null) {
                            targetUser = snapshots.data as UserModel;
                          }
                          return targetUser == null
                              ? SizedBox()
                              :
                              
                               StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(targetUser.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return SizedBox();
                                    }

                                    final userData = UserModel.fromMap(
                                        snapshot.data!.data()
                                            as Map<String, dynamic>);
    
                                    // Use userData to display user details
                              return ShadowContainerWidget(
                                padding: 0,
                                widget: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return ChatRoomScreen(
                                                  chatRoomId:
                                                      chatRoomModel.chatRoomId!,
                                                  targetUser: userData,
                                                );
                                              }),
                                            );
                                          },
                                          leading: NetworkImageWidget(
                                              height: 50,
                                              width: 50,
                                              isProfile: true,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              imageUrl:
                                                  userData.profilepic ?? ''),
                                          trailing: Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                CommonMethod.formatDateTime(
                                                    chatRoomModel.lastSeen ??
                                                        DateTime.now()),
                                                style: AppTextStyle
                                                    .normalRegular12
                                                    .copyWith(color: greyColor),
                                              ),
                                            ),
                                            height08,
                                            Text(
                                              userData.status == 'typing'
                                                  ? "typing..."
                                                  : userData.status == "online"
                                                      ? "online"
                                                      : userData.status ==
                                                              "offline"
                                                          ? "offline"
                                                          : '-',
                                              style: AppTextStyle
                                                  .normalRegular12
                                                  .copyWith(
                                                      color: userData.status ==
                                                              'offline'
                                                          ? redColor
                                                          : greenColor),
                                            ),
                                          ]),
                                          title: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  userData.fullname.toString(),
                                                  style:
                                                      AppTextStyle.normalBold16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            chatRoomModel.lastMessage ??
                                                "Say hi to your new friend!",
                                            style: AppTextStyle.normalRegular12
                                                .copyWith(color: greyColor),
                                          )),
                                    );
                                  },
                                );

                        
                      
                        }
                  );
              },
            );
          },
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