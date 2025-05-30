// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'dart:convert';
import 'package:test/consts.dart';
import 'package:test/user/domain/user_preferences.dart';

import '../../user/data/user.dart';

class ChatListService {
  List<MessengerListedChatInfo>? _cachedChats;

  Future<List<MessengerListedChatInfo>> _fetchChats() async {
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

      print('Bearer $token');

      if (response.statusCode == 200) {
        print('Ответ сервера: ${utf8.decode(response.bodyBytes)}');
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes))['chats'];
        print(body);

        List<MessengerListedChatInfo> chats = body.map((dynamic item) => MessengerListedChatInfo.fromJson(item)).toList();
        chats.sort((a, b) {
          if (a.lastMessage != null && b.lastMessage != null) {
            return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
          }

          if (a.lastMessage != null) return -1;
          if (b.lastMessage != null) return 1;
          return a.chatName.compareTo(b.chatName);
        });
        return chats;
      }
      throw Exception('Failed to load chats: ${response.statusCode}');

    } catch (e) {
      throw Exception('Исключение при загрузке чатов: $e');
    }
  }

  Future<List<MessengerListedChatInfo>> fetchAndAdjustChats() async {
    _cachedChats = await _fetchChats();
    final userId = await UserPreferences.getUserId();

    List<Future<void>> tasks = [];

    for (var chat in _cachedChats!) {
      if (!chat.isPersonal()) {
        continue;
      }
      tasks.add(() async {
        final secondParticipantId = chat.getSecondParticipantId(userId);
        if (secondParticipantId == null) return;
        User anotherUser;
        try {
          anotherUser = await UserPreferences.fetchUserInfoById(secondParticipantId);
        } catch (e) {
          print("Ошибка загрузки пользователей: $e");
          return;
        }

        chat.photoUrl = anotherUser.photo_link;
        chat.personalChatName = anotherUser.getFullName();
      }());
    }

    await Future.wait(tasks);

    return _cachedChats!;
  }

  Future<List<MessengerListedChatInfo>> searchChats(String query) async {
    _cachedChats ??= await fetchAndAdjustChats();

    if (query.isEmpty) {
      return [];
    }

    final normalizedQuery = query.toLowerCase().trim();
    return _cachedChats!.where((chat) {
      final name = chat.getPrettyChatName().toLowerCase();
      return name.contains(normalizedQuery);
    }).toList();
  }
}
