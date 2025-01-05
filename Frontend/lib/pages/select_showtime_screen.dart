import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/pages/select_seat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/showtime_controller.dart';
import '../models/showtime.dart';

class ShowtimeSelectorScreen extends StatefulWidget {
  final String theatreName;
  final int theatreId;
  final UserModel user; // Thêm thông tin người dùng vào constructor

  const ShowtimeSelectorScreen({
    Key? key,
    required this.theatreName,
    required this.theatreId,
    required this.user, // Thêm đối tượng user ở đây
  }) : super(key: key);

  @override
  _ShowtimeSelectorScreenState createState() => _ShowtimeSelectorScreenState();
}

class _ShowtimeSelectorScreenState extends State<ShowtimeSelectorScreen> {
  final ShowtimeController showtimeController = Get.put(ShowtimeController());
  DateTime selectedDate = DateTime.now();
  String selectedTimeRange = "Tất cả";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(widget.theatreName, style: const TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildTimeRangeSelector(),
          Expanded(
            child: Obx(() {
              if (showtimeController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final showtimes =
                  showtimeController.filterShowtimesByTheatreDateAndTimeRange(
                widget.theatreId,
                selectedDate,
                selectedTimeRange,
              );

              if (showtimes.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có suất chiếu phù hợp.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                );
              }

              final groupedByMovie = groupShowtimesByMovie(showtimes);

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: groupedByMovie.length,
                itemBuilder: (context, index) {
                  final movie = groupedByMovie.keys.elementAt(index);
                  final movieShowtimes = groupedByMovie[movie]!;
                  return _buildMovieCard(movie, movieShowtimes);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final List<DateTime> dates = List.generate(7, (index) {
      final now = DateTime.now();
      return now.add(Duration(days: index));
    });

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dates.map((date) {
            final isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                  selectedTimeRange = "Tất cả"; // Reset khung giờ khi chọn ngày
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pinkAccent : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.pinkAccent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getWeekday(date.weekday),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${date.day}/${date.month}",
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final List<String> timeRanges = _generateTimeRanges(selectedDate);

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: timeRanges.map((timeRange) {
            final isSelected = timeRange == selectedTimeRange;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTimeRange = timeRange;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pinkAccent : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.pinkAccent : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  timeRange,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<String> _generateTimeRanges(DateTime selectedDate) {
    final now = DateTime.now();
    final startHour = (selectedDate.day == now.day &&
            selectedDate.month == now.month &&
            selectedDate.year == now.year)
        ? (now.hour < 9 ? 9 : now.hour)
        : 9;

    final List<String> timeRanges = [];
    for (int i = startHour; i < 24; i += 3) {
      final endHour = (i + 3) <= 24 ? (i + 3) : 24;
      final range =
          "${i.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00";
      timeRanges.add(range);
    }

    return ["Tất cả", ...timeRanges];
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return "Thứ 2";
      case 2:
        return "Thứ 3";
      case 3:
        return "Thứ 4";
      case 4:
        return "Thứ 5";
      case 5:
        return "Thứ 6";
      case 6:
        return "Thứ 7";
      case 7:
        return "CN";
      default:
        return "Unknown";
    }
  }

  Map<String, List<Showtime>> groupShowtimesByMovie(List<Showtime> showtimes) {
    final Map<String, List<Showtime>> grouped = {};
    for (var showtime in showtimes) {
      final movieTitle = showtime.movie?.title ?? 'Phim không xác định';
      if (!grouped.containsKey(movieTitle)) {
        grouped[movieTitle] = [];
      }
      grouped[movieTitle]!.add(showtime);
    }
    return grouped;
  }

  Widget _buildMovieCard(String movieTitle, List<Showtime> showtimes) {
    final movie = showtimes.first.movie;
    final genres = movie?.genres?.join(", ") ?? "Không xác định";
    final formats = movie?.formats?.join(", ") ?? "Không xác định";
    final duration = movie?.durationInMinutes ?? 0;
    final ageRating = movie?.ageRating ?? "Không xác định";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie?.bannerUrl != null)
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          _getFullImageUrl(movie!.bannerUrl!),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getAgeRatingColor(ageRating),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ageRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "$genres | $formats | $duration phút",
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: showtimes.map((showtime) {
                final startTime = formatTime(showtime.startTime);
                final endTime = formatTime(showtime.endTime);
                return ElevatedButton(
                  onPressed: () {
                    if (showtime.screen.id > 0) {
                      Get.to(() => SeatSelectionPage(
                            key: ValueKey(
                                showtime.id), // Đảm bảo tái tạo lại widget
                            screenId: showtime.screen.id,
                            screenName:
                                showtime.screen.name ?? "Không xác định",
                            theatreName: widget.theatreName,
                            showtime: showtime,
                            selectedSeats: [],
                            user: widget.user,
                            format: showtime.format ?? "Không xác định",
                          ));
                    } else {
                      print("Invalid Screen ID: ${showtime.screen.id}");
                      // Hiển thị thông báo lỗi
                      Get.snackbar("Lỗi", "Screen ID không hợp lệ");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pinkAccent,
                    side: const BorderSide(color: Colors.pinkAccent),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        startTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        " ~ $endTime",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Color _getAgeRatingColor(String ageRating) {
    switch (ageRating.toUpperCase()) {
      case "P":
        return Colors.green;
      case "C13":
        return Colors.orange;
      case "C18":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFullImageUrl(String bannerUrl) {
    const baseUrl = "http://10.0.2.2:5130"; // Thay đổi nếu cần
    return bannerUrl.startsWith("/") ? "$baseUrl$bannerUrl" : bannerUrl;
  }
}
