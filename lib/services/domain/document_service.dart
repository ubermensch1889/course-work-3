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

    final url = Uri.parse('http://51.250.110.96:8080/v1/documents/list');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['documents'];
      List<DocumentItem> documents =
          body.map((dynamic item) => DocumentItem.fromJson(item)).toList();
      return documents;
    } else {
      throw Exception('Failed to load documents: ${response.statusCode}');
    }
  }
}
