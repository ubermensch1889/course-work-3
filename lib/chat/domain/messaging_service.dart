import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:test/chat/data/chat.dart';
import 'dart:convert';
import 'package:test/chat/data/chat.dart';
import 'package:test/consts.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingService {
  Future<void> sendMessage(String chatId, String content, WebSocketChannel channel, {List<Media>? media}) async {
    String employeeId = await UserPreferences.getUserId();
    String? companyId = await UserPreferences.getCompanyId();
    if (companyId == null) {
      throw Exception("Unauthorised user can not send messages");
    }

    final message = {
      'chat_id': chatId,
      'sender_id': employeeId,
      'content': {
        'content': content,
        'company_id': companyId,
        if (media != null && media.isNotEmpty) 'media': media.map((m) => {
          'type': m.type,
          'url': m.url
        }).toList(),
      }
    };
    final jsonMessage = json.encode(message);

    try {
      channel.sink.add(jsonMessage);

      print('Sent: $jsonMessage');
    } catch (e) {
      print('Исключение при отправке сообщения: $e');
      throw Exception('Exception during message sending: $e');
    }
  }

  Future<List<MessengerMessage>> getRecentMessages(String chatId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse('$baseUrl/v1/messenger/recent-messages');
    final body = jsonEncode({
      'chat_id': chatId
    });

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
        var bodyRaw = json.decode(utf8.decode(response.bodyBytes));
        if (bodyRaw == null) {
          return List.empty();
        }
        List<dynamic> body = bodyRaw;

        print('govb');
        print(body.isNotEmpty ? body[0] : 'empty');
        List<MessengerMessage> messages = body.map((dynamic item) => MessengerMessage.fromJson(json.decode(item))).toList();

        if (messages.isNotEmpty && messages[messages.length - 1].senderId.isEmpty) {
          messages.removeAt(messages.length - 1);
        }
        print('jop');
        return messages.reversed.toList();
      }
      print('Ошибка загрузки сообщений: ${response.statusCode}');
      print('Ответ: ${response.body}');
      throw Exception('Failed to load messages: ${response.statusCode}');

    } catch (e) {
      print('Исключение при получении сообщений: $e');
      rethrow;
    }
  }

  Future<List<PlatformFile>?> pickFiles({bool allowMultiple = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      return result.files;
    }
    return null;
  }

}
