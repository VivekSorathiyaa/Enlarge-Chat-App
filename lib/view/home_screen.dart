import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:chatapp/Drawer/navigation_drawer.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/common_showAlert.dart';
import '../controller/theme_controller.dart';
import '../componet/app_text_style.dart';
import '../componet/network_image_widget.dart';
import '../componet/shadow_container_widget.dart';
import '../controller/home_controller.dart';
import '../models/user_model.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/static_decoration.dart';
import 'chat_room_screen.dart';
import 'create_group_screen.dart';

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
  Locale? selectedLocale;
  String? fullname = AppPreferences.getFullName();
  String? phone = AppPreferences.getPhone();
  String? profilePic = AppPreferences.getProfilePic();
  Locale? savedLocale = AppPreferences().getLocaleFromPreferences();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    selectedLocale = savedLocale;
    super.initState();
  }
  // void initState() {
  //   WidgetsBinding.instance.addObserver(this);
  //   super.initState();
  //   initPlatformState();

  //                 onTap: () {
  //                   print(locale[index]['name']);
  //                   updateLanguage(locale[index]['locale']);
  //                   Navigator.of(context).pop(); // Close the dialog after selection
  //                 },
  //               );
  //             }),
  //           ),
  //         );
  //       }
  //   );
  // }

  final List<Map<String, dynamic>> locale = [
    {'name': 'ENGLISH', 'locale': Locale('en', 'US')},
    {'name': 'ગુજરાતી', 'locale': Locale('gu', 'IN')},
    {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
  ];

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

  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
    AppPreferences.setLocal(locale);

    setState(() {
      selectedLocale = locale;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    log('---currentUserId---${AppPreferences.getUiId()}');

    return Obx(() {
      return Scaffold(
        drawer: CustomDrawer(
            logout: () {
              MyAlertDialog.showLogoutDialog(context);
            },
            changeLang: () {
              MyAlertDialog.showLanguageDialog(
                context,
                locale,
                selectedLocale!,
                (Locale newLocale) {
                  updateLanguage(newLocale);
                },
              );
            },
            people: () => Get.to(() => SearchScreen()),
            myAccount: () {
              Get.to(() => EditProfile());
            },
            chats: () {}),
        appBar: AppBar(
          centerTitle: true,
          title: Text("head".tr),
          actions: [
            IconButton(
              onPressed: () async {
                Get.to(() => CreateGroupScreen());
              },
              icon: Icon(Icons.group),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: controller.chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoomModel = controller.chatRooms[index];
              return chatRoomModel.users == null
                  ? SizedBox()
                  : FutureBuilder(
                      future:
                          CommonMethod.getTargetUserModel(chatRoomModel.users!),
                      builder: (context, snapshots) {
                        UserModel? targetUser;
                        if (snapshots.data != null) {
                          targetUser = snapshots.data as UserModel;
                        }
                        return targetUser == null
                            ? SizedBox()
                            : StreamBuilder<DocumentSnapshot>(
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
                                  return Obx(
                                    () {
                                      return ShadowContainerWidget(
                                        borderColor:
                                            themeController.isDark.value
                                                ? primaryBlack
                                                : greyBorderColor,
                                        color: themeController.isDark.value
                                            ? primaryBlack
                                            : primaryWhite,
                                        shadowColor: themeController
                                                .isDark.value
                                            ? Colors.transparent
                                            : greyBorderColor.withOpacity(.5),
                                        padding: 0,
                                        widget: ListTile(
                                            tileColor:
                                                themeController.isDark.value
                                                    ? primaryBlack
                                                    : primaryWhite,
                                            onTap: () {
                                              Get.to(() => ChatRoomScreen(
                                                  chatRoom: chatRoomModel,
                                                  targetUser:
                                                      chatRoomModel.isGroup!
                                                          ? null
                                                          : userData));
                                            },
                                            leading: NetworkImageWidget(
                                                height: 50,
                                                width: 50,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                errorIcon: chatRoomModel
                                                        .isGroup!
                                                    ? CupertinoIcons.group_solid
                                                    : CupertinoIcons
                                                        .profile_circled,
                                                imageUrl: chatRoomModel.isGroup!
                                                    ? chatRoomModel.groupImage
                                                    : userData.profilepic ??
                                                        ''),
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
                                                      .copyWith(
                                                          color: greyColor),
                                                ),
                                              ),
                                              height08,
                                              if (chatRoomModel.isGroup ==
                                                  false)
                                                Text(
                                                  userData.status == 'typing'
                                                      ? "typing..."
                                                      : userData.status ==
                                                              "online"
                                                          ? "online"
                                                          : userData.status ==
                                                                  "offline"
                                                              ? "offline"
                                                              : '-',
                                                  style: AppTextStyle
                                                      .normalRegular12
                                                      .copyWith(
                                                          color:
                                                              userData.status ==
                                                                      'offline'
                                                                  ? redColor
                                                                  : greenColor),
                                                ),
                                            ]),
                                            title: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                      chatRoomModel.isGroup!
                                                          ? chatRoomModel
                                                                  .groupName ??
                                                              "Group"
                                                          : userData.fullname
                                                              .toString(),
                                                      style: themeController.isDark
                                                              .value
                                                          ? AppTextStyle
                                                              .darkNormalBold16
                                                          : AppTextStyle
                                                              .lightNormalBold16),
                                                ),
                                              ],
                                            ),
                                            subtitle: Text(
                                              chatRoomModel.lastMessage ??
                                                  (chatRoomModel.isGroup!
                                                      ? "New Group"
                                                      : "Say hi to your new friend!"),
                                              style: AppTextStyle
                                                  .normalRegular12
                                                  .copyWith(color: greyColor),
                                            )),
                                      );
                                    },
                                  );
                                });
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
    });
  }

  Widget headerWidget(String profilePic, String fullName, String phone) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.0), // Adjust the padding as needed
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Background color of the circle
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profilePic),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(
              height: 10,
            ),
            Text(phone, style: TextStyle(fontSize: 14, color: Colors.white))
          ],
        )
      ],
    );
  }
}
