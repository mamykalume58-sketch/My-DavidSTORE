import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl =
      'https://davidstore-payment.vercel.app';

  static Future<Map<String, dynamic>> pay({
    required int amount,
    required String phone,
    required String orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/shwary/pay'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'clientPhoneNumber': phone,
        'orderId': orderId,
        'sandbox': true,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
