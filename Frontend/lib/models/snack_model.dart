class SnackPackage {
  final String snackPackageId; // ID của gói snack
  final String name; // Tên gói snack
  final double price; // Giá của gói snack
  final String? description; // Mô tả, có thể null
  int selectedAmount; // Số lượng người dùng đã chọn, có thể thay đổi
  final String? imageUrl; // URL hình ảnh, có thể null
  final DateTime createdAt; // Thời gian tạo
  final DateTime? updatedAt; // Thời gian cập nhật, có thể null

  SnackPackage({
    required this.snackPackageId,
    required this.name,
    required this.price,
    this.description,
    this.selectedAmount = 0, // Mặc định là 0
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Chuyển đổi từ JSON sang đối tượng SnackPackage
  factory SnackPackage.fromJson(Map<String, dynamic> json) {
    return SnackPackage(
      snackPackageId: json['SnackPackageId'] as String,
      name: json['Name'] as String,
      price: (json['Price'] as num).toDouble(),
      description: json['Description'] as String?, // Kiểm tra null
      selectedAmount: json['SelectedAmount'] as int? ?? 0, // Mặc định là 0
      imageUrl: json['ImageUrl'] as String?, // Kiểm tra null
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'] as String)
          : null, // Xử lý khi UpdatedAt là null
    );
  }

  // Chuyển đổi từ đối tượng SnackPackage sang JSON
  Map<String, dynamic> toJson() {
    return {
      'SnackPackageId': snackPackageId,
      'Name': name,
      'Price': price,
      'Description': description,
      'SelectedAmount': selectedAmount,
      'ImageUrl': imageUrl,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
