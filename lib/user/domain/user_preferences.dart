// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/user/data/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/user/data/user_action.dart';

class UserPreferences {
  static Future<void> saveCompanyId(String companyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Saving company_id: $companyId");
    await prefs.setString('company_id', companyId);
  }

  static Future<String?> getCompanyId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_id');
  }

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Saving token: $token");
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var userId = prefs.getString('user_id');
    userId ??= (await fetchProfileInfo()).id;

    return userId;
  }

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> logout() async {
    if (_prefs == null) await init();
    print("Logging out. Current token: ${_prefs!.getString('auth_token')}");
    await _prefs!.clear();
    print("Logged out. Current token: ${_prefs!.getString('auth_token')}");
  }

  static Future<User> fetchProfileInfo() async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    var url = Uri.parse('https://working-day.su:8080/v1/employee/info');
    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var userData = jsonDecode(responseBody);
      var user = User.fromJson(userData);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_id', user.id);

      return user;
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }

  static Future<User> fetchUserInfoById(String userId) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    var url = Uri.parse('https://working-day.su:8080/v1/employee/info')
        .replace(queryParameters: {'employee_id': userId});
    var headers = {'Authorization': 'Bearer $token'};

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var userData = jsonDecode(responseBody);
      return User.fromJson(userData);
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }

  static Future<List<UserAction>> fetchUserActions(
      String from, String to, String? employeeId) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Токен не существует');
    }

    var url = Uri.parse('https://working-day.su:8080/v1/actions');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var body = jsonEncode({
      'from': from,
      'to': to,
      if (employeeId != null) 'employee_id': employeeId,
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var json = jsonDecode(responseBody) as Map<String, dynamic>;
      List<dynamic> actionsJson = json['actions'] as List<dynamic>;
      return actionsJson
          .map((actionJson) => UserAction.fromJson(actionJson))
          .toList();
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }
}
