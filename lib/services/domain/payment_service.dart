import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/services/data/payment.dart';
import 'package:test/user/domain/user_preferences.dart';

class PaymentApi {
  static Future<List<Payment>> getPayments() async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    var url = Uri.parse('https://working-day.online:8080/v1/payments');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var json = jsonDecode(responseBody) as Map<String, dynamic>;
      List<dynamic> paymentsJson = json['payments'] as List<dynamic>;
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } else {
      var responseBody = utf8.decode(response.bodyBytes);
      // ignore: avoid_print
      print('Response body: $responseBody');
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
