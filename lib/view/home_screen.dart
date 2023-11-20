import 'dart:async';
import 'dart:developer';
import 'package:chatapp/Drawer/navigation_drawer.dart';
import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/image_view_widget.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/utils/common_method.dart';
import 'package:chatapp/view/chat_bot_screen.dart';
import 'package:chatapp/view/edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../componet/common_showAlert.dart';
import '../controller/theme_controller.dart';
import '../componet/app_text_style.dart';
import '../componet/network_image_widget.dart';
import '../componet/shadow_container_widget.dart';
import '../controller/home_controller.dart';
import '../models/message_model.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.put(HomeController());
  ThemeController themeController = Get.put(ThemeController());
  Locale? selectedLocale = AppPreferences().getLocaleFromPreferences();
  StreamController<List<MessageModel>> _unreadMessagesStreamController =
      StreamController<List<MessageModel>>.broadcast();
  String? userId = AppPreferences.getUiId();

  Stream<List<MessageModel>> get unreadMessagesStream =>
      _unreadMessagesStreamController.stream;
  @override
  void initState() {
    controller.refreshPage();
    super.initState();
  }

  final List<Map<String, dynamic>> locale = [
    {'name': 'ENGLISH', 'locale': Locale('en', 'US')},
    {'name': 'ગુજરાતી', 'locale': Locale('gu', 'IN')},
    {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
  ];

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
    controller.chatRoomsStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authController = Get.put(AuthController());
    log('---currentUserId---${AppPreferences.getUiId()}');
    return Obx(() {
      return Scaffold(
        backgroundColor:
            themeController.isDark.value ? primaryBlack : primaryWhite,
        drawer: CustomDrawer(
          logout: () {
            // MyAlertDialog.showLogoutDialog(context);
            MyAlertDialog.showDialogWithOption(
                context, 'Continue'.tr, 'Cancel'.tr, () {
              authController.phoneTxtController.text = '';
              authController.otpTxtController.text = '';
              CommonMethod.logoutUser();
            }, () {
              Get.back();
            }, 'logout_desc'.tr);
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
        ),
        appBar: CommonAppBar(
          title: "head".tr,
          hideLeadingIcon: true,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadowContainerWidget(
                borderColor: themeController.isDark.value
                    ? primaryBlack
                    : greyBorderColor,
                color: themeController.isDark.value
                    ? primaryBlack
                    : primaryWhite,
                shadowColor: themeController.isDark.value
                    ? Colors.transparent
                    : greyBorderColor.withOpacity(.5),
                padding: 0,
                widget: ListTile(
                    tileColor: themeController.isDark.value
                        ? primaryBlack
                        : primaryWhite,
                    onTap: () async {
                                        Get.to(() => ChatBotScreen());

                    },
                    leading: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: Colors.transparent,
                              content: Hero(
                                  transitionOnUserGestures: true,
                                  tag: 'userProfile',
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                      Get.to(
                                        () => ImageViewWidget(
                                          imageUrl:
                                              'https://images.unsplash.com/photo-1684493735679-359868df0e18?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                          profileImg: true,
                                          isFile: false,
                                          text: "Ai ChatBot",
                                        ),
                                      );
                                    },
                                    child: Image.network(
                                        'https://images.unsplash.com/photo-1684493735679-359868df0e18?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                  )),
                            );
                          },
                        );
                      },
                      child: NetworkImageWidget(
                          height: 50,
                          width: 50,
                          borderRadius: BorderRadius.circular(50),
                          errorIcon: CupertinoIcons.profile_circled,
                          imageUrl:
                              'https://images.unsplash.com/photo-1684493735679-359868df0e18?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [],
                    ),
                    title: Row(
                      children: [
                        Text('Ai ChatBot',
                            style: themeController.isDark.value
                                ? AppTextStyle.darkNormalBold16
                                : AppTextStyle.lightNormalBold16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(
                            Icons.verified_rounded,
                            color: greenColor,
                          ),
                        )
                      ],
                    ),
                    subtitle: Text(
                      "Say hi to chatbot",
                      style: AppTextStyle.normalRegular12
                          .copyWith(color: greyColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Recent chats",
                  style: AppTextStyle.normalBold14.copyWith(color: greyColor),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoomModel = controller.chatRooms[index];
                    return chatRoomModel.usersIds == null
                        ? SizedBox()
                        : FutureBuilder(
                            future: CommonMethod.getTargetUserModel(
                                chatRoomModel.usersIds!),
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
                                          return SizedBox();
                                        }
                                        if (!snapshot.hasData ||
                                            !snapshot.data!.exists) {
                                          return SizedBox();
                                        }
                                        final userData = UserModel.fromMap(
                                            snapshot.data!.data()
                                                as Map<String, dynamic>);
                                        return Obx(
                                          () {
                                            return ShadowContainerWidget(
                                              borderColor:
                                                  themeController.isDark.value
                                                      ? primaryBlack
                                                      : greyBorderColor,
                                              color:
                                                  themeController.isDark.value
                                                      ? primaryBlack
                                                      : primaryWhite,
                                              shadowColor:
                                                  themeController.isDark.value
                                                      ? Colors.transparent
                                                      : greyBorderColor
                                                          .withOpacity(.5),
                                              padding: 0,
                                              widget: ListTile(
                                                  tileColor: themeController
                                                          .isDark.value
                                                      ? primaryBlack
                                                      : primaryWhite,
                                                  onTap: () async {
                                                    log('====ontap');
                                                    Get.to(() => ChatRoomScreen(
                                                        chatRoom: chatRoomModel,
                                                        targetUser:
                                                            chatRoomModel
                                                                    .isGroup!
                                                                ? null
                                                                : userData));
                                                  },
                                                  onLongPress: () {
                                                    MyAlertDialog
                                                        .showDialogWithOption(
                                                            context,
                                                            'continue'.tr,
                                                            'cancel'.tr, () {
                                                      log("====Current user id$userId");
                                                      // CommonMethod.deleteChatroom(
                                                      //     chatRoomModel.chatRoomId!);
                                                      //      CommonMethod.deleteChatroomUser(chatRoomModel.chatRoomId!,userId!);
                                                      CommonMethod
                                                          .deleteChatroomUser3(
                                                              chatRoomModel
                                                                  .chatRoomId!,
                                                              userId!);
                                                      Get.back();
                                                      log('====Delete Successfully ${chatRoomModel.chatRoomId!}');
                                                    }, () {
                                                      Get.back();
                                                    }, 'delete_desc'.tr);
                                                  },
                                                  leading: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            content: Hero(
                                                                transitionOnUserGestures:
                                                                    true,
                                                                tag:
                                                                    'userProfile',
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Get.back();
                                                                    Get.to(
                                                                      () =>
                                                                          ImageViewWidget(
                                                                        imageUrl: chatRoomModel.isGroup!
                                                                            ? chatRoomModel.groupImage ??
                                                                                'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSSvQXJzciKs02q4YcgDAebrBW9nFa6wMnjWzeCkNPGopgObID3'
                                                                            : userData.profilePic ??
                                                                                '',
                                                                        profileImg:
                                                                            true,
                                                                        isFile:
                                                                            false,
                                                                        text: chatRoomModel.isGroup!
                                                                            ? chatRoomModel.groupName ??
                                                                                "Group"
                                                                            : userData.fullName.toString(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Image
                                                                      .network(
                                                                    chatRoomModel
                                                                            .isGroup!
                                                                        ? chatRoomModel.groupImage ??
                                                                            'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSSvQXJzciKs02q4YcgDAebrBW9nFa6wMnjWzeCkNPGopgObID3'
                                                                        : userData.profilePic ??
                                                                            '',
                                                                  ),
                                                                )),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: NetworkImageWidget(
                                                        height: 50,
                                                        width: 50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                50),
                                                        errorIcon: chatRoomModel
                                                                .isGroup!
                                                            ? CupertinoIcons
                                                                .group_solid
                                                            : CupertinoIcons
                                                                .profile_circled,
                                                        imageUrl: chatRoomModel
                                                                .isGroup!
                                                            ? chatRoomModel
                                                                .groupImage
                                                            : userData
                                                                    .profilePic ??
                                                                ''),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      StreamBuilder<
                                                          List<MessageModel>>(
                                                        stream: CommonMethod
                                                            .unreadMessagesStream(
                                                                chatRoomModel
                                                                    .chatRoomId!),
                                                        builder: (context,
                                                            snapshot) {
                                                          return snapshot.data !=
                                                                      null &&
                                                                  snapshot.data!
                                                                      .isNotEmpty
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color:
                                                                          greenColor, // Choose your preferred badge background color
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        snapshot
                                                                            .data!
                                                                            .length
                                                                            .toString(),
                                                                        style: AppTextStyle
                                                                            .normalSemiBold14
                                                                            .copyWith(color: primaryWhite),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : SizedBox();
                                                        },
                                                      ),
                                                      Column(children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Text(
                                                            CommonMethod.formatDateTime(
                                                                chatRoomModel
                                                                        .lastSeen ??
                                                                    DateTime
                                                                        .now()),
                                                            style: AppTextStyle
                                                                .normalRegular12
                                                                .copyWith(
                                                                    color:
                                                                        greyColor),
                                                          ),
                                                        ),
                                                        height08,
                                                        if (chatRoomModel
                                                                .isGroup ==
                                                            false)
                                                          Text(
                                                            userData.status ==
                                                                    'typing'
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
                                                                    color: userData.status ==
                                                                            'offline'
                                                                        ? redColor
                                                                        : greenColor),
                                                          ),
                                                      ]),
                                                    ],
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                            chatRoomModel
                                                                    .isGroup!
                                                                ? chatRoomModel
                                                                        .groupName ??
                                                                    "Group"
                                                                : userData
                                                                    .fullName
                                                                    .toString(),
                                                            style: themeController
                                                                    .isDark
                                                                    .value
                                                                ? AppTextStyle
                                                                    .darkNormalBold16
                                                                : AppTextStyle
                                                                    .lightNormalBold16),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: chatRoomModel
                                                                  .lastMessage ==
                                                              null &&
                                                          chatRoomModel.isGroup!
                                                      ? FutureBuilder<String>(
                                                          future: CommonMethod
                                                              .getMembersName(
                                                                  chatRoomModel
                                                                      .usersIds!),
                                                          builder: (context,
                                                              snapshot) {
                                                            return snapshot !=
                                                                        null &&
                                                                    snapshot.data !=
                                                                        null
                                                                ? Text(
                                                                    '${snapshot.data}',
                                                                    style: AppTextStyle
                                                                        .normalRegular12
                                                                        .copyWith(
                                                                            color:
                                                                                greyColor),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )
                                                                : SizedBox();
                                                          },
                                                        )
                                                      : Text(
                                                          chatRoomModel
                                                                  .lastMessage ??
                                                              "Say hi to your new friend!",
                                                          style: AppTextStyle
                                                              .normalRegular12
                                                              .copyWith(
                                                                  color:
                                                                      greyColor),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => SearchScreen());
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
