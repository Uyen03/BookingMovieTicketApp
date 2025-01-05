import 'dart:convert';

import 'seatdetail_model.dart';

class SeatArrangement {
  final int screenId;
  final List<List<SeatDetail>> arrangement;

  SeatArrangement({
    required this.screenId,
    required this.arrangement,
  });

  factory SeatArrangement.fromJson(Map<String, dynamic> json) {
    return SeatArrangement(
      screenId: json['ScreenId'],
      arrangement: (jsonDecode(json['Arrangement']) as List)
          .map((row) =>
              (row as List).map((seat) => SeatDetail.fromJson(seat)).toList())
          .toList(),
    );
  }
}
