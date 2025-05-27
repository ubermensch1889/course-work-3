import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test/user/domain/user_preferences.dart';
import 'package:test/consts.dart';

class AbsenceService {
  static Future<bool> requestAbsence(
      DateTime startDate, DateTime endDate, String type) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      return false;
    }

    final url =
        Uri.parse('$baseUrl/v1/abscence/request');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'type': type,
      }),
    );

    return response.statusCode == 200;
  }
}
