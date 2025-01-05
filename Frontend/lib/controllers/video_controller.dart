import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoController {
  static const String apiUrl = "http://localhost:5130/api/movies";

  // Hàm tải danh sách phim từ API
  static Future<List<dynamic>> fetchMovies() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> moviesJson = jsonDecode(response.body);
        return moviesJson.map((json) => _mapMovieData(json)).toList();
      } else {
        throw Exception("Failed to load movies: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching movies: $e");
    }
  }

  // Xử lý URL (chuyển đổi localhost -> 10.0.2.2 nếu cần thiết)
  static Map<String, dynamic> _mapMovieData(Map<String, dynamic> json) {
    final String? trailerUrl = json['TrailerUrl'];
    final String? bannerUrl = json['BannerUrl'];

    return {
      ...json,
      'TrailerUrl': trailerUrl != null ? _fixUrl(trailerUrl) : null,
      'BannerUrl': bannerUrl != null ? _fixUrl(bannerUrl) : null,
    };
  }

  // Hàm sửa URL localhost thành 10.0.2.2 (cho Android Emulator)
  static String _fixUrl(String url) {
    return url.replaceFirst("localhost", "10.0.2.2");
  }
}
