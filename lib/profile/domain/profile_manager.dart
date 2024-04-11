// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:test/user/data/user_profile_update.dart';

class ProfileManager {
  Future<User?> fetchUserProfile() async {
    return UserPreferences.fetchProfileInfo();
  }

  Future<bool> saveUserProfile(UserProfileUpdate update) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      print('Error: Authorization token is missing');
      return false;
    }

    var url = Uri.parse('https://working-day.online:8080/v1/profile/edit');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      'password': update.password,
      'birthday': update.birthday,
      'telegram_id': update.telegram_id,
      'vk_id': update.vk_id,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          print('Response body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      print('Error sending request: $e');
      return false;
    }
  }
}
