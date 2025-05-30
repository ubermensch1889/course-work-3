import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:test/chat/data/chat.dart';
import 'package:test/consts.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingService {
  Future<void> sendMessage(String chatId, String content, WebSocketChannel channel, {List<Media>? media}) async {
    String employeeId = await UserPreferences.getUserId();
    String? companyId = await UserPreferences.getCompanyId();
    if (companyId == null) {
      throw Exception("Неавторизованный пользователь не может отправлять сообщения");
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
      print('Сообщение отправлено: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}');
    } catch (e) {
      print('Ошибка при отправке сообщения: $e');
      throw Exception('Ошибка при отправке сообщения: $e');
    }
  }

  Future<List<MessengerMessage>> getRecentMessages(String chatId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
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

      if (response.statusCode == 200) {
        var bodyRaw = json.decode(utf8.decode(response.bodyBytes));
        if (bodyRaw == null) {
          return List.empty();
        }
        List<dynamic> body = bodyRaw;

        List<MessengerMessage> messages = body
            .map((dynamic item) => MessengerMessage.fromJson(json.decode(item)))
            .toList();

        if (messages.isNotEmpty && messages[messages.length - 1].senderId.isEmpty) {
          messages.removeAt(messages.length - 1);
        }
        
        print('Загружено ${messages.length} сообщений');
        return messages.reversed.toList();
      }

      throw Exception('Не удалось загрузить сообщения');
    } catch (e) {
      print('Ошибка при получении сообщений: $e');
      rethrow;
    }
  }

  Future<List<PlatformFile>?> pickFiles({bool allowMultiple = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.any,
    );

    if (result != null) {
      return result.files;
    }
    return null;
  }

  Future<Media> uploadFile(PlatformFile file) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    // Получаем URL для загрузки файла
    final uploadUrlResponse = await http.get(
      Uri.parse('$baseUrl/v1/messenger/get-upload-url'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (uploadUrlResponse.statusCode != 200) {
      throw Exception('Не удалось получить URL для загрузки файла');
    }

    final uploadUrl = json.decode(uploadUrlResponse.body)['url'];
    
    // Загружаем файл
    final fileBytes = await File(file.path!).readAsBytes();
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      body: fileBytes,
      headers: {'Content-Type': 'application/octet-stream'},
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception('Ошибка при загрузке файла');
    }

    // Определяем тип файла
    String mediaType = 'file';
    if (file.extension?.toLowerCase() == 'pdf') {
      mediaType = 'pdf';
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(file.extension?.toLowerCase())) {
      mediaType = 'image';
    }

    return Media(mediaType, uploadUrl.split('?')[0]); // Возвращаем URL без параметров запроса
  }
}
