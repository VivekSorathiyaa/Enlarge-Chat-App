class ChatBotModel {
  final String msg;
  final int chatIndex;

  ChatBotModel({required this.msg, required this.chatIndex});

  factory ChatBotModel.fromJson(Map<String, dynamic> json) => ChatBotModel(
        msg: json["msg"],
        chatIndex: json["chatIndex"],
      );
}