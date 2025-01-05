import 'dart:convert';

import 'package:bookingmovieticket/models/comment_model.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/pages/list_cinema_screen.dart';
import 'package:bookingmovieticket/pages/trailer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatelessWidget {
  final Movie model = Get.arguments as Movie;
  final UserModel user; // Thêm thông tin người dùng

  DetailsScreen({Key? key, required this.user}) : super(key: key);

  String sanitizeUrl(String rawUrl) {
    // Kiểm tra xem URL có chứa tiền tố sai hay không
    if (rawUrl.startsWith("http://10.0.2.2")) {
      rawUrl = rawUrl.replaceFirst("http://10.0.2.2:5130", "");
    }

    // Loại bỏ các khoảng trắng thừa hoặc ký tự không mong muốn
    return rawUrl.trim();
  }

  Future<void> addComment(Map<String, dynamic> comment) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5130/api/Comments'), // Thay bằng URL của bạn
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add comment");
    }
  }

  Future<List<Comment>> fetchComments(int movieId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5130/api/Comments/$movieId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load comments");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Thông tin phim",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMovieHeader(context),
            buildDetailsSection(),
            const SizedBox(height: 16),
            buildMovieDescription(),
            const SizedBox(height: 16),
            buildActorsSection(),
            const SizedBox(height: 16),
            buildCommentSection(context),
            const SizedBox(height: 16),
            buildCommentInput(context),
            buildBuyTicketButton(),
          ],
        ),
      ),
    );
  }

  // Header chứa tên phim, poster và nút trailer
  Widget buildMovieHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              model.bannerUrl ?? 'https://via.placeholder.com/150',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 100),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  model.genres.join(", "),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: getAgeRatingColor(model.ageRating),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        model.ageRating ?? "N/A",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getAgeRatingDescription(model.ageRating),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (model.trailerUrl != null &&
                            model.trailerUrl!.isNotEmpty) {
                          final sanitizedUrl =
                              sanitizeUrl(model.trailerUrl!); // Làm sạch URL

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrailerScreen(trailerUrl: sanitizedUrl),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Trailer không khả dụng")),
                          );
                        }
                      },
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text("Xem Trailer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailsSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Ngày khởi chiếu
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Ngày khởi chiếu",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  "${model.releaseDate.day}/${model.releaseDate.month}/${model.releaseDate.year}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Line đứng 1
          SizedBox(
            height: 40, // Chiều cao của line đứng
            child: const VerticalDivider(
              thickness: 1,
              width: 10, // Không gian giữa line và các mục
              color: Colors.grey, // Màu của line đứng
            ),
          ),
          // Thời lượng
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Thời lượng",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  "${model.durationInMinutes} phút",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Line đứng 2
          SizedBox(
            height: 40, // Chiều cao của line đứng
            child: const VerticalDivider(
              thickness: 1,
              width: 10, // Không gian giữa line và các mục
              color: Colors.grey, // Màu của line đứng
            ),
          ),
          // Ngôn ngữ
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Ngôn ngữ",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  model.languagesAvailable.isNotEmpty
                      ? model.languagesAvailable.join(", ")
                      : "Không có",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRatingSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "6.3",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 36),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "461 đánh giá",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildMovieDescription() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nội dung phim",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            model.description ?? "Không có mô tả.",
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget buildActorsSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Đạo diễn & Diễn viên",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: model.actors.map((actor) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          actor.profilePictureUrl ??
                              'https://via.placeholder.com/100',
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 100);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          actor.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentSection(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: fetchComments(model.id), // Lấy bình luận từ API
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Không thể tải bình luận"));
        } else {
          final comments = snapshot.data ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text("Chưa có bình luận nào"));
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bình luận",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...comments.map((comment) {
                  bool isExpanded = false; // Trạng thái mở rộng
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            comment.username.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(comment.username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpanded
                                  ? comment.content // Hiển thị toàn bộ nội dung
                                  : comment.content.length > 250
                                      ? comment.content.substring(0, 250) +
                                          "..." // Rút gọn nội dung
                                      : comment.content,
                            ),
                            if (comment.content.length > 250)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Text(
                                  isExpanded ? "Thu gọn" : "Xem thêm",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          DateFormat("dd/MM/yyyy").format(comment.createdAt),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          );
        }
      },
    );
  }

  // Form nhập bình luận
  Widget buildCommentInput(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: "Viết bình luận...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.pink),
            onPressed: () async {
              final newComment = {
                'movieId': model.id,
                'userId': user.userId,
                'username': user.username,
                'content': commentController.text,
                'createdAt': DateTime.now().toIso8601String(),
              };
              await addComment(newComment);
              commentController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bình luận đã được gửi!")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildBuyTicketButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Chuyển sang trang ListCinemaScreen
            Get.to(() => ListCinemaScreen(
                model: model,
                user: user)); // Truyền thông tin người dùng vào đây
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Mua vé",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // // Hiển thị thông tin người dùng (tuỳ chọn)
  // Widget buildUserInfoSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Thông tin người dùng",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         Text("Tên người dùng: ${user.username}"),
  //         Text("Email: ${user.email}"),
  //       ],
  //     ),
  //   );
  // }

  // Hàm lấy màu sắc phân loại độ tuổi
  Color getAgeRatingColor(String? ageRating) {
    switch (ageRating) {
      case "P":
        return Colors.green;
      case "C13":
        return Colors.yellow;
      case "C18":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Hàm lấy mô tả phân loại độ tuổi
  String getAgeRatingDescription(String? ageRating) {
    switch (ageRating) {
      case "P":
        return "Phim được phép phổ biến đến người xem ở mọi độ tuổi.";
      case "C13":
        return "Phim được phổ biến đến người xem từ đủ 13 tuổi trở lên.";
      case "C18":
        return "Phim được phổ biến đến người xem từ đủ 18 tuổi trở lên.";
      default:
        return "Không có thông tin phân loại độ tuổi.";
    }
  }
}
