import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchService {
  Future<List<User>> searchUsers(String searchKey) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      return [];
    }

    final response = await http.post(
      Uri.parse('http://51.250.110.96:8080/v1/search/basic'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'search_key': searchKey,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final responseData = json['employees'] as List<dynamic>;
      return responseData.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      return [];
    }
  }
}
