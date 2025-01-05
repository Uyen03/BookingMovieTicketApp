import 'package:bookingmovieticket/models/actor_model.dart';

class Movie {
  final int id;
  final String title;
  final String? description;
  final String? bannerUrl;
  final DateTime releaseDate;
  final int durationInMinutes;
  final List<String> genres;
  final int likes; // Renamed for clarity
  final String status;
  final String? trailerUrl;
  final List<Actor> actors;
  final String? ageRating;
  final List<String> formats;
  final List<String> languagesAvailable;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.bannerUrl,
    required this.releaseDate,
    required this.durationInMinutes,
    required this.genres,
    required this.likes, // Updated naming for consistency
    required this.status,
    this.trailerUrl,
    required this.actors,
    this.ageRating,
    required this.formats,
    required this.languagesAvailable,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['Id'] as int?) ?? 0, // Xử lý null
      title: json['Title'] ?? 'Unknown', // Giá trị mặc định
      description: json['Description'],
      bannerUrl: _resolveUrl(json['BannerUrl']),
      releaseDate:
          DateTime.tryParse(json['ReleaseDate'] ?? '') ?? DateTime.now(),
      durationInMinutes: (json['DurationInMinutes'] as int?) ?? 0, // Xử lý null
      genres: List<String>.from(json['Genres'] ?? []),
      likes: (json['Like'] as int?) ?? 0, // Xử lý null
      status: json['Status'] ?? 'Inactive',
      trailerUrl: _resolveUrl(json['TrailerUrl']),
      actors: (json['Actors'] as List?)
              ?.map((actorJson) => Actor.fromJson(actorJson))
              .toList() ??
          [],
      ageRating: json['AgeRating'],
      formats: List<String>.from(json['Formats'] ?? []),
      languagesAvailable: List<String>.from(json['LanguagesAvailable'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Description': description,
      'BannerUrl': bannerUrl,
      'ReleaseDate': releaseDate.toIso8601String(),
      'DurationInMinutes': durationInMinutes,
      'Genres': genres,
      'Like': likes,
      'Status': status,
      'TrailerUrl': trailerUrl,
      'Actors': actors.map((actor) => actor.toJson()).toList(),
      'AgeRating': ageRating,
      'Formats': formats,
      'LanguagesAvailable': languagesAvailable,
    };
  }

  // Helper function to resolve URL and replace localhost with the emulator IP
  static String? _resolveUrl(String? url) {
    if (url == null) return null;
    return Uri.encodeFull(url.replaceFirst('localhost', '10.0.2.2'));
  }
}
