import 'package:bookingmovieticket/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theatre_controller.dart';
import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import 'select_showtime_screen.dart'; // Import màn hình SelectShowtimeScreen

class ListCinemaScreen extends StatelessWidget {
  final Movie model;
  final UserModel user; // Thêm đối tượng user

  const ListCinemaScreen({Key? key, required this.model, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TheatreController theatreController = Get.put(TheatreController());
    theatreController.fetchTheatres();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text("Chọn rạp cho phim: ${model.title}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm rạp...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                theatreController.searchTheatre(value);
              },
            ),
          ),
          // Danh sách rạp
          Expanded(
            child: Obx(() {
              if (theatreController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (theatreController.filteredTheatres.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có rạp chiếu phim phù hợp.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: theatreController.filteredTheatres.length,
                itemBuilder: (context, index) {
                  final theatre = theatreController.filteredTheatres[index];
                  return GestureDetector(
                    onTap: () {
                      // Điều hướng đến SelectShowtimeScreen khi chọn rạp
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowtimeSelectorScreen(
                            theatreName: theatre.name,
                            theatreId: theatre.id,
                            user: user, // Truyền ID rạp
                          ),
                        ),
                      );
                    },
                    child: _buildCinemaItem(theatre),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin từng rạp
  Widget _buildCinemaItem(Theatre theatre) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị hình ảnh từ URL hoặc placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              theatre.imageUrl ?? "https://via.placeholder.com/100",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image: ${theatre.imageUrl}");
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theatre.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theatre.fullAddress,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Màn hình: ${theatre.availableScreens.join(", ")}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.snackbar("Tìm đường", "Tính năng này đang được phát triển.");
            },
            child: const Text(
              "Tìm đường",
              style: TextStyle(color: Colors.pinkAccent),
            ),
          ),
        ],
      ),
    );
  }
}
