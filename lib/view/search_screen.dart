import 'dart:async';

import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/common_app_bar.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/componet/user_widget.dart';
import 'package:chatapp/utils/app_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componet/network_image_widget.dart';
import '../controller/search_user_controller.dart';
import '../utils/colors.dart';
import 'chat_room_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchUserController searchController = Get.put(SearchUserController());
  FocusNode _focusNode = FocusNode();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (searchController.searchTextController.text.isEmpty) {
        searchController.searchUsers();
      }
    });
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          _focusNode.requestFocus();
        });
      });
    }
  }

  void _changeKeyboardType(TextInputType newInputType) {
    searchController.keyboardType.value = newInputType;
    _onFocusChange();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: primaryWhite,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: TextFormFieldWidget(
              keyboardType: searchController.keyboardType.value,
              controller: searchController.searchTextController,
              prefixIcon: Icon(Icons.search),
              focusNode: _focusNode,
              filledColor: primaryWhite.withOpacity(.1),
              cursorColor: primaryWhite,
              autofocus: true,
              textStyle:
                  AppTextStyle.normalBold16.copyWith(color: primaryWhite),
              onChanged: (value) {
                searchController.searchUsers();
              },
              hintText: 'search'.tr),
          actions: [
            Obx(
              () => searchController.keyboardType.value == TextInputType.text
                  ? IconButton(
                      onPressed: () {
                        _changeKeyboardType(TextInputType.number);
                      },
                      icon: Icon(Icons.dialpad_rounded),
                    )
                  : IconButton(
                      onPressed: () {
                        _changeKeyboardType(TextInputType.text);
                      },
                      icon: Icon(Icons.keyboard),
                    ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final searchedUsers = searchController.searchResults;
                if (searchedUsers.isNotEmpty) {
                  return ListView(
                    children: searchedUsers.map((user) {
                      return UserWidget(user: user);
                    }).toList(),
                  );
                } else {
                  return Center(child: Text("No results found!"));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
