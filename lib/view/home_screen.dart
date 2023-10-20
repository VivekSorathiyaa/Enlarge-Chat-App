

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

  final List locale = [
    {'name': 'ENGLISH', 'locale': Locale('en', 'US')},
    {'name': 'ગુજરાતી', 'locale': Locale('gu', 'IN')},
    {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
    AppPreferences.setLocal(locale);
  }

  buildLanguageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the border radius as needed
            ),
            elevation: 15,
            title: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBlack.withOpacity(0.9),
                        greyColor.withOpacity(0.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10)),
                //  color: primaryBlack.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'chooseLang'.tr,
                    style: TextStyle(color: primaryWhite),
                  ),
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(locale.length, (index) {
                return ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(locale[index]['name']),
                  ),
                  leading: Radio<Locale>(
                    value: locale[index]['locale'],
                    groupValue: selectedLocale,
                    onChanged: (value) {
                      setState(() {
                        selectedLocale = value as Locale?;
                      });
                      print(locale[index]['name']);
                      updateLanguage(value!);
                      Navigator.of(context)
                          .pop(); // Close the dialog after selection
                    },
                  ),
                  splashColor: Colors.grey,
                  onTap: () {
                    print(locale[index]['name']);
                    updateLanguage(locale[index]['locale']);
                    Navigator.of(context)
                        .pop(); // Close the dialog after selection
                  },
                );
              }),
            ),
          );
        });
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
    log('---currentUserId---${AppPreferences.getUiId()}');
    showAlertDialog(BuildContext context) {
      // set up the buttons
      Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(primaryWhite.withOpacity(0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'cancel'.tr,
            style: TextStyle(color: greyColor, fontWeight: FontWeight.w500),
          ),
        ),
        onPressed: () {
          Get.back();
        },
      );

      Widget continueButton = ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(primaryBlack.withOpacity(0.9)),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return LoginScreen();
            }),
          );
        },
        child: Text(
          'continue'.tr,
          style: TextStyle(color: primaryWhite, fontWeight: FontWeight.w500),
        ),
      );
      AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Adjust the border radius as needed
        ),

        alignment: Alignment.center,
        // title: Text("Would you like to continue to logout?"),
        content: Text("logout_desc".tr),
        actions: [
          cancelButton,
          continueButton,
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Scaffold(

   
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              decoration:
                  BoxDecoration(color: Color(0xFF737373).withOpacity(0.9)),
              //   color: primaryColor.withOpacity(0.5),
              height: 30,
            ),

            UserAccountsDrawerHeader(


              currentAccountPictureSize: Size.square(70),

              decoration: BoxDecoration(
                  color: primaryBlack,

              ),

              accountName: Text(fullname!,style: TextStyle(fontSize: 18,color: primaryWhite),),
              accountEmail: Text(phone!,style: TextStyle(fontSize: 13,color: primaryWhite),),
              currentAccountPicture:Container(
         

                // Adjust the size as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryWhite,style: BorderStyle.solid)// Background color of the circle
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(profilePic!),
                  ),
                ),
              ),
            ),

            ListTile(
                leading: Icon(Icons.info),
                title: Text('aboutUs'.tr),
                onTap: () {}),
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('theme'.tr),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('changeLang'.tr),
              onTap: () {
                buildLanguageDialog(context);
                // var locale = Locale('gu', 'IN');
                // Get.updateLocale(locale);
              },
            ),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text('logOut'.tr),
                onTap: () {
                  showAlertDialog(context);
                }),
            // Add more list items as needed
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("head".tr),
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
  }
}
