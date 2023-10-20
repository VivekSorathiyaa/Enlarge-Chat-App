import 'dart:developer';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/common_drawer.dart';
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
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/common_method.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? currentUserId;
  Locale? selectedLocale;


  @override
  void initState() {
    refreshPage();
    selectedLocale = savedLocale;
    super.initState();
  }
  final List locale =[
    {'name':'ENGLISH','locale': Locale('en','US')},
    {'name':'ગુજરાતી','locale': Locale('gu','IN')},
    {'name':'हिंदी','locale': Locale('hi','IN')},
  ];
  updateLanguage(Locale locale){
    Get.back();
    Get.updateLocale(locale);
    AppPreferences.setLocal(locale);
  }
  buildLanguageDialog(BuildContext context){
    showDialog(context: context,
        builder: (builder){
          return AlertDialog(
        actionsAlignment: MainAxisAlignment.start,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
            ),
            elevation: 15,
            title: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlack.withOpacity(0.9),greyColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10)
              ),
            //  color: primaryBlack.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('chooseLang'.tr,style: TextStyle(color: primaryWhite),),
                )),
            // content: Container(
            //   width: double.maxFinite,
            //   child: ListView.separated(
            //       shrinkWrap: true,
            //       itemBuilder: (context,index){
            //         return Padding(
            //           padding: const EdgeInsets.all(15.0),
            //           child: GestureDetector(child: Text(locale[index]['name']),onTap: (){
            //             print(locale[index]['name']);
            //             updateLanguage(locale[index]['locale']);
            //           },),
            //         );
            //       }, separatorBuilder: (context,index){
            //     return Divider(
            //       height: 2,
            //       color: primaryBlack,
            //     );
            //   }, itemCount: locale.length
            //   ),
            // ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(locale.length, (index) {
                return ListTile(
                  title: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 10),
                    child: Text(locale[index]['name']),
                  ),
                  leading:Radio<Locale>(
                    value: locale[index]['locale'],
                    groupValue: selectedLocale,
                    onChanged: (value ) {
                      setState(() {
                        selectedLocale = value as Locale?;
                      });
                      print(locale[index]['name']);
                      updateLanguage(value!);
                      Navigator.of(context).pop(); // Close the dialog after selection
                    },
                  ),
                  splashColor: Colors.grey,

                  onTap: () {
                    print(locale[index]['name']);
                    updateLanguage(locale[index]['locale']);
                    Navigator.of(context).pop(); // Close the dialog after selection
                  },
                );
              }),
            ),
          );
        }
    );
  }

  Future refreshPage() async {
    await AppPreferences.getFirebaseMessagingToken();
    await AppPreferences.uploadData();

    currentUserId = await AppPreferences.getUiId();
  }

  String? fullname = AppPreferences.getFullName();
  String? phone = AppPreferences.getPhone();
  String? profilePic = AppPreferences.getProfilePic();
  Locale? savedLocale = AppPreferences().getLocaleFromPreferences();
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
          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
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

      drawer:Drawer(



        child: ListView(

          padding: EdgeInsets.zero,
          children: [
            Container(

              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
 color: primaryBlack
              ),
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
                onTap: (){

                }
            ),
            ListTile(
              leading:Icon(Icons.light_mode),
              title: Text('theme'.tr),
              onTap:(){

              } ,
            ),
            ListTile(
              leading:Icon(Icons.language),
              title: Text('changeLang'.tr),
              onTap:(){
                buildLanguageDialog(context);
                // var locale = Locale('gu', 'IN');
                // Get.updateLocale(locale);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('logOut'.tr),
              onTap: (){
                showAlertDialog(context);
              }
            ),
            // Add more list items as needed
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("head".tr),
        actions: [
          IconButton(
            onPressed: () => showAlertDialog(context),
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
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
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
                        future:
                            CommonMethod.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.waiting) {
                            // Handle loading state
                            return Container();
                          } else if (userData.connectionState ==
                              ConnectionState.done) {
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
                                      isProfile: true,
                                      borderRadius: BorderRadius.circular(50),
                                      imageUrl: targetUser.profilepic ?? ''),
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
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black87,
                  ),
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
