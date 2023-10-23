import 'dart:io';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class ImageViewWidget extends StatelessWidget {
  bool isFile;
  String imageUrl;
  ImageViewWidget(
      {Key? key,
      required this.imageUrl,
      required this.isFile,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isFile
              ? PhotoView(
                  imageProvider: FileImage(File(imageUrl)),
                )
              : PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios_new_rounded,color: primaryWhite),),
      
              ],
            ),
          ),
        ],
      ),
    );
  }
}
