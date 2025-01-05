import 'package:bookingmovieticket/controllers/snack_package_controller.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/pages/snack_package_list_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../controllers/seat_controller.dart';
import '../models/seatdetail_model.dart';
import '../models/showtime.dart';

class SeatSelectionPage extends StatefulWidget {
  final int screenId;
  final String screenName;
  final String theatreName;
  final Showtime showtime;
  final List<String> selectedSeats;
  final String format;
  final UserModel user;

  const SeatSelectionPage({
    Key? key,
    required this.screenId,
    required this.screenName,
    required this.theatreName,
    required this.showtime,
    required this.selectedSeats,
    required this.format,
    required this.user,
  }) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final SeatController seatController = SeatController();
  late Future<List<List<SeatDetail>>> seats;
  final List<String> selectedSeats = [];
  final Set<String> processedSeats = {};

  @override
  void initState() {
    super.initState();
    print('Initializing SeatSelectionPage for screenId: ${widget.screenId}');
    selectedSeats.clear();
    fetchAndSetSeats();
  }

  void fetchSeats() {
    setState(() {
      selectedSeats.clear(); // Reset danh sách ghế đã chọn
      seats = seatController.fetchSeats(widget.screenId);
    });
  }

  void fetchAndSetSeats() {
    print('Fetching seats for screenId: ${widget.screenId}');
    setState(() {
      seats = seatController.fetchSeats(widget.screenId);
    });
  }

  Future<void> refreshSeats() async {
    setState(() {
      seats = seatController
          .fetchSeats(widget.screenId); // Gọi lại API lấy danh sách ghế
    });
  }

  // Future<void> updateSeatStatus({
  //   required int screenId,
  //   required List<String> selectedSeats,
  //   required String status,
  //   required String action,
  // }) async {
  //   const String apiUrl = "http://10.0.2.2:5130/api/Seat/UpdateSeatStatus";
  //   try {
  //     final response = await http.put(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "screenId": screenId,
  //         "selectedSeats": selectedSeats,
  //         "status": status,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print("Cập nhật trạng thái ghế thành công [$action]: $status");

