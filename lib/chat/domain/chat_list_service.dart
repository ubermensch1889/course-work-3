// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'dart:convert';
import 'package:test/chat/data/chat.dart';
import 'package:test/user/domain/user_preferences.dart';

class ChatListService {
  Future<List<MessengerListedChatInfo>> fetchChats() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final employeeId = await UserPreferences.getUserId();
    final url = Uri.parse('https://working-day.su:8080/v1/messenger/list-chats?employee_id=$employeeId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Bearer $token');

      if (response.statusCode == 200) {
        print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes))['chats'];
        List<MessengerListedChatInfo> chats = body.map((dynamic item) => MessengerListedChatInfo.fromJson(item)).toList();
        return chats;
      }
      print('Ошибка загрузки чатов: ${response.statusCode}');
      print('Ответ: ${response.body}');
      throw Exception('Failed to load chats: ${response.statusCode}');

    } catch (e) {
      print('Исключение при загрузке чатов: $e');
      throw Exception('Exception during fetchDocuments: $e');
    }
  }
}
