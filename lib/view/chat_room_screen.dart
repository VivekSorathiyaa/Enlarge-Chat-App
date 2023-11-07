// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:chatapp/componet/app_text_style.dart';
import 'package:chatapp/componet/audio_player_widget.dart';
import 'package:chatapp/componet/custom_dialog.dart';

import 'package:chatapp/componet/network_image_widget.dart';
import 'package:chatapp/componet/shadow_container_widget.dart';
import 'package:chatapp/componet/video_view_widget.dart';
import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:chatapp/view/video_conference_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_glow/flutter_glow.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

import '../controller/theme_controller.dart';
import '../componet/image_view_widget.dart';
import '../componet/text_form_field_widget.dart';
import '../models/chat_room_model.dart';
import '../utils/app_preferences.dart';
import '../utils/common_method.dart';
import 'group_info_screen.dart';
import 'package:grouped_list/grouped_list.dart';

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
  RxBool currentSpeaking = false.obs;
  RxInt selectedIndex = 0.obs;
  AppPreferences preferences = AppPreferences();
  var controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  Map<String, int> unreadMessageCounts = {};
  String? userId = AppPreferences.getUiId();
StreamSubscription<QuerySnapshot>? _messageSubscription;

  @override
  void initState() {
    log("==============target user open room id:${widget.targetUser!.openRoomId}");
    _messageSubscription = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoom.chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      final messages = querySnapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      controller.updateMessages(messages, widget.chatRoom);
      refreshPage();
    });
    initializeChatRoom();
    super.initState();
  }

