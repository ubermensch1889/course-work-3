import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:test/main.dart';
import 'package:test/user/domain/user_preferences.dart';

class AuthManager {
  Future<bool> authenticate(
      String login, String password, WidgetRef ref) async {
    await UserPreferences.logout();

    final url = Uri.parse('https://working-day.online:8080/v1/authorize');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'login': login,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String token = responseData['token'];
      final String role = responseData['role'];
      await UserPreferences.saveToken(token);
      await UserPreferences.saveRole(role);
      ref.read(authStateProvider.notifier).state = true;
      return true;
    }
    return false;
  }
}
