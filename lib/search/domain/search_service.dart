import 'package:http/http.dart' as http;
import 'package:test/consts.dart';
import 'dart:convert';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchService {
  Future<List<User>> searchUsers(String searchKey, {int limit = 5}) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      return [];
    }

    final response = await http.post(
      Uri.parse('$baseUrl/v1/search/full'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'search_key': searchKey,
        'limit': limit,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final responseData = json['employees'] as List<dynamic>;
      return responseData.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<List<User>> suggestUsers(String searchKey, {int limit = 5}) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      return [];
    }

    final response = await http.post(
      Uri.parse('$baseUrl/v1/search/suggest'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'search_key': searchKey,
        'limit': limit,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final responseData = json['employees'] as List<dynamic>;
      return responseData.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
