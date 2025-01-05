import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingmovieticket/models/movie_model.dart';

class MovieController extends GetxController {
  var isLoading = true.obs; // Trạng thái tải dữ liệu
  var movies = <Movie>[].obs; // Danh sách phim

  // Tải dữ liệu từ Firestore
  Future<void> fetchMovies() async {
    try {
      isLoading(true); // Đang tải dữ liệu
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('movies').get();
      movies.clear(); // Xóa danh sách phim cũ

      for (var doc in snapshot.docs) {
        movies.add(Movie.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error fetching movies: $e");
    } finally {
      isLoading(false); // Xong rồi, không còn tải dữ liệu nữa
    }
  }

  @override
  void onInit() {
    fetchMovies(); // Tải phim khi controller khởi tạo
    super.onInit();
  }
}
