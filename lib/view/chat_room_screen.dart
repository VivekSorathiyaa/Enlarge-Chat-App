// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';
import 'dart:io';

import 'package:chatapp/componet/app_text_style.dart';

import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/video_view_widget.dart';
import 'package:chatapp/controller/chat_controller.dart';

import 'package:chatapp/models/chat_room_model.dart';

import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

import '../componet/image_view_widget.dart';
import '../componet/text_form_field_widget.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final UserModel targetUser;

  const ChatRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.targetUser,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = '';
  String msg = '';
  String? localeId;
  final RxBool isMenuVisible = RxBool(false);
  Locale? locale = AppPreferences().getLocaleFromPreferences();

  AppPreferences preferences = AppPreferences();
  var controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    CommonMethod.updateChatActiveStatus([widget.targetUser.uid!]);
    CommonMethod.setOnlineStatus();
    _requestMicrophonePermission();
    _initializeSpeechToText();
    super.initState();
  }

  void _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      // Microphone permission granted, you can now start speech recognition
      // _listen('gu');
      // listenAndTranslate();
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, ask the user to go to app settings
      openAppSettings();
    } else {
      // Permission is denied, handle accordingly (e.g., show a message to the user)
    }
  }

  void _initializeSpeechToText() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech Recognition Status: $status');
      },
      onError: (errorNotification) {
        print('Speech Recognition Error: $errorNotification');
      },
    );

    if (!available) {
      // Handle the case where speech recognition is not available
      print('Speech recognition not available');
    }
  }

  void listen(Locale savedLocale) async {
    var microphoneStatus = await Permission.microphone.status;

    if (microphoneStatus.isGranted) {
      if (!_speech.isListening) {
        bool available = await _speech.initialize(
          onStatus: (status) {
            print('Speech Recognition Status: $status');
          },
          onError: (errorNotification) {
            print('Speech Recognition Error: $errorNotification');
          },
          // localeId: selectedLanguage, // Set the selected language for recognition
        );

        if (available) {
          setState(() {
            _text = '';
          });

          _speech.listen(
            onResult: (result) {
              setState(() async {
                _text = result.recognizedWords;
                log('Speech Recognition : $_text');
                log('Languagjehhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh============${savedLocale.languageCode}');
                translateTo(_text, savedLocale.languageCode);
                //    controller.messageController.text = msg1;
              });
            },
          );
        }
      }
    } else if (microphoneStatus.isPermanentlyDenied) {
      // Handle permanently denied permission (e.g., show a message to the user)
      openAppSettings();
    } else {
      // Handle other permission states (e.g., show a message to the user)
    }
  }

  Future<void> translateTo(String text, String local) async {
    final translator = GoogleTranslator();

    Translation translation = await translator.translate(text, to: local);

    // Set the translated text to the messageController
    controller.messageController.text = translation.text;
    log('Languagjehhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh============${controller.messageController.text}');
  }

  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  @override
  void dispose() {
    CommonMethod.updateChatActiveStatus(null);
    CommonMethod.setOnlineStatus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Rx<UserModel> targetUser = widget.targetUser.obs;
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.targetUser.uid)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.exists) {
        final user =
            UserModel.fromMap(querySnapshot.data() as Map<String, dynamic>);
        targetUser.value = user;
      } else {
        targetUser.value = widget.targetUser;
      }
    });
    FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      final messages = querySnapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      controller.updateMessages(messages);
    });

    return Scaffold(
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
        title: Row(
          children: [
            Obx(
              () => NetworkImageWidget(
                width: 42,
                height: 42,
                borderRadius: BorderRadius.circular(42),
                imageUrl: targetUser.value.profilepic.toString(),
              ),
            ),
            width15,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    targetUser.value.fullname.toString(),
                    style: AppTextStyle.regularBold.copyWith(
                        color: primaryWhite, fontSize: 16, height: 1.5),
                  ),
                ),
                Obx(
                  () => Text(
                    targetUser.value.status.toString(),
                    style: AppTextStyle.normalRegular14.copyWith(
                      color: primaryWhite.withOpacity(.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              reverse: true,
              children: [
                Obx(
                  () {
                    final messages = controller.messages;
                    if (messages.isEmpty) {
                      return SizedBox();
                    } else {
                      return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final currentMessage = messages[index];
                          final isCurrentUser =
                              currentMessage.sender == AppPreferences.getUiId();

                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isCurrentUser
                                        ? primaryColor
                                        : greenColor),
                                color:
                                    isCurrentUser ? primaryColor : greenColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: isCurrentUser
                                        ? Radius.circular(10)
                                        : Radius.circular(0),
                                    bottomLeft: Radius.circular(10),
                                    topRight: isCurrentUser
                                        ? Radius.circular(0)
                                        : Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              constraints: BoxConstraints(
                                maxWidth: Get.width * 0.7,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (currentMessage.media != null)
                                    Column(
                                      children: [
                                        if (currentMessage.messageType == 3)
                                          audioTypeMessageWidget(
                                              currentMessage, isCurrentUser),
                                        if (currentMessage.messageType == 2)
                                          videoTypeMessageWidget(
                                              currentMessage, isCurrentUser),
                                        if (currentMessage.messageType == 1)
                                          imageTypeMessageWidget(
                                              currentMessage, isCurrentUser)
                                      ],
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (currentMessage.text!.isNotEmpty)
                                          textTypeMessageWidget(currentMessage),
                                        messageTimeWidget(currentMessage)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Obx(
            () => targetUser.value.status == 'typing'
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        width12,
                        Text(
                          'Typing ',
                          style: AppTextStyle.normalBold14
                              .copyWith(color: greenColor),
                        ),
                        LoadingAnimationWidget.waveDots(
                          color: greenColor,
                          size: 30,
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormFieldWidget(
                    controller: controller.messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        CommonMethod.setTypingStatus();
                      } else {
                        CommonMethod.setOnlineStatus();
                      }
                    },
                    hintText: "Enter message",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              //listenAndTranslate();
                              listen(locale!);
                            },
                            icon: Icon(
                              Icons.mic_none,
                              color: primaryBlack,
                            )),
                        IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            controller.selectedFile =
                                await CommonMethod.pickFile();
                            if (controller.selectedFile != null) {
                              String? path =
                                  await controller.uploadFile(context);
                              if (path != null) {
                                controller.mediaUrl = path;
                                controller.sendMessage(
                                    chatRoomId: widget.chatRoomId,
                                    targetUser: widget.targetUser);
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
                width10,
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor,
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: primaryWhite,
                    ),
                    onPressed: () {
                      controller.sendMessage(
                          chatRoomId: widget.chatRoomId,
                          targetUser: widget.targetUser);
                    },
                  ),
                ),
              ],
            ),
          ),
          height12,
        ],
      ),
    );
  }

  Widget messageTimeWidget(MessageModel currentMessage) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        CommonMethod.formatDateToTime(
            currentMessage.createdAt ?? DateTime.now()),
        style: AppTextStyle.normalRegular10
            .copyWith(height: 0, color: primaryWhite.withOpacity(.7)),
      ),
    );
  }

  Widget textTypeMessageWidget(MessageModel currentMessage) {
    return Flexible(
      child: Text(
        currentMessage.text.toString(),
        style: AppTextStyle.normalRegular14.copyWith(color: primaryWhite),
      ),
    );
  }

  Widget imageTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ImageViewWidget(
              imageUrl: currentMessage.media!,
              isFile: false,
            ));
      },
      child: NetworkImageWidget(
        width: (Get.width / 2),
        height: (Get.width / 2),
        borderRadius: BorderRadius.only(
            topLeft: isCurrentUser ? Radius.circular(10) : Radius.circular(0),
            bottomLeft: Radius.circular(10),
            topRight: isCurrentUser ? Radius.circular(0) : Radius.circular(10),
            bottomRight: Radius.circular(10)),
        imageUrl: currentMessage.media,
      ),
    );
  }

  Widget audioTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return GestureDetector(
        onTap: () {
          log("---currentMessage.media---${currentMessage.media}");
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.audio_file_rounded,
                color: primaryWhite,
              ),
            ),
            Flexible(
              child: Text(
                "Audio file",
                style: AppTextStyle.normalBold14.copyWith(color: primaryWhite),
              ),
            )
          ],
        ));
  }

  Widget videoTypeMessageWidget(
      MessageModel currentMessage, bool isCurrentUser) {
    return FutureBuilder<String>(
      future: CommonMethod.generateThumbnail(currentMessage.media!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () async {
              Get.to(() =>
                  VideoViewWidget(url: currentMessage.media!, isFile: false));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(snapshot.data!),
                      width: (Get.width / 2),
                      height: (Get.width / 2),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 50,
                  color: primaryWhite.withOpacity(.8),
                )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        }
        return const SizedBox();
      },
    );
  }
}
