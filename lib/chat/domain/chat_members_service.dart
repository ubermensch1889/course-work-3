// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'package:test/consts.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ChatMembersService {
  Future<List<String>?> getChatMembers(String chatId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse('https://5716b573-68b3-42b1-a282-2132ac02ea10.mock.pstmn.io/v1/messenger/chat_members');
    final body = jsonEncode({
      'chat_id': chatId,
    });

    print('тело запроса $body');
    try {
      final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: body
      );

      print('Bearer $token');

      if (response.statusCode == 200) {
        print(json.decode(utf8.decode(response.bodyBytes)));
        List<dynamic> result = json.decode(utf8.decode(response.bodyBytes))['members_id'];
        return result.map((item) => item.toString()).toList();
      }
      print('Ошибка создания чата: ${response.statusCode}');
      print('Ответ: ${response.body}');
    } catch (e) {
      print('Исключение при получении пользователей: $e');
    }

    return null;
  }
}
