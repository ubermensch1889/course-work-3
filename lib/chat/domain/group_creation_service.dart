// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:image_picker/image_picker.dart';

class GroupCreationService {
  Future<bool> tryCreateChat(String chatName, List<SuggestedUser> users) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse('https://working-day.su:8080/v1/messenger/create-chat');
    final body = jsonEncode({
      'chat_name': chatName,
      'id_list': users.map((SuggestedUser user) => user.userId).toList() + [await UserPreferences.getUserId()]
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
        print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
        return true;
      }
      print('Ошибка создания чата: ${response.statusCode}');
      print('Ответ: ${response.body}');
    } catch (e) {
      print('Исключение при создании чата: $e');
    }

    return false;
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected');
      return null;
    }
  }
}
