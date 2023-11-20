import 'dart:async';

import 'package:chatapp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/theme_controller.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    Key? key,
    required this.msg,
    required this.chatIndex,
    required bool shouldAnimate,
  });

  final String msg;
  final int chatIndex;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool textCopied = false;
  ThemeController themeController = Get.put(ThemeController());

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      textCopied = true;
    });

    // Reset the copy state after 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      setState(() {
        textCopied = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.chatIndex == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: greenColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextWidget(
                            color: primaryWhite,
                            label: widget.msg,
                            fontSize: 18,
                            align: TextAlign.start,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            : GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: themeController.isDark.value
                                ? greyColor.withOpacity(0.2)
                                : greyColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: TextWidget(
                                  label: widget.msg,
                                  fontSize: 16,
                                  color: themeController.isDark.value
                                      ? primaryWhite
                                      : primaryBlack),
                            ),
                          ],
                        ),
                      ),
                    )),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CopyButton(
                            textToCopy: widget.msg,
                            isCopied: textCopied,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ShareButton(
                            text: widget.msg,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40,
                    ),
                  ],
                ),
              )
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget(
      {Key? key,
      required this.label,
      this.fontSize = 18,
      this.color,
      this.weight,
      this.align});

  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align ?? TextAlign.left,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize,
        fontWeight: weight ?? FontWeight.w400,
      ),
    );
  }
}

class CopyButton extends StatefulWidget {
  final String textToCopy;
  final bool isCopied;

  CopyButton({required this.textToCopy, required this.isCopied});

  @override
  _CopyButtonState createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool copied = false;

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      copied = true;
    });

    // Schedule a timer to reset the copied state after 5 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        copied = false;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.center,
      duration: Duration(milliseconds: 300),
      width:
          copied ? 30 : 30, // Adjust the button width based on the copied state
      height: 30,
      decoration: BoxDecoration(
        // color: copied ? tealLightColor : greyLightColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: () {
          copyToClipboard(widget.textToCopy);
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        icon: copied
            ? Icon(
                Icons.check,
                size: 20,
              )
            : Icon(
                Icons.copy,
                size: 20,
              ),
        // child: Expanded(child:  Icon(
        //   copied ? Icons.check : Icons.content_copy,
        //   color: Colors.black, // Adjust the icon color
        // ),
      ),
    );
  }
}

class ShareButton extends StatefulWidget {
  final String text;

  ShareButton({required this.text});

  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.center,
      duration: Duration(milliseconds: 300),
      width: 30, // Adjust the button width based on the copied state
      height: 30,
      decoration: BoxDecoration(
        // color: copied ? tealLightColor : greyLightColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: () {
          Share.share(widget.text);
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        icon: Icon(
          Icons.share,
          size: 20,
        ),
      ),
    );
  }
}
