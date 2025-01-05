import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để định dạng ngày giờ và tiền tệ
import 'package:http/http.dart' as http;

class BookingHistoryPage extends StatefulWidget {
  final String userId;

  const BookingHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<dynamic> bookingHistory = [];
  bool isLoading = true;

  // Fetch dữ liệu lịch sử đặt vé
  Future<void> fetchBookingHistory() async {
    final String url = "http://10.0.2.2:5130/api/Booking/${widget.userId}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          bookingHistory = jsonDecode(response.body);

          // Sắp xếp lịch sử theo thời gian giảm dần
          sortBookingHistoryByNewest();

          isLoading = false;
        });
      } else {
        throw Exception(
            "Failed to load booking history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm sắp xếp lịch sử theo thời gian giảm dần
  void sortBookingHistoryByNewest() {
    bookingHistory.sort((a, b) {
      DateTime dateA = DateTime.parse(a["bookingTime"]);
      DateTime dateB = DateTime.parse(b["bookingTime"]);
      return dateB.compareTo(dateA); // Mới nhất trước
    });
  }

  // Định dạng ngày tháng
  String formatDate(String? date) {
    try {
      if (date == null) return "N/A";
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));
    } catch (e) {
      return "N/A";
    }
  }

  // Định dạng tiền tệ
  String formatCurrency(double amount) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return currencyFormat.format(amount);
  }

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đặt vé"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingHistory.isEmpty
              ? const Center(
                  child: Text(
                    "Không có lịch sử đặt vé.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  itemCount: bookingHistory.length,
                  itemBuilder: (context, index) {
                    final booking = bookingHistory[index];

                    final String movieTitle =
                        booking["movieTitle"] ?? "Không có tên phim";
                    final String theatreName =
                        booking["theaterName"] ?? "Không có tên rạp";
                    final String screenName =
                        booking["screenName"] ?? "Không có tên phòng";
                    final String showtime = booking["showtime"] ?? "N/A";
                    final List seats = booking["seats"] ?? [];
                    final double totalPrice =
                        (booking["totalPrice"] as num?)?.toDouble() ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên phim
                            Text(
                              movieTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Rạp chiếu và phòng chiếu
                            Row(
                              children: [
                                const Icon(Icons.theater_comedy,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Rạp: $theatreName",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.meeting_room,
                                    color: Colors.purpleAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Phòng chiếu: $screenName",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Thời gian chiếu
                            Row(
                              children: [
                                const Icon(Icons.schedule,
                                    color: Colors.greenAccent),
                                const SizedBox(width: 8),
                                Text(
                                  "Thời gian: ${formatDate(showtime)}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Ghế ngồi
                            Row(
                              children: [
                                const Icon(Icons.event_seat,
                                    color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  "Ghế: ${seats.join(', ')}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Tổng tiền
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tổng tiền:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatCurrency(totalPrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