  //       // Làm mới giao diện sau khi cập nhật trạng thái ghế
  //       await refreshSeats();
  //     } else {
  //       print("Lỗi khi cập nhật trạng thái ghế [$action]: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Lỗi kết nối [$action]: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(widget.theatreName),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildScreenSymbol(),
          Expanded(
            child: FutureBuilder<List<List<SeatDetail>>>(
              future: seats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error loading seats: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildZoomableSeatLayout(snapshot.data!),
                        const SizedBox(height: 10),
                        _buildLegend(),
                        const SizedBox(height: 10),
                        _buildMovieInfoAndSummary(snapshot.data!),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('No seats available'));
                }
              },
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildScreenSymbol() {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 40),
          painter: ScreenPainter(),
        ),
        const SizedBox(height: 8),
        const Text(
          "MÀN HÌNH",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildZoomableSeatLayout(List<List<SeatDetail>> seatRows) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.8,
      maxScale: 2.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: _buildSeatGrid(seatRows),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid(List<List<SeatDetail>> seatRows) {
    processedSeats.clear();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: seatRows.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((seat) {
            if (processedSeats.contains(seat.seatNumber)) {
              return const SizedBox.shrink();
            }

            if (seat.type == "Couple" && seat.linkedSeatNumber != null) {
              processedSeats.add(seat.linkedSeatNumber!);
              return _buildCoupleSeat(seat);
            } else {
              processedSeats.add(seat.seatNumber);
              return _buildSingleSeat(seat);
            }
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSeat(SeatDetail seat) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (seat.status == "available") {
            if (selectedSeats.contains(seat.seatNumber)) {
              selectedSeats.remove(seat.seatNumber);
            } else {
              selectedSeats.add(seat.seatNumber);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Ghế này đã được đặt hoặc không khả dụng."),
              ),
            );
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getSeatColor(seat),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Text(
          seat.seatNumber,
          style: TextStyle(
            fontSize: 12,
            color: selectedSeats.contains(seat.seatNumber)
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCoupleSeat(SeatDetail seat) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (seat.status == "available") {
            if (selectedSeats.contains(seat.seatNumber) ||
                selectedSeats.contains(seat.linkedSeatNumber!)) {
              selectedSeats.remove(seat.seatNumber);
              selectedSeats.remove(seat.linkedSeatNumber!);
            } else {
              selectedSeats.add(seat.seatNumber);
              selectedSeats.add(seat.linkedSeatNumber!);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Ghế đôi này đã được đặt hoặc không khả dụng."),
              ),
            );
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 100,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedSeats.contains(seat.seatNumber) ||
                  selectedSeats.contains(seat.linkedSeatNumber!)
              ? Colors.greenAccent
              : Colors.pinkAccent.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seat.seatNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              seat.linkedSeatNumber!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(Colors.grey, "Đã đặt"),
          _buildLegendItem(Colors.greenAccent, "Ghế bạn chọn"),
          _buildLegendItem(Colors.purpleAccent.shade100, "Ghế thường"),
          _buildLegendItem(Colors.redAccent.shade100, "Ghế VIP"),
          _buildLegendItem(Colors.pinkAccent.shade100, "Ghế đôi"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildMovieInfoAndSummary(List<List<SeatDetail>> loadedSeats) {
    final movie = widget.showtime.movie;
    final ageRatingColor =
        _getAgeRatingColor(movie.ageRating ?? "Không xác định");

    final double totalPrice = calculateTotalPrice(
      widget.showtime.ticketPrice,
      selectedSeats,
      loadedSeats,
    );

    final formats = movie.formats.isNotEmpty ? movie.formats.join(", ") : "";
    final languages = movie.languagesAvailable.isNotEmpty
        ? movie.languagesAvailable.join(", ")
        : "";

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ageRatingColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  movie.ageRating ?? "Không xác định",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                movie.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${_formatTime(widget.showtime.startTime)} ~ ${_formatTime(widget.showtime.endTime)} | ${_getWeekday(widget.showtime.startTime.weekday)}, ${_formatDate(widget.showtime.startTime)} | $formats $languages",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tạm tính:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${_formatCurrency(totalPrice)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: selectedSeats.isNotEmpty
            ? () async {
                try {
                  final snackPackages =
                      await SnackPackageController().fetchSnackPackages();

                  // Điều hướng tới SnackPackageListView sau PaymentPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SnackPackageListView(
                        snackPackages: snackPackages,
                        movie: widget.showtime.movie!,
                        theaterName: widget.theatreName,
                        showtime: widget.showtime,
                        screen: widget.screenName,
                        selectedSeats: selectedSeats,
                        user: widget.user,
                        ticketPrice: widget.showtime.ticketPrice,
                      ),
                    ),
                  ).then((result) {
                    // Làm mới sơ đồ ghế nếu thanh toán và xử lý xong SnackPackageListView
                    if (result == true) {
                      refreshSeats(); // Gọi lại API để cập nhật trạng thái ghế
                    }
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Có lỗi xảy ra khi tải dữ liệu: $e'),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          "Tiếp tục",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  double calculateTotalPrice(
    double ticketPrice,
    List<String> selectedSeats,
    List<List<SeatDetail>> seats,
  ) {
    double total = 0.0;

    for (var seatNumber in selectedSeats) {
      for (var row in seats) {
        for (var seat in row) {
          if (seat.seatNumber == seatNumber) {
            total += ticketPrice + seat.additionalPrice;
            break;
          }
        }
      }
    }

    return total;
  }

  Color _getSeatColor(SeatDetail seat) {
    if (seat.status == "booked") {
      return Colors.grey; // Màu xám cho ghế đã đặt
    } else if (selectedSeats.contains(seat.seatNumber)) {
      return Colors.greenAccent; // Ghế đang chọn
    } else {
      switch (seat.type) {
        case "Regular":
          return Colors.purpleAccent.shade100; // Ghế thường
        case "VIP":
          return Colors.redAccent.shade100; // Ghế VIP
        case "Couple":
          return Colors.pinkAccent.shade100; // Ghế đôi
        default:
          return Colors.lightBlue[100]!; // Mặc định
      }
    }
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

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
        return "Không xác định";
    }
  }

  String _formatCurrency(double value) {
    return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => "${match[1]}.")}đ";
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
