import 'dart:ffi';

import 'package:chatapp/componet/chat_bot_widget.dart';
import 'package:chatapp/componet/text_form_field_widget.dart';
import 'package:chatapp/controller/chatbot_controller.dart';
import 'package:chatapp/controller/theme_controller.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/static_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ChatBotController chatBotController = Get.put(ChatBotController());
  ThemeController themeController = Get.put(ThemeController());

  bool _isTyping = false;
  RxBool _isListening = false.obs;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  SpeechToText speechToText = SpeechToText();

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
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

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  playMessageSentSound() {
    assetsAudioPlayer.open(
      Audio("assets/audio/sent_message.mp3"),
    );
    print('----------------------------play sound');
  }

  playMessageReceiveSound() {
    assetsAudioPlayer.open(
      Audio("assets/audio/receive_message.mp3"),
    );
    print('----------------------------receive sound');
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(themeController.isDark.value ? "Chat Bot" : "Chat Bot"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeController.isDark.value
                ? Icons.nightlight_round
                : Icons.wb_sunny),
            onPressed: () {
              themeController.isDark.value
                  ? themeController.isDark.value = false
                  : themeController.isDark.value = true;
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Flexible(
              child: Obx(
                () => ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatBotController.getChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatBotController.getChatList[index].msg,
                      chatIndex: chatBotController.getChatList[index].chatIndex,
                      shouldAnimate:
                          chatBotController.getChatList.length - 0 == index,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (_isTyping) ...[
              SpinKitThreeBounce(
                color: greenColor,
                size: 25,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormFieldWidget(
                      controller: textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      hintText: "Ask me anything...",
                      suffixIcon: FadeIn(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await toggleSpeechRecognition();
                            },
                            child: Icon(
                              Icons.mic,
                              color: themeController.isDark.value
                                  ? greyColor
                                  : Colors.black38,
                            ),
                          ),
                        ),
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
                      onPressed: () async {
                        _isListening.value = false;

                        await sendMessageFCT();
                      },
                    ),
                  ),
                ],
              ),
            ),
            height12,
          ],
        ),
      ),
    );
  }

  Future<void> sendMessageFCT() async {
    if (_isTyping) {
      Get.snackbar(
        "Error",
        "You can't send multiple messages at a time",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (textEditingController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please type a message",
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      String msg = textEditingController.text;
      _isTyping = true;
      chatBotController.addUserMessage(msg: msg);
      textEditingController.clear();
      focusNode.unfocus();

      await playMessageSentSound();
      await chatBotController.sendMessageAndGetAnswers(
        msg: msg,
        chosenModelId: chatBotController.getCurrentModel,
      );
      await playMessageReceiveSound();
    } catch (error) {
      print("error $error");
      Get.snackbar(
        "Error",
        error.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      scrollListToEND();
      _isTyping = false;
    }
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 10),
        curve: Curves.easeOut);
  }

  Future<void> toggleSpeechRecognition() async {
    if (!_isListening.value) {
      var available = await speechToText.initialize();
      if (available) {
        _isListening.value = true;
        speechToText.listen(
            listenFor: const Duration(days: 1),
            onResult: (result) {
                textEditingController.text = result.recognizedWords;
            });
      }
    } else {
      _isListening.value = false;
      speechToText.stop();
    }
  }
}
