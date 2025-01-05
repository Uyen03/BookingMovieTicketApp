import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to fetch data with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during GET request: $e");
      return null;
    }
  }
}
