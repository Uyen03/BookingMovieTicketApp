import 'dart:convert';

import 'package:bookingmovieticket/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:bookingmovieticket/services/booking_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final String username;
  final String email;
  final String phone;
  final int screenId; // Nhận screenId
  final List<String> selectedSeats;

  const PaymentPage({
    Key? key,
    required this.totalAmount,
    required this.username,
    required this.email,
    required this.phone,
    required this.screenId,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  void _handlePayment() async {
    setState(() => _isLoading = true);

    print("Starting Payment Process...");
    final bookingService = BookingService();
    final bookingId = "ORDER_${Uuid().v4()}"; // Tạo ID đơn hàng giả

    // Cập nhật trạng thái ghế trước khi chuyển qua ZaloPay
    try {
      print("Updating seat status...");
      await _saveBookingHistoryAndUpdateSeats(
        bookingId,
        widget.screenId,
        widget.selectedSeats,
        "booked",
      );
    } catch (e) {
      print("Error: $e");
      _showErrorDialog("Lỗi khi cập nhật trạng thái ghế. Vui lòng thử lại.");
      setState(() => _isLoading = false);
      return; // Nếu lỗi thì không tiếp tục thanh toán
    }

    // Tạo URL thanh toán ZaloPay
    final payUrl = await bookingService.createPayment(
      bookingId: bookingId,
      amount: widget.totalAmount,
    );

    if (payUrl != null && payUrl.isNotEmpty) {
      print("ZaloPay Order URL: $payUrl");

      if (await canLaunchUrl(Uri.parse(payUrl))) {
        await launchUrl(
          Uri.parse(payUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        print("Invalid URL: $payUrl");
        _showErrorDialog("URL không hợp lệ. Vui lòng thử lại.");
      }
    } else {
      _showErrorDialog("Không thể tạo URL thanh toán. Vui lòng thử lại.");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveBookingHistoryAndUpdateSeats(String bookingId, int screenId,
      List<String> selectedSeats, String status) async {
    const String seatApiUrl = "http://10.0.2.2:5130/api/Seat/UpdateSeatStatus";

    try {
      // Gửi yêu cầu cập nhật trạng thái ghế
      final seatResponse = await http.put(
        Uri.parse(seatApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "screenId": screenId,
          "selectedSeats": selectedSeats,
          "status": status,
        }),
      );

      if (seatResponse.statusCode == 200) {
        print("Ghế đã chuyển trạng thái thành 'booked'.");
      } else {
        print("Error updating seat status: ${seatResponse.body}");
        throw Exception("Lỗi khi cập nhật trạng thái ghế.");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Lỗi kết nối khi xử lý cập nhật trạng thái ghế.");
    }
  }

  Future<void> _updateSeatStatusAfterPayment(
      int screenId, List<String> selectedSeats, String status) async {
    const String apiUrl = "http://10.0.2.2:5130/api/Seat/UpdateSeatStatus";
    try {
      // Log dữ liệu trước khi gửi
      print("Payload gửi API:");
      print(jsonEncode({
        "screenId": screenId,
        "selectedSeats": selectedSeats,
        "status": status,
      }));

      // Gửi yêu cầu PUT
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "screenId": screenId,
          "selectedSeats": selectedSeats,
          "status": status,
        }),
      );

      // Log phản hồi từ API
      print("Phản hồi từ API: ${response.statusCode}");
      print("Nội dung phản hồi: ${response.body}");

      if (response.statusCode == 200) {
        print("Ghế đã chuyển trạng thái thành 'booked'.");
        Navigator.pop(context, true);
      } else {
        print("Lỗi từ API: ${response.body}");
        _showErrorDialog(
            "Lỗi khi cập nhật trạng thái ghế. Chi tiết: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      _showErrorDialog("Lỗi kết nối khi cập nhật trạng thái ghế.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán ZaloPay"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalAmount(),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        "Thanh toán qua ZaloPay",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalAmount() {
    // Sử dụng NumberFormat để định dạng tiền tệ
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN', // Sử dụng định dạng tiền Việt Nam
      symbol: 'đ', // Ký hiệu đơn vị tiền tệ
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tổng tiền:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              currencyFormatter.format(widget.totalAmount),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
