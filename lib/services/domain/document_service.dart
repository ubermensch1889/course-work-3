import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test/services/data/document.dart';
import 'package:test/user/domain/user_preferences.dart';

class DocumentsService {
  Future<List<DocumentItem>> fetchDocuments() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse('https://working-day.online:8080/v1/documents/list');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body =
          json.decode(utf8.decode(response.bodyBytes))['documents'];
      List<DocumentItem> documents =
          body.map((dynamic item) => DocumentItem.fromJson(item)).toList();
      return documents;
    } else {
      throw Exception('Failed to load documents: ${response.statusCode}');
    }
  }

  Future<String> downloadDocument(String documentId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse(
        'http://working-day.online:8080/v1/documents/download?id=$documentId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      String downloadUrl = body['url'];
      return downloadUrl;
    } else {
      throw Exception('Failed to download document: ${response.statusCode}');
    }
  }

  Future<void> signDocument(String documentId) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    final url = Uri.parse(
        'http://working-day.online:8080/v1/documents/sign?document_id=$documentId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Документ успешно подписан.");
      } else {
        // Ошибка сервера
        print("Ошибка подписания документа: ${response.statusCode}");
        print("Тело ответа: ${response.body}");
      }
    } catch (e) {
      // Ошибка выполнения HTTP запроса
      print("Исключение при попытке подписать документ: $e");
    }
  }
}
