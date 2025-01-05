import 'dart:convert';

import 'package:bookingmovieticket/models/showtime.dart';
import 'package:bookingmovieticket/models/snack_model.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/pages/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class BookingConfirmationPage extends StatelessWidget {
  final Movie movie;
  final String theaterName;
  final String screen;
  final List<String> selectedSeats;
  final List<SnackPackage> snackPackages;
  final double ticketPrice;
  final UserModel user;
  final double totalAmount;
  final Showtime showtime;

  const BookingConfirmationPage({
    Key? key,
    required this.movie,
    required this.theaterName,
    required this.showtime,
    required this.screen,
    required this.selectedSeats,
    required this.snackPackages,
    required this.ticketPrice,
    required this.user,
    required this.totalAmount,
  }) : super(key: key);

  Future<String?> _getFirebaseUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Firebase UserId: ${user.uid}"); // Debug UserId
      return user.uid;
    }
    return null;
  }

  Future<void> _syncUserToBackend() async {
    const String syncUrl = "http://10.0.2.2:5130/api/UserSync/sync";

    try {
      final response = await http.post(Uri.parse(syncUrl));

      if (response.statusCode == 200) {
        print("User synchronized successfully.");
      } else {
        print("Sync failed: ${response.body}");
      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  double _calculateTotal() {
    double snacksTotal =
        snackPackages.fold(0.0, (sum, snack) => sum + snack.price);
    double seatsTotal = selectedSeats.length * ticketPrice;
    return snacksTotal + seatsTotal;
  }

  Future<void> _sendBookingToBackend(BuildContext context) async {
    const String baseUrl = "http://10.0.2.2:5130/api/Booking";

    try {
      final firebaseUserId = await _getFirebaseUserId();
      if (firebaseUserId == null) {
        _showErrorSnackBar(context, "Người dùng chưa đăng nhập!");
        return;
      }

      // Đồng bộ User trước khi tạo booking
      await _syncUserToBackend();

      // Dữ liệu booking gửi lên Backend
      final bookingData = {
        "UserId": firebaseUserId, // UserId từ Firebase
        "ShowtimeId": showtime.id,
        "Seats": selectedSeats
            .map((seat) => {"seatNumber": seat, "type": "Regular"})
            .toList(),
        "Snacks": snackPackages.map((snack) => snack.toJson()).toList(),
        "TotalPrice": _calculateTotal(),
        "Status": "Pending"
      };

      print("Booking Data: ${jsonEncode(bookingData)}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              totalAmount: _calculateTotal(),
              username: user.username,
              email: user.email,
              phone: user.phone,
              selectedSeats: selectedSeats,
              screenId: showtime.screen.id,
            ),
          ),
        );
      } else {
        print("Error Response: ${response.body}");
        _showErrorSnackBar(context, "Không thể tạo booking: ${response.body}");
      }
    } catch (error) {
      print("Connection Error: $error");
      _showErrorSnackBar(context, "Lỗi kết nối: $error");
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String _getFullImageUrl(String bannerUrl) {
    const baseUrl = "http://10.0.2.2:5130";
    return bannerUrl.startsWith("/") ? "$baseUrl$bannerUrl" : bannerUrl;
  }

  Color _getAgeRatingColor(String? ageRating) {
    if (ageRating == "P") {
      return Colors.green;
    }
    return Colors.transparent;
  }

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

  String _formatShowtime(DateTime startTime) {
    return DateFormat('HH:mm, EEEE, dd/MM/yyyy').format(startTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin thanh toán'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderNotification(),
              const SizedBox(height: 16),
              _buildMovieBannerWithDetails(),
              const SizedBox(height: 16),
              _buildMovieDetails(),
              const Divider(thickness: 1, height: 32),
              _buildSnackDetails(),
              const Divider(thickness: 1, height: 32),
              _buildUserInfo(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeaderNotification() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Bạn ơi, vé đã mua sẽ không thể hoàn, huỷ, đổi vé. Bạn nhớ kiểm tra kỹ thông tin nha!",
              style: TextStyle(color: Colors.pinkAccent[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieBannerWithDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(_getFullImageUrl(movie.bannerUrl ?? "")),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$theaterName",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAgeRatingColor(movie.ageRating),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movie.ageRating ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getAgeRatingDescription(movie.ageRating),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
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
    );
  }

  Widget _buildMovieDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thời gian:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 4),
                    Text(
                      _formatShowtime(showtime.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Phòng chiếu:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 4),
                    Text(
                      showtime.screen.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Số ghế:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 4),
                    Text(
                      selectedSeats.join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnackDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Combo bắp nước",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            snackPackages.isEmpty
                ? const Text(
                    "Không có combo nào được chọn",
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    children: snackPackages.map((snack) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: snack.imageUrl != null
                                  ? Image.network(
                                      _getFullImageUrl(snack.imageUrl!),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.fastfood,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snack.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    snack.description ?? "Không có mô tả",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(snack.price),
                              style: const TextStyle(
                                fontSize: 14,
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

  Widget _buildUserInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin người nhận",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 8),
            Text(
              "Họ tên: ${user.username}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Số điện thoại: ${user.phone}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Email: ${user.email}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tạm tính: ${_formatCurrency(_calculateTotal())}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          ElevatedButton(
            onPressed: () => _sendBookingToBackend(
                context), // Gọi API để gửi dữ liệu booking
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              "Tiếp tục",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
