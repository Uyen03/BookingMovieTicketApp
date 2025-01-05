class Seat {
  final int id;
  final int screenId;
  final String arrangement; // Chuỗi JSON lưu sơ đồ ghế

  Seat({
    required this.id,
    required this.screenId,
    required this.arrangement,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['Id'],
      screenId: json['ScreenId'],
      arrangement: json['Arrangement'], // Chuỗi JSON từ API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ScreenId': screenId,
      'Arrangement': arrangement,
    };
  }
}
