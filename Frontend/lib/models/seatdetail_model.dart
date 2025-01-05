class SeatDetail {
  final String seatNumber; // Mã số ghế (ví dụ: "A1")
  final String type; // Loại ghế: Regular, VIP, Couple
  final String status; // Trạng thái ghế: available, booked
  final String? linkedSeatNumber; // Ghế liên kết (dành cho ghế đôi)
  final double additionalPrice; // Giá tăng thêm cho loại ghế

  SeatDetail({
    required this.seatNumber,
    required this.type,
    required this.status,
    this.linkedSeatNumber,
    required this.additionalPrice,
  });

  /// Parse từ JSON
  factory SeatDetail.fromJson(Map<String, dynamic> json) {
    return SeatDetail(
      seatNumber: json['seatNumber'] ?? '',
      type: json['type'] ?? 'Regular',
      status: json['status'] ?? 'available',
      linkedSeatNumber: json['linkedSeatNumber'],
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'seatNumber': seatNumber,
      'type': type,
      'status': status,
      'linkedSeatNumber': linkedSeatNumber,
      'additionalPrice': additionalPrice,
    };
  }

  /// Kiểm tra trạng thái ghế
  bool isBooked() {
    return status.toLowerCase() == 'booked';
  }
}
