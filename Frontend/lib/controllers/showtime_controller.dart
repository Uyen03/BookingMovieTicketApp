import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/showtime.dart';

class ShowtimeController extends GetxController {
  var isLoading = false.obs;
  var showtimes = <Showtime>[].obs;

  // API endpoint
  final String apiUrl = 'http://10.0.2.2:5130/api/showtimes';

  // Hàm gọi API để tải danh sách showtime
  Future<void> fetchShowtimes() async {
    try {
      isLoading.value = true;
      print("Fetching data from $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isNotEmpty) {
          showtimes.value = jsonData.map((e) => Showtime.fromJson(e)).toList();
          print("Loaded ${showtimes.length} showtimes");
        } else {
          print("No data found in API response.");
          showtimes.clear();
        }
      } else {
        print("Failed to fetch showtimes: ${response.statusCode}");
        Get.snackbar(
            'Error', 'Failed to fetch showtimes: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching showtimes: $e");
      showtimes.clear();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Lọc danh sách showtime theo rạp, ngày và khung giờ
  List<Showtime> filterShowtimesByTheatreDateAndTimeRange(
      int theatreId, DateTime date, String timeRange) {
    final filteredShowtimes = showtimes.where((showtime) {
      final isSameTheatre = showtime.theatre.id == theatreId;
      final isSameDate = showtime.startTime.year == date.year &&
          showtime.startTime.month == date.month &&
          showtime.startTime.day == date.day;
      return isSameTheatre && isSameDate;
    }).toList();

    if (timeRange == "Tất cả") return filteredShowtimes;

    final timeParts = timeRange.split(' - ');
    final startHour = int.parse(timeParts[0].split(':')[0]);
    final endHour = int.parse(timeParts[1].split(':')[0]);

    return filteredShowtimes.where((showtime) {
      final showtimeHour = showtime.startTime.hour;
      return showtimeHour >= startHour && showtimeHour < endHour;
    }).toList();
  }

  // Tìm danh sách showtime theo movie ID
  List<Showtime> filterShowtimesByMovie(int movieId) {
    return showtimes.where((showtime) => showtime.movie.id == movieId).toList();
  }

  // Lấy chi tiết showtime theo ID
  Showtime? getShowtimeById(int id) {
    return showtimes.firstWhereOrNull((showtime) => showtime.id == id);
  }

  @override
  void onInit() {
    super.onInit();
    fetchShowtimes();
  }
}
