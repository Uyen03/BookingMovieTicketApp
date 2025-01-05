import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/models/showtime.dart';
import 'package:bookingmovieticket/models/snack_model.dart';
import 'package:bookingmovieticket/models/theatre_model.dart';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/models/screen_model.dart';

class Booking {
  final int id; // Mã đặt vé
  final UserModel user; // Thông tin người dùng
  final Theatre theatre; // Thông tin rạp
  final Showtime showtime; // Thông tin suất chiếu
  final Screen screen; // Thông tin phòng chiếu
  final Movie movie; // Thông tin phim
  final List<String> seats; // Danh sách ghế ngồi
  final List<SnackPackage> snacks; // Danh sách combo
  final double ticketPrice; // Giá vé từng ghế
  final double totalPrice; // Tổng giá trị
  final String status; // Trạng thái (Pending, Confirmed, Cancelled)
  final DateTime createdAt; // Ngày tạo
  final DateTime? updatedAt; // Ngày cập nhật (nếu có)

  Booking({
    required this.id,
    required this.user,
    required this.theatre,
    required this.showtime,
    required this.screen,
    required this.movie,
    required this.seats,
    required this.snacks,
    required this.ticketPrice,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tạo từ JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      user: UserModel.fromMap(json['user']),
      theatre: Theatre.fromJson(json['theatre']),
      showtime: Showtime.fromJson(json['showtime']),
      screen: Screen.fromJson(json['screen']),
      movie: Movie.fromJson(json['movie']),
      seats: List<String>.from(json['seats']),
      snacks: (json['snacks'] as List)
          .map((snackJson) => SnackPackage.fromJson(snackJson))
          .toList(),
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toMap(),
      'theatre': theatre.toJson(),
      'showtime': showtime.toJson(),
      'screen': screen.toJson(),
      'movie': movie.toJson(),
      'seats': seats,
      'snacks': snacks.map((snack) => snack.toJson()).toList(),
      'ticketPrice': ticketPrice,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
