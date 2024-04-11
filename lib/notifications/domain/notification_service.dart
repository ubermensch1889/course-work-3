// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/notifications/data/notification.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  Future<NotificationsResponse> fetchNotifications(String token) async {
    const url = 'https://working-day.online:8080/v1/notifications';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return NotificationsResponse.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<bool> sendAbsenceVerdict(
      String token, String actionId, bool approve) async {
    const url = 'https://working-day.online:8080/v1/absence/verdict';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({'action_id': actionId, 'approve': approve}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error sending verdict: ${response.body}');
    }
  }

  Future<String?> fetchVacationDocumentLink(
      String token, String actionId, String requestType) async {
    const url = 'https://working-day.online:8080/v1/documents/vacation';
    final uri = Uri.parse(url).replace(
        queryParameters: {'action_id': actionId, 'request_type': requestType});
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Error requesting document: ${response.statusCode}');
      return null;
    }
  }

  Future<File> downloadFile(String url) async {
    var response = await http.get(Uri.parse(url));
    var bytes = response.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/document.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  markNotificationAsRead(String id) {}
}
