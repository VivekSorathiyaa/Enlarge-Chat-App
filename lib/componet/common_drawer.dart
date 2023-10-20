import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String username;
  final String profilePic;
  final String phone;
  final VoidCallback logoutOnTap;
  final VoidCallback locale;


   CustomDrawer(
      {key, required this.username, required this.phone, required this.logoutOnTap, required this.profilePic, required this.locale,});

  @override
  Widget build(BuildContext context) {


          return Drawer(
            
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                 color: Color(0xFF969697).withOpacity(0.9)
                  ),
                  //   color: primaryColor.withOpacity(0.5),
                  height: 30,
                ),

                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                      color:Color(0xFF969697).withOpacity(0.9)
                  ),
                  accountName: Text(username,style: TextStyle(fontSize: 18,color: primaryWhite),),
                  accountEmail: Text(phone,style: TextStyle(fontSize: 13,color: primaryWhite),),
                  currentAccountPicture:Container(
                  // Adjust the size as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Background color of the circle
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(profilePic),
                    ),
                  ),
                ),






                ListTile(
                    leading: Icon(Icons.info),
                    title: Text('About Us'),
                    onTap: (){

                    }
                ),
                ListTile(
                  leading:Icon(Icons.light_mode),
                  title: Text('Theme'),
                  onTap:(){

                  } ,
                ),
                ListTile(
                  leading:Icon(Icons.language),
                  title: Text('Change Language'),
                  onTap:locale,
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  onTap: logoutOnTap,
                ),
                // Add more list items as needed
              ],
            ),
          );}

  }
