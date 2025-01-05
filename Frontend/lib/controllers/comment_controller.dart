import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchComments(int movieId) async {
  final response = await http.get(
    Uri.parse(
        'http://10.0.2.2:5130/api/Comments/$movieId'), // Thay bằng URL của bạn
  );

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception("Failed to load comments");
  }
}
