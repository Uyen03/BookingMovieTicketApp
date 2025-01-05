import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  final String _baseUrl = "http://10.0.2.2:5130/api/ZaloPay/create-payment";

  Future<String?> createPayment({
    required String bookingId,
    required double amount,
  }) async {
    try {
      print("Sending Payment Request...");
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount.toInt(),
          "MovieTitle": "Vé xem phim",
          "User": "testuser",
        }),
      );

      // Log response để kiểm tra
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data["paymentUrl"];

        if (url != null && url.isNotEmpty) {
          print("Received Payment URL: $url");
          return url; // Trả về URL thanh toán
        } else {
          print("Error: paymentUrl is null or empty.");
          return null;
        }
      } else {
        print("Server Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
