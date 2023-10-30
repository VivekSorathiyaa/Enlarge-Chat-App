// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:chatapp/componet/app_text_style.dart';

import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/video_view_widget.dart';
import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_glow/flutter_glow.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

import '../controller/theme_controller.dart';
import '../componet/image_view_widget.dart';
import '../componet/text_form_field_widget.dart';
import '../models/chat_room_model.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';
import 'group_info_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final UserModel? targetUser;

  const ChatRoomScreen({
    Key? key,
    required this.chatRoom,
    required this.targetUser,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  SpeechToText speechToText = SpeechToText();
  String _text = '';
  String msg = '';
  String? localeId;

  Locale? locale = AppPreferences().getLocaleFromPreferences();
  bool isListening = false;
  int maxDurationInSeconds = 10;
  Timer? timer;

  final FlutterTts flutterTts = FlutterTts();

  AppPreferences preferences = AppPreferences();
  var controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    CommonMethod.updateChatActiveStatus(widget.chatRoom.chatRoomId!);
    CommonMethod.setOnlineStatus();
    checkMicrophoneAvailability();
    super.initState();
  }

  void checkMicrophoneAvailability() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        if (kDebugMode) {
          print('Microphone available: $available');
        }
      });
    } else {
      if (kDebugMode) {
        print("The user has denied the use of speech recognition.");
      }
    }
  }

  Future<String> translateTo(String text, String local) async {
    final translator = GoogleTranslator();
    print('----beforeTranslator---$local----  ${text}');
    Translation translation = await translator.translate(text,
        // from: 'en',
        to: local);
    print('----afterTranslator-------  ${translation.text}');
    return translation.text;
  }

  Future<void> speakHindiText(String text) async {
    print("----speakHindiText---");
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.isLanguageAvailable("hi-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'hi');
    await flutterTts.speak(translate);
  }

  Future<void> speakEnglishText(String text) async {
    print("----speakEnglishText---");
    await flutterTts.setLanguage("en-IN");
    await flutterTts.isLanguageAvailable("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'en');
    await flutterTts.speak(translate);
  }

  Future<void> speakGujaratiText(String text) async {
    print("----speakGujaratiText---");
    await flutterTts.setLanguage("gu-IN");
    await flutterTts.isLanguageAvailable("gu-IN");
    await flutterTts.setVoice({"name": "Karen", "locale": "gu-IN"});
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'gu');
    await flutterTts.speak(translate);
  }
  //  listen() async {
  //   var microphoneStatus = await Permission.microphone.status;
  //   if (microphoneStatus.isGranted) {
  //     if (!_speech.isListening) {
  //       bool available = await _speech.initialize(
  //         onStatus: (status) {
  //           if (status =="listening") {
  //             // Show a loading spinner while listening
  //             setState(() {
  //               isListening=true;
  //             });
  //
  //         //    showListeningEffect();
  //           }
  //           else if (status == 'notListening') {
  //             // Hide the loading spinner when not listening
  //          //   hideListeningEffect();
  //           }
  //
  //           print('Speech Recognition Status: $status');
  //         },
  //         onError: (errorNotification) {
  //           print('Speech Recognition Error: $errorNotification');
  //         },
  //       );
  //       if (available) {
  //         setState(() {
  //           isListening = true;
  //           _text = '';
  //         });
  //         _speech.listen(
  //           onResult: (result) {
  //           //  openMicrophoneDialog();
  //             showListeningEffect();
  //             setState(() async {
  //               _text = result.recognizedWords;
  //               log('Speech Recognition : $_text');
  //               controller.messageController.text = _text;
  //
  //
  //             });
  //           },
  //         ).whenComplete(() {
  //           hideListeningEffect();
  //         });
  //       }
  //       else{
  //         setState(() {
  //           isListening = false;
  //         });
  //       }
  //     }
  //   } else if (microphoneStatus.isPermanentlyDenied) {
  //     openAppSettings();
  //   } else {}
  // }

  void showListeningEffect() {
    // Show a loading spinner or any other visual effect in your UI
    setState(() {
      isListening =
          true; // You can use this flag to conditionally display the effect
    });
  }

  void hideListeningEffect() {
    // Hide the loading spinner or visual effect
    setState(() {
      isListening = false;
    });
  }

  // String transliterateToGujarati(String text) {
  //   // Replace English characters with Gujarati characters based on a mapping
  //   final Map<String, String> gujaratiMap = {
  //     'a': 'અ',
  //     'b': 'બ',
  //     'c': 'ક',
  //     // Add more mappings as needed
  //   };
  //
  //   return text.split('').map((char) {
  //     final transliteration = gujaratiMap[char.toLowerCase()] ?? char;
  //     return char == char.toUpperCase()
  //         ? transliteration.toUpperCase()
  //         : transliteration;
  //   }).join();
  // }
  //
  // String transliterateToHindi(String text) {
  //   // Replace English characters with Hindi characters based on a mapping
  //   final Map<String, String> hindiMap = {
  //     'a': 'अ',
  //     'b': 'ब',
  //     'c': 'क',
  //     // Add more mappings as needed
  //   };
  //
  //   return text.split('').map((char) {
  //     final transliteration = hindiMap[char.toLowerCase()] ?? char;
  //     return char == char.toUpperCase()
  //         ? transliteration.toUpperCase()
  //         : transliteration;
  //   }).join();
  // }

  Future<UserModel> getTargetUser() async {
    return widget.targetUser!;
  }

  //
  // void _stopListening() {
  //   if (_speech.isListening) {
  //     _speech.stop();
  //   }
  // }



  @override
  void dispose() {
    CommonMethod.updateChatActiveStatus(widget.chatRoom.chatRoomId!);
    CommonMethod.setOnlineStatus();
    flutterTts.stop();
    super.dispose();
  }

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    Rx<UserModel> targetUser = UserModel(
            uid: null,
            fullName: null,
            phone: null,
            profilePic: null,
            fcmToken: null,
            openRoomId: null)
        .obs;
    if (widget.targetUser != null) {
      targetUser = widget.targetUser!.obs;
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.targetUser!.uid)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.exists) {
          final user =
              UserModel.fromMap(querySnapshot.data() as Map<String, dynamic>);
          targetUser.value = user;
        } else {
          targetUser.value = widget.targetUser!;
        }
      });
    }
    FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoom.chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      final messages = querySnapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      controller.updateMessages(messages);
    });

    return Obx(() {
      return Scaffold(
        backgroundColor:
            themeController.isDark.value ? primaryBlack : primaryWhite,
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
          title: GestureDetector(
            onTap: () {
              if (widget.chatRoom.isGroup!) {
                Get.to(() => GroupInfoScreen(
                      chatRoom: widget.chatRoom,
                    ));
              }
            },
            child: Row(
              children: [
                widget.targetUser != null
                    ? Obx(
                        () => NetworkImageWidget(
                          width: 42,
                          height: 42,
                          borderRadius: BorderRadius.circular(42),
                          imageUrl: targetUser.value.profilePic.toString(),
                        ),
                      )
                    : NetworkImageWidget(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(42),
                        imageUrl: widget.chatRoom.groupImage.toString(),
                      ),
                width15,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.targetUser != null
                          ? Obx(
                              () => Text(
                                targetUser.value.fullName.toString(),
                                style: AppTextStyle.regularBold.copyWith(
                                    color: primaryWhite,
                                    fontSize: 16,
                                    height: 1.5),
                              ),
                            )
                          : Text(
                              widget.chatRoom.groupName.toString(),
                              style: AppTextStyle.regularBold.copyWith(
                                  color: primaryWhite,
                                  fontSize: 16,
                                  height: 1.5),
                            ),
                      widget.targetUser != null
                          ? Obx(
                              () => Text(
                                targetUser.value.status.toString(),
                                style: AppTextStyle.normalRegular14.copyWith(
                                  color: primaryWhite.withOpacity(.7),
                                ),
                              ),
                            )
                          : FutureBuilder<String>(
                              future: CommonMethod.getMembersName(
                                  widget.chatRoom.usersIds!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(); // Display a loading indicator.
                                } else if (snapshot.hasError) {
                                  return SizedBox();
                                } else {
                                  return Text(
                                    '${snapshot.data}',
                                    style: AppTextStyle.normalRegular14
                                        .copyWith(
                                            color:
                                                primaryWhite.withOpacity(.7)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                              },
                            )
                    ],
                  ),
                ),
              ],
            ),
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
                            final isCurrentUser = currentMessage.sender ==
                                AppPreferences.getUiId();
                            if (currentMessage.sender != AppPreferences.getUiId()) {

                                controller.playMessageReceiveSound();
                            }
                           else if (currentMessage.sender == AppPreferences.getUiId()) {

                              controller.playMessageSentSound();
                            }


                            return InkWell(
                              onTap: () async {
                                // String englishText = currentMessage.text ?? "";
                                // String phoneticPronunciation;
                                //
                                // if (locale!.languageCode == 'gu') {
                                //  phoneticPronunciation=transliterateToGujarati(englishText);
                                // } else if (locale!.languageCode == 'hi') {
                                //   phoneticPronunciation=transliterateToHindi(englishText);
                                // } else {
                                //   // Handle other languages or default behavior
                                //   phoneticPronunciation =
                                //       englishText; // Using the same text for other languages
                                // }
                                //
                                //
                                //
                                // log('Pronunciation======$phoneticPronunciation');
                                log("-----locale!.languageCode----${locale!.languageCode}");
                                if (locale!.languageCode == 'gu') {
                                  speakGujaratiText(currentMessage.text ?? "");
                                } else if (locale!.languageCode == 'hi') {
                                  speakHindiText(currentMessage.text ?? "");
                                } else {
                                  speakEnglishText(currentMessage.text ?? "");
                                }

                              },

                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10),
                                  alignment: isCurrentUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: FutureBuilder<UserModel?>(
                                    future: isCurrentUser
                                        ? null
                                        : widget.targetUser != null
                                            ? getTargetUser()
                                            : CommonMethod.getUserModelById(
                                                currentMessage
                                                    .sender!), // The future to wait for.
                                    builder: (BuildContext context,
                                        AsyncSnapshot<UserModel?> snapshot) {
                                      var data = snapshot.data;
                                      return data == null && !isCurrentUser
                                          ? SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (data != null &&
                                                    !isCurrentUser &&
                                                    widget.targetUser == null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: NetworkImageWidget(
                                                      width: 30,
                                                      height: 30,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      imageUrl: snapshot
                                                          .data!.profilePic,
                                                    ),
                                                  ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: isCurrentUser
                                                            ? themeController
                                                                    .isDark
                                                                    .value
                                                                ? Color(
                                                                    0xFF3B444B)
                                                                : primaryBlack
                                                            : greenColor),
                                                    color: isCurrentUser
                                                        ? themeController
                                                                .isDark.value
                                                            ? Color(0xFF3B444B)
                                                            : primaryBlack
                                                        : greenColor,
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: isCurrentUser
                                                            ? Radius.circular(
                                                                10)
                                                            : Radius.circular(
                                                                0),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        topRight: isCurrentUser
                                                            ? Radius.circular(0)
                                                            : Radius.circular(
                                                                10),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  constraints: BoxConstraints(
                                                    maxWidth: Get.width * 0.7,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        isCurrentUser
                                                            ? CrossAxisAlignment
                                                                .end
                                                            : CrossAxisAlignment
                                                                .start,
                                                    children: [
                                                      if (data != null &&
                                                          !isCurrentUser &&
                                                          widget.targetUser ==
                                                              null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10),
                                                          child: Text(
                                                            data.fullName
                                                                .toString(),
                                                            style: AppTextStyle
                                                                .regularBold
                                                                .copyWith(
                                                              color:
                                                                  primaryWhite,
                                                              shadows: [
                                                                Shadow(
                                                                  offset:
                                                                      Offset(
                                                                          1, 1),
                                                                  color: primaryBlack
                                                                      .withOpacity(
                                                                          .2), // Shadow color
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (currentMessage
                                                              .media !=
                                                          null)
                                                        Column(
                                                          children: [
                                                            if (currentMessage
                                                                    .messageType ==
                                                                3)
                                                              audioTypeMessageWidget(
                                                                  currentMessage,
                                                                  isCurrentUser),
                                                            if (currentMessage
                                                                    .messageType ==
                                                                2)
                                                              videoTypeMessageWidget(
                                                                  currentMessage,
                                                                  isCurrentUser),
                                                            if (currentMessage
                                                                    .messageType ==
                                                                1)
                                                              imageTypeMessageWidget(
                                                                  currentMessage,
                                                                  isCurrentUser)
                                                          ],
                                                        ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            if (currentMessage
                                                                .text!
                                                                .isNotEmpty)
                                                              textTypeMessageWidget(
                                                                  currentMessage),
                                                            messageTimeWidget(
                                                                currentMessage)
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                    },
                                  )),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            if (widget.targetUser != null)
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
                          FadeIn(
                            child: GestureDetector(
                              onTap: () async {
                                if (!isListening) {
                                  var available =
                                      await speechToText.initialize();
                                  if (available) {
                                    setState(() {
                                      isListening = true;
                                    });
                                    speechToText.listen(
                                      listenFor: const Duration(days: 1),
                                      onResult: (result) {
                                        setState(() {
                                          controller.messageController.text =
                                              result.recognizedWords;
                                          if (result.finalResult) {
                                            // Recognition is complete
                                            setState(() {
                                              isListening = false;
                                            });
                                          }
                                        });
                                      },
                                    );
                                  }
                                } else {
                                  setState(() {
                                    isListening = false;
                                  });
                                  speechToText.stop();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isListening
                                      ? greenColor
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    isListening ? Icons.mic : Icons.mic_none,
                                    color: themeController.isDark.value
                                        ? isListening
                                            ? primaryWhite
                                            : primaryWhite
                                        : isListening
                                            ? primaryWhite
                                            : primaryBlack,
                                    // glowColor: isListening ? primaryWhite : Colors.transparent,
                                    // blurRadius: isListening ? 10 : 5,
                                    size: isListening ? 24 : 23,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: themeController.isDark.value
                                  ? primaryWhite
                                  : primaryBlack,
                            ),
                            onPressed: () async {
                              controller.selectedFile =
                                  await CommonMethod.pickFile();
                              if (controller.selectedFile != null) {
                                String? path = await CommonMethod.uploadFile(
                                    context, controller.selectedFile!);
                                if (path != null) {
                                  controller.mediaUrl = path;
                                  controller.sendMessage(
                                      chatRoom: widget.chatRoom);
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
                    backgroundColor: themeController.isDark.value
                        ? blackThemeColor
                        : primaryBlack,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: primaryWhite,
                      ),
                      onPressed: () {

                        controller.sendMessage(chatRoom: widget.chatRoom);
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
    });
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
