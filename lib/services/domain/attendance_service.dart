import 'package:http/http.dart' as http;
import 'package:test/services/data/attendance.dart';
import 'dart:convert';
import 'package:test/user/domain/user_preferences.dart';

class AttendanceService {
  static const String _baseUrl = 'https://working-day.su:8080/v1';

  static Future<void> addAttendance(
      String employeeId, String startDate, String endDate) async {
    String? token = await UserPreferences.getToken();
    if (token == null) throw Exception('Токен не существует');

    var url = Uri.parse('$_baseUrl/attendance/add?employee_id=$employeeId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      'start_date': startDate,
      'end_date': endDate,
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Ошибка добавления посещения: ${response.statusCode}');
    }
  }

  static Future<List<AttendanceRecord>> fetchAllAttendances(
      String from, String to) async {
    String? token = await UserPreferences.getToken();
    if (token == null) throw Exception('Токен не существует');

    var url = Uri.parse('$_baseUrl/attendance/list-all');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      'from': from,
      'to': to,
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        var jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> attendancesJson = jsonResponse['attendances'];
        return attendancesJson
            .map((attendanceJson) => AttendanceRecord.fromJson(attendanceJson))
            .toList();
      } on FormatException catch (e) {
        throw Exception('Ошибка формата данных: ${e.message}');
      }
    } else if (response.body.isEmpty) {
      throw Exception('Получен пустой ответ от сервера.');
    } else {
      throw Exception(
          'Ошибка получения списка посещений: ${response.statusCode}');
    }
  }
}
