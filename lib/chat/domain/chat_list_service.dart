// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'dart:convert';
import 'package:test/chat/data/chat.dart';
import 'package:test/user/domain/user_preferences.dart';

class ChatListService {
  Future<List<ChatItem>> fetchChats() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    // TODO: написать логику получения списка сообщений из сервера и из памяти
    // final url = Uri.parse('https://working-day.online:8080/v1/chats/list');
    // try {
    //   final response = await http.get(
    //     url,
    //     headers: {
    //       'Authorization': 'Bearer $token',
    //     },
    //   );
    //
    //   if (response.statusCode == 200) {
    //     // print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
    //     // List<dynamic> body =
    //     // json.decode(utf8.decode(response.bodyBytes))['chats'];
    //     // List<DocumentItem> documents =
    //     // body.map((dynamic item) => DocumentItem.fromJson(item)).toList();
    //     // return documents;
    //   } else {
    //     print('Ошибка загрузки документов: ${response.statusCode}');
    //     print('Ответ: ${response.body}');
    //     throw Exception('Failed to load documents: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Исключение при загрузке документов: $e');
    //   throw Exception('Exception during fetchDocuments: $e');
    // }

    final chats = <ChatItem>[
      ChatItem(
          id: 'id',
          name: 'Владимир Игнатьев',
          lastMessageText: 'Привет! Когда будет готов отчет?',
          lastMessageDate: '9:25',
          imageUrl: "https://i.imgur.com/PCvDtt3.png",
          chatType: ChatType.personal,
      ),
      ChatItem(
        id: 'id',
        name: 'Алексей Гончаров',
        lastMessageText: 'Отлично, договорились',
        lastMessageDate: '9:20',
        chatType: ChatType.personal,
        messageStatus: MessageStatus.read,
      ),
      ChatItem(
        id: 'id',
        name: 'Дмитрий Иванов',
        lastMessageText: 'Да, как скажешь',
        lastMessageDate: 'Пт',
        chatType: ChatType.personal,
        messageStatus: MessageStatus.delivered,
      ),
      ChatItem(
        id: 'id',
        name: 'Команда Альфа',
        lastMessageText: 'понял',
        lastMessageDate: 'Пт',
        chatType: ChatType.group,
        lastMessageAuthorName: 'Сергей',
      ),
    ];

    return chats + chats + chats;
  }
}
