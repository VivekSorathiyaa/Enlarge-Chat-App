import 'package:chatapp/Drawer/drawer_item.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Change Theme/model_theme.dart';


class CustomDrawer extends StatefulWidget {

   CustomDrawer({Key? key, required this.logout, required this.changeLang, required this.theme, required this.people, required this.myAccount, required this.chats}) : super(key: key);

   final Function() people;
   final Function() myAccount;
   final Function() theme;
   final Function() chats;
   final Function() changeLang;
   final Function() logout;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? profilepic=AppPreferences.getProfilePic();

   String? fullname=AppPreferences.getFullName();

   String? phone=AppPreferences.getPhone();

  @override
  Widget build(BuildContext context) {
    final modelTheme = Provider.of<ModelTheme>(context);
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
   return Drawer(
        child: Material(
          color:primaryBlack,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
            child: Column(
              children: [
                headerWidget(profilepic!,fullname!,phone!),
                const SizedBox(height: 40,),
                const Divider(thickness: 1, height: 10, color: Colors.grey,),
                const SizedBox(height: 40,),
                DrawerItem(
                  name: 'people'.tr,
                  icon: Icons.people,
                  onPressed:widget.people
                ),
                const SizedBox(height: 30,),
                DrawerItem(
                    name: 'myProfile'.tr,
                    icon: Icons.account_box_rounded,
                    onPressed:widget.myAccount
                ),
                const SizedBox(height: 30,),
                DrawerItem(
                    name: 'theme'.tr,
                    icon: themeNotifier.isDark? Icons.dark_mode:Icons.light_mode,
                    onPressed:(){
                      themeNotifier.isDark
                          ? themeNotifier.isDark = false
                          : themeNotifier.isDark = true;
                    }
                ),
                const SizedBox(height: 30,),
                DrawerItem(
                    name: 'chats'.tr,
                    icon: Icons.message_outlined,
                    onPressed:widget.chats
                ),


                const SizedBox(height: 30,),
                const Divider(thickness: 1, height: 10, color: Colors.grey,),
                const SizedBox(height: 30,),
                DrawerItem(
                    name: 'changeLang'.tr,
                    icon: Icons.language,
                    onPressed: widget.changeLang,
                ),
                const SizedBox(height: 30,),
                DrawerItem(
                    name: 'logOut'.tr,
                    icon: Icons.logout,
                    onPressed:widget.logout,
                ),

              ],
            ),
          ),
        ),
      );}
    );
  }

  Widget headerWidget(String profilePic,String fullName,String phone) {

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
        const SizedBox(width: 20,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text(fullName, style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(height: 10,),
            Text(phone, style: TextStyle(fontSize: 14, color: Colors.white))
          ],
        )
      ],
    );

  }
}