refreshPage() async {
    print('-----refreshPage-----');
    List<String> messageIdsWithSeenStatusFalse =
          await CommonMethod.retrieveMessagesWithSeenStatusFalse(
      widget.chatRoom.chatRoomId!,
    );                                                                                                                                                                                                                   
    await CommonMethod.updateMessagesToSeenStatusTrue(
        widget.chatRoom.chatRoomId!, messageIdsWithSeenStatusFalse, userId!);
  }

  Future<void> initializeChatRoom() async {
    log('-------userid=============${userId}');
    try {
      CommonMethod.updateChatActiveStatus(widget.chatRoom.chatRoomId!);
      refreshPage();
      CommonMethod.setOnlineStatus();
      checkMicrophoneAvailability();
    } catch (e) {
      print('Error initializing chat room: $e');
    }
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
    currentSpeaking.value = true;

    await flutterTts.setLanguage("hi-IN");
    await flutterTts.isLanguageAvailable("hi-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'hi');
    await flutterTts.speak(translate);
    flutterTts.setCompletionHandler(() {
      currentSpeaking.value = false;
    });
  }

  Future<void> speakEnglishText(String text) async {
    currentSpeaking.value = true;
    print("----speakEnglishText---");
    await flutterTts.setLanguage("en-IN");
    await flutterTts.isLanguageAvailable("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'en');
    await flutterTts.speak(translate);
    flutterTts.setCompletionHandler(() {
      currentSpeaking.value = false;
    });
  }

  Future<void> speakGujaratiText(String text) async {
    currentSpeaking.value = true;
    print("----speakGujaratiText---");
    await flutterTts.setLanguage("gu-IN");
    await flutterTts.isLanguageAvailable("gu-IN");
    await flutterTts.setVoice({"name": "Karen", "locale": "gu-IN"});
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    var translate = await translateTo(text, 'gu');
    await flutterTts.speak(translate);
    flutterTts.setCompletionHandler(() {
      currentSpeaking.value = false;
    });
  }

  Future<UserModel> getTargetUser() async {
    return widget.targetUser!;
  }

  @override
  void dispose() {
    _messageSubscription!.cancel();

    CommonMethod.updateChatActiveStatus(null);
    CommonMethod.setOnlineStatus();
    flutterTts.stop();
    super.dispose();
  }

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // int unreadCount = unreadMessageCounts[widget.chatRoom.chatRoomId] ?? 0;

    Rx<UserModel> targetUser = UserModel(
            uid: null,
            fullName: null,
            phone: null,
            profilePic: null,
            fcmToken: null,
            openRoomId: null, deviceToken: null)
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
                      chatRoomId: widget.chatRoom.chatRoomId!,
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
        
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => VideoConferenceScreen(
                      chatRoomModel: widget.chatRoom,
                      chatRoomId: widget.chatRoom.chatRoomId,
                    ));
              },
              icon: Icon(Icons.video_call),
            ),
            width10,
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Obx(
              () => GroupedListView<MessageModel, DateTime>(
                padding: const EdgeInsets.only(bottom: 20),
                shrinkWrap: true,
                reverse: true,
                controller: _scrollController,
                floatingHeader: true,
                elements: controller.messages.value,
                scrollDirection: Axis.vertical,
                sort: false,
                itemComparator: (a, b) {
                  final valueA =
                      CommonMethod.currentUtcTime(a.createdAt.toString());
                  final valueB =
                      CommonMethod.currentUtcTime(b.createdAt.toString());

                  return valueA.compareTo(valueB);
                },
                groupBy: (element) {
                  final datetime =
                      CommonMethod.currentUtcTime(element.createdAt.toString());

                  final date =
                      DateTime(datetime.year, datetime.month, datetime.day);
                  return date;
                },
                groupHeaderBuilder: (element) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ShadowContainerWidget(
                      shadowColor: primaryColor.withOpacity(.1),
                      borderColor: primaryBlack.withOpacity(.1),
                      padding: 0,
                      radius: 10,
                      widget: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          DateFormat('EEEE dd MMMM, yyyy').format(
                                      CommonMethod.currentUtcTime(
                                          element.createdAt.toString())) ==
                                  DateFormat('EEEE dd MMMM, yyyy')
                                      .format(DateTime.now())
                              ? "Today"
                              : DateFormat('EEEE dd MMMM, yyyy').format(
                                  CommonMethod.currentUtcTime(
                                      element.createdAt.toString())),
                          style: AppTextStyle.normalRegular10
                              .copyWith(color: primaryBlack),
                        ),
                      ),
                    ),
                  ),
                ),
                indexedItemBuilder: (context, e, index) {
                  final currentMessage = e;
                  final isCurrentUser = currentMessage.sender == null
                      ? false
                      : currentMessage.sender == AppPreferences.getUiId();
                  return currentMessage.sender == null
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ShadowContainerWidget(
                            shadowColor: themeController.isDark.value
                                ? primaryWhite.withOpacity(.1)
                                : primaryColor.withOpacity(.1),
                            borderColor: themeController.isDark.value
                                ? primaryWhite.withOpacity(.1)
                                : primaryBlack.withOpacity(.1),
                            padding: 0,
                            radius: 10,
                            widget: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                currentMessage.text.toString(),
                                style: AppTextStyle.normalRegular10.copyWith(
                                    color: themeController.isDark.value
                                        ? primaryWhite.withOpacity(.5)
                                        : primaryBlack),
                              ),
                            ),
                          ),
                        ))
                      : InkWell(
                          onTap: () {
                            selectedIndex.value = index;
                            print(
                                "-----currentMessage.messageType----${currentMessage.messageType}");
                            if (currentMessage.messageType == 3) {
                              CustomDialog.showSimpleDialog(
                                  child: AudioPlayerWidget(
                                    audioUrl: currentMessage.media.toString(),
                                  ),
                                  context: context);
                            }
                            if (currentMessage.messageType == 0 &&
                                currentMessage.text != null &&
                                currentMessage.text!.isNotEmpty) {
                              if (locale!.languageCode == 'gu') {
                                speakGujaratiText(currentMessage.text ?? "");
                              } else if (locale!.languageCode == 'hi') {
                                speakHindiText(currentMessage.text ?? "");
                              } else {
                                speakEnglishText(currentMessage.text ?? "");
                              }
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
                                  return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                      if (!isCurrentUser &&
                                          widget.chatRoom.isGroup!)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: NetworkImageWidget(
                                                  width: 30,
                                                  height: 30,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  imageUrl:
                                                      snapshot.data != null
                                                ? snapshot.data!.profilePic
                                                    .toString()
                                                : "",
                                                ),
                                              ),
                                            Obx(() => currentSpeaking.value &&
                                                    selectedIndex.value == index
                                                ? IconButton(
                                                    icon: Icon(
                                                        CupertinoIcons.waveform,
                                                        color: themeController
                                                                .isDark.value
                                                            ? Colors
                                                                .blueGrey[200]
                                                            : primaryColor),
                                                    onPressed: () {},
                                                  )
                                                : SizedBox()),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: isCurrentUser
                                                        ? themeController
                                                                .isDark.value
                                                            ? Color(0xFF3B444B)
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
                                                        ? Radius.circular(10)
                                                        : Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    topRight: isCurrentUser
                                                        ? Radius.circular(0)
                                                        : Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                              ),
                                              constraints: BoxConstraints(
                                                maxWidth: Get.width * 0.7,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    isCurrentUser
                                                        ? CrossAxisAlignment.end
                                                        : CrossAxisAlignment
                                                            .start,
                                                children: [
                                            if (!isCurrentUser &&
                                                widget.chatRoom.isGroup!)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 10),
                                                      child: Text(
                                                  snapshot.data != null
                                                      ? snapshot.data!.fullName
                                                          .toString()
                                                      : "Unknown",
                                                        style: AppTextStyle
                                                            .regularBold
                                                            .copyWith(
                                                          color: primaryWhite,
                                                          shadows: [
                                                            Shadow(
                                                              offset:
                                                                  Offset(1, 1),
                                                              color: primaryBlack
                                                                  .withOpacity(
                                                                      .2), // Shadow color
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (currentMessage.media !=
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
                                                        const EdgeInsets.all(
                                                            10),
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
                                                            .text!.isNotEmpty)
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

                                    
                                            // currentMessage.sender == AppPreferences.getUiId()
                                            //     ? Row(
                                            //   children: [
                                            //     Icon(
                                            //       Icons.done_all,
                                            //       color:(color: currentMessage.seen ? Colors.blue : Colors.grey,)? Colors.blue : Colors.grey,
                                            //     ),
                                            //     if (controller.isChatActive)
                                            //       Icon(Icons.check, color: Colors.blue), // Add checkmark when chat is active
                                            // //   ],
                                            // // )
                                            // //     : SizedBox(),
                                          ],
                                        );
                                },
                              )),
                        );
                },
              ),
            )),
            if (widget.targetUser != null)
              Obx(
                () => targetUser.value.status == 'typing' &&
                        targetUser.value.openRoomId ==
                            widget.chatRoom.chatRoomId
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
      child: Row(
        children: [
          Text(
            CommonMethod.formatDateToTime(
                currentMessage.createdAt ?? DateTime.now()),
            style: AppTextStyle.normalRegular10
                .copyWith(height: 0, color: primaryWhite.withOpacity(.7)),
          ),
          width05,
          currentMessage.sender == AppPreferences.getUiId()
              ? Icon(
                  Icons.done_all,
                  size: 18,
                  color: currentMessage.seen == true
                      ? lightBlueColor
                      : primaryWhite.withOpacity(.7),
                )
              : SizedBox(),
        ],
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
