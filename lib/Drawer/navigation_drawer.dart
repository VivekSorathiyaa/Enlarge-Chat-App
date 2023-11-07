import 'package:chatapp/view/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatapp/Drawer/drawer_item.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:chatapp/utils/colors.dart';

import '../controller/theme_controller.dart';

class CustomDrawer extends StatelessWidget {
  final Function() people;
  final Function() myAccount;

  final Function() changeLang;
  final  Function() logout;


  CustomDrawer({
    required this.people,
    required this.myAccount,


    required this.changeLang,
    required this.logout,
  });



  String? profilepic = AppPreferences.getProfilePic();
  String? fullname = AppPreferences.getFullName();
  String? phone = AppPreferences.getPhone();

  @override
  Widget build(BuildContext context) { final ThemeController themeController = Get.find();



    return Drawer(
      child: Material(
        color: primaryBlack,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
          child: Column(
            children: [
              headerWidget(profilepic!, fullname!, phone!),
              const SizedBox(height: 40,),
              const Divider(thickness: 1, height: 10, color: Colors.grey,),
              const SizedBox(height: 40,),
              DrawerItem(
                name: 'people'.tr,
                icon: Icons.people,
                onPressed: people,
              ),
              const SizedBox(height: 30,),
              DrawerItem(
                name: 'myProfile'.tr,
                icon: Icons.account_box_rounded,
                onPressed: myAccount,
              ),
              const SizedBox(height: 30,),




              Obx(() {
                final themeIcon = themeController.isDark.value ? Icons.dark_mode : Icons.light_mode;

                return DrawerItem(
                  name: 'theme'.tr,
                  icon: themeIcon,
                  onPressed: () {
                    themeController.toggleTheme(!themeController.isDark.value);
                    final newTheme = themeController.isDark.value
                        ? themeController.darkTheme
                        : themeController.lightTheme;

                    Get.changeTheme(newTheme);

                  },
                );
              }),
              const SizedBox(height: 30,),


              const Divider(thickness: 1, height: 10, color: Colors.grey,),
              const SizedBox(height: 30,),
              DrawerItem(
                name: 'changeLang'.tr,
                icon: Icons.language,
                onPressed: changeLang,
              ),
              const SizedBox(height: 30,),
              DrawerItem(
                name: 'logOut'.tr,
                icon: Icons.logout,
                onPressed: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerWidget(String profilePic, String fullName, String phone) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            Get.to(()=>EditProfile());
          },
          child: Container(
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
        ),
        const SizedBox(width: 20,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(height: 10,),
            Text(phone, style: TextStyle(fontSize: 14, color: Colors.white))
          ],
        )
      ],
    );
  }
}
