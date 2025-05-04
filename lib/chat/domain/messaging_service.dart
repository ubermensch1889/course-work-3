import 'package:http/http.dart' as http;
import 'package:test/chat/data/chat.dart';
import 'dart:convert';
import 'package:test/chat/data/chat.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingService {
  Future<void> sendMessage(String chatId, String content, WebSocketChannel channel) async {
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
        'company_id': companyId
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

    final url = Uri.parse('https://working-day.su:8080/v1/messenger/recent-messages');
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
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        print('govb');
        print(body[0]);
        List<MessengerMessage> messages = body.map((dynamic item) => MessengerMessage.fromJson(json.decode(item))).toList();
        print('jop');
        return messages;
      }
      print('Ошибка загрузки сообщений: ${response.statusCode}');
      print('Ответ: ${response.body}');
      throw Exception('Failed to load messages: ${response.statusCode}');

    } catch (e) {
      print('Исключение при получении сообщений: $e');
      rethrow;
    }
  }
}
