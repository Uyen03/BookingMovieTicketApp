import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteController extends GetxController {
  var votes = 0.obs; // Sử dụng Rx để quản lý votes

  // Hàm để cập nhật votes vào Firestore và local
  Future<void> updateVotes(String movieId, String userId) async {
    // Lấy bộ phim từ Firestore
    var movieDoc = await FirebaseFirestore.instance
        .collection('movies')
        .doc(movieId)
        .get();

    // Lấy dữ liệu movie
    var movieData = movieDoc.data();
    if (movieData != null) {
      // Kiểm tra xem người dùng đã đánh giá chưa
      List<dynamic> userVotes = movieData['userVotes'] ?? [];
      if (!userVotes.contains(userId)) {
        // Thêm người dùng vào danh sách userVotes
        userVotes.add(userId);

        // Cập nhật lại danh sách userVotes và số lượng votes
        await FirebaseFirestore.instance
            .collection('movies')
            .doc(movieId)
            .update({
          'userVotes': userVotes,
        });

        // Cập nhật lại giá trị votes
        votes.value = userVotes.length;
      }
    }
  }

  // Hàm để lấy số lượng votes từ Firestore
  Future<void> fetchVotes(String movieId) async {
    var movieDoc = await FirebaseFirestore.instance
        .collection('movies')
        .doc(movieId)
        .get();

    if (movieDoc.exists) {
      var movieData = movieDoc.data();
      if (movieData != null) {
        // Lấy số lượng votes từ danh sách userVotes
        List<dynamic> userVotes = movieData['userVotes'] ?? [];
        votes.value = userVotes.length; // Cập nhật số lượng votes
      }
    }
  }
}
