import 'package:bookingmovieticket/models/showtime.dart';
import 'package:bookingmovieticket/models/theatre_model.dart';

class Screen {
  final int id;
  final String name;
  final int theatreId;
  final Theatre theatre; // Bao gồm thông tin rạp
  final int seatCapacity;
  final List<Showtime>? showtimes;

  Screen({
    required this.id,
    required this.name,
    required this.theatreId,
    required this.theatre,
    this.seatCapacity = 0, // Giá trị mặc định cho ghế
    this.showtimes,
  });

  factory Screen.fromJson(Map<String, dynamic> json) {
    return Screen(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? 'Không xác định',
      theatreId: json['TheatreId'] ?? 0,
      theatre: json['Theatre'] != null
          ? Theatre.fromJson(json['Theatre'])
          : Theatre(id: 0, name: "Không xác định", fullAddress: ""),
      seatCapacity: json['seatCapacity'] ?? 0,
      showtimes: json['Showtimes'] != null
          ? (json['Showtimes'] as List)
              .map((e) => Showtime.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'TheatreId': theatreId,
      'Theatre': theatre.toJson(),
      'seatCapacity': seatCapacity,
      'Showtimes': showtimes?.map((e) => e.toJson()).toList(),
    };
  }
}
