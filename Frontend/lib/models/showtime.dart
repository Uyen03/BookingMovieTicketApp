import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/models/screen_model.dart';
import 'package:bookingmovieticket/models/theatre_model.dart';

class Showtime {
  final int id;
  final Movie movie;
  final Theatre theatre;
  final Screen screen;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double ticketPrice;
  final String? format; // Định dạng có thể null
  final List<String>? languagesAvailable; // Có thể null
  final double? priceModifier; // Giá bổ sung có thể null

  Showtime({
    required this.id,
    required this.movie,
    required this.theatre,
    required this.screen,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.ticketPrice,
    this.format,
    this.languagesAvailable,
    this.priceModifier,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing Showtime JSON: $json"); // Debugging
      return Showtime(
        id: (json['Id'] as int?) ?? 0,
        movie: Movie.fromJson(json['Movie'] ?? {}),
        theatre: Theatre.fromJson(json['Theatre'] ?? {}),
        screen: Screen.fromJson(json['Screen'] ?? {}),
        startTime: DateTime.tryParse(json['StartTime'] ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['EndTime'] ?? '') ?? DateTime.now(),
        status: json['Status'] ?? 'Inactive',
        ticketPrice: (json['TicketPrice'] as num?)?.toDouble() ?? 0.0,
        format: json['Format'],
        languagesAvailable: json['LanguagesAvailable'] != null
            ? List<String>.from(json['LanguagesAvailable'])
            : null,
        priceModifier: (json['PriceModifier'] as num?)?.toDouble(),
      );
    } catch (e) {
      print("Error parsing Showtime: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Movie': movie.toJson(),
      'Theatre': theatre.toJson(),
      'Screen': screen.toJson(),
      'StartTime': startTime.toIso8601String(),
      'EndTime': endTime.toIso8601String(),
      'Status': status,
      'TicketPrice': ticketPrice,
      'Format': format,
      'LanguagesAvailable': languagesAvailable,
      'PriceModifier': priceModifier,
    };
  }
}
