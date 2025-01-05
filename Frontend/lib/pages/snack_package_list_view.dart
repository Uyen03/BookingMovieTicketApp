import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/models/showtime.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/pages/booking_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để định dạng tiền tệ
import 'package:bookingmovieticket/models/snack_model.dart';

class SnackPackageListView extends StatefulWidget {
  final List<SnackPackage> snackPackages;
  final Movie movie; // Thay thế movieName và format
  final String theaterName;
  final Showtime showtime;
  final String screen;
  final List<String> selectedSeats;
  final UserModel user;
  final double ticketPrice;

  const SnackPackageListView({
    Key? key,
    required this.snackPackages,
    required this.movie, // Nhận đối tượng Movie
    required this.theaterName,
    required this.showtime,
    required this.screen,
    required this.selectedSeats,
    required this.user,
    required this.ticketPrice,
  }) : super(key: key);

  @override
  State<SnackPackageListView> createState() => _SnackPackageListViewState();
}

class _SnackPackageListViewState extends State<SnackPackageListView> {
  final Map<String, int> quantities = {}; // Lưu số lượng của từng sản phẩm

  @override
  void initState() {
    super.initState();

    // Lọc ra các sản phẩm có price > 0
    widget.snackPackages.removeWhere((package) => package.price <= 0);

    // Khởi tạo số lượng = 0 cho các sản phẩm hợp lệ
    for (var package in widget.snackPackages) {
      quantities[package.snackPackageId] = 0;
    }

    print("Filtered Snack Packages: ${widget.snackPackages}");
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(value)}đ";
  }

  void _showSnackPackageDetails(SnackPackage snackPackage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int tempQuantity = quantities[snackPackage.snackPackageId] ?? 0;

        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Chi tiết sản phẩm",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      snackPackage.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'http://10.0.2.2:5130${snackPackage.imageUrl!}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.fastfood, size: 100),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snackPackage.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snackPackage.description ?? "Không có mô tả",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(snackPackage.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setStatePopup(() {
                                if (tempQuantity > 0) {
                                  tempQuantity--;
                                }
                              });
                            },
                          ),
                          Text(
                            "$tempQuantity",
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setStatePopup(() {
                                tempQuantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      Text(
                        "Tạm tính: ${_formatCurrency(tempQuantity * snackPackage.price)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        quantities[snackPackage.snackPackageId] = tempQuantity;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Xác nhận",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = widget.snackPackages.fold(
      0.0,
      (sum, snackPackage) =>
          sum + (quantities[snackPackage.snackPackageId]! * snackPackage.price),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Combo – Bắp nước"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Danh sách bắp nước",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.snackPackages.length,
              itemBuilder: (context, index) {
                final snackPackage = widget.snackPackages[index];
                return GestureDetector(
                  onTap: () => _showSnackPackageDetails(snackPackage),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          snackPackage.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'http://10.0.2.2:5130${snackPackage.imageUrl!}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.fastfood, size: 80),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snackPackage.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(snackPackage.price),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pinkAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (quantities[
                                            snackPackage.snackPackageId]! >
                                        0) {
                                      quantities[snackPackage.snackPackageId] =
                                          quantities[snackPackage
                                                  .snackPackageId]! -
                                              1;
                                    }
                                  });
                                },
                              ),
                              Text(
                                "${quantities[snackPackage.snackPackageId]}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    quantities[snackPackage.snackPackageId] =
                                        quantities[
                                                snackPackage.snackPackageId]! +
                                            1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng cộng:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Lọc danh sách snack được chọn
                final selectedSnacks = widget.snackPackages
                    .where((snackPackage) =>
                        quantities[snackPackage.snackPackageId]! > 0)
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingConfirmationPage(
                      movie: widget.movie, // Truyền đối tượng Movie
                      theaterName: widget.theaterName,
                      showtime: widget.showtime,
                      screen: widget.screen,
                      snackPackages: selectedSnacks,
                      totalAmount: totalAmount,
                      selectedSeats: widget.selectedSeats,
                      user: widget.user,
                      ticketPrice: widget.ticketPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Tiếp tục",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
