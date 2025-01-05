import 'dart:convert';
import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MovieController extends GetxController {
  var isLoading = true.obs; // Trạng thái tải dữ liệu
  var movies = <Movie>[].obs; // Danh sách phim
  late UserModel currentUser; // Người dùng hiện tại
  var filteredMovies = <Movie>[].obs; // Danh sách phim đã lọc

  @override
  void onInit() {
    super.onInit();
    fetchMovies();
  }

  // Đặt thông tin người dùng hiện tại
  void setCurrentUser(UserModel user) {
    currentUser = user;
  }

  // Lọc phim theo tiêu chí
  void filterMovies(String query) {
    if (query.isEmpty) {
      filteredMovies.value = movies;
    } else {
      filteredMovies.value = movies.where((movie) {
        return movie.title.toLowerCase().contains(query.toLowerCase()) ||
            movie.genres.any(
                (genre) => genre.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
  }

  // Tải danh sách phim từ API
  Future<void> fetchMovies() async {
    try {
      isLoading(true); // Bắt đầu tải
      var url = Uri.parse("http://10.0.2.2:5130/api/movies");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        movies.value = List<Movie>.from(
          jsonData.map((item) => Movie.fromJson(item)),
        );
        filteredMovies.value = movies; // Cập nhật danh sách phim đã lọc
        print("Movies fetched: ${movies.map((m) => m.bannerUrl).toList()}");
      } else {
        print("Failed to fetch movies: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to fetch movies: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching movies: $e");
      Get.snackbar('Error', 'Error fetching movies: $e');
    } finally {
      isLoading(false); // Kết thúc tải
    }
  }

  // Làm mới danh sách phim
  Future<void> refreshMovies() async {
    await fetchMovies();
  }

  // Lấy phim theo ID
  Movie? getMovieById(int id) {
    try {
      return movies.firstWhere((movie) => movie.id == id);
    } catch (e) {
      print("Movie with ID $id not found.");
      return null;
    }
  }
}
