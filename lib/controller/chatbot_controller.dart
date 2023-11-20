import 'package:chatapp/models/chatbot_model.dart';
import 'package:chatapp/models/models_model.dart';
import 'package:chatapp/service/api_service.dart';
import 'package:get/get.dart';

class ChatBotController extends GetxController {
  RxList<ChatBotModel> chatList = <ChatBotModel>[].obs;

  List<ChatBotModel> get getChatList => chatList.toList();
RxString currentModel = "gpt-3.5-turbo-0301".obs;

  String get getCurrentModel {
    return currentModel.value;
  }

  void setCurrentModel(String newModel) {
    currentModel.value = newModel;
    update();
  }

  RxList<ModelsModel> modelsList = <ModelsModel>[].obs;

  RxList<ModelsModel> get getModelsList {
    return modelsList;
  }

  Future<List<ModelsModel>> getAllModels() async {
    modelsList.assignAll(await ApiService.getModels());
    return modelsList;
  }
  void addUserMessage({required String msg}) {
    chatList.add(ChatBotModel(msg: msg, chatIndex: 0));
    update();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        message: msg,
        modelId: chosenModelId,
      ));
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
      ));
    }
    update();
  }
}
