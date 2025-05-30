// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'package:test/consts.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ChatCreationService {
  Future<String?> createGroupChat(String chatName, List<String> userIds) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final url = Uri.parse('$baseUrl/v1/messenger/create-chat');
    final body = jsonEncode({
      'chat_name': chatName,
      'id_list': userIds.map((String id) => id).toList() + [await UserPreferences.getUserId()]
    });

    print('Создание группового чата: $chatName');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: body
      );

      if (response.statusCode == 200) {
        final chatId = json.decode(utf8.decode(response.bodyBytes))['chat_id'];
        print('Групповой чат успешно создан');
        return chatId;
      }
      print('Ошибка при создании группового чата. Код: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Ошибка при создании группового чата: $e');
      return null;
    }
  }

  Future<String?> createPersonalChat(String anotherUserId) async {
    var userId = await UserPreferences.getUserId();
    var chatName = '_ps_${userId}_${anotherUserId}_ps_';
    print('Создание личного чата с пользователем: $anotherUserId');
    return await createGroupChat(chatName, [anotherUserId]);
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('Изображение не выбрано');
      return null;
    }
  }

  Future<List<User>> getEmployees() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse('$baseUrl/v1/employees');

    try {
      final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          }
      );

      print('Bearer $token');

      if (response.statusCode == 200) {
        print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes))['employees'];
        List<User> employees = body.map((dynamic item) => User.fromJson(item)).toList();
        return employees;
      }
      print('Ошибка создания чата: ${response.statusCode}');
      print('Ответ: ${response.body}');
    } catch (e) {
      print('Исключение при создании чата: $e');
    }

    return List.empty();
  }

  Future<MessengerListedChatInfo?> getChatWithEmployee(String anotherUserId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final employeeId = await UserPreferences.getUserId();
    final url = Uri.parse('$baseUrl/v1/messenger/list-chats?employee_id=$employeeId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes))['chats'];
        print(body);

        List<MessengerListedChatInfo> chats = body.map((dynamic item) => MessengerListedChatInfo.fromJson(item)).toList();

        return chats.firstWhere((chat) => chat.isPersonal() && chat.getSecondParticipantId(employeeId) == anotherUserId);
      }

      throw Exception('Ошибка загрузки чатов: ${response.statusCode}');
    } catch (e) {
      print('Исключение при загрузке чатов: $e');
      return null;
    }
  }
}
