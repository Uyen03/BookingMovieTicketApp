class UserModel {
  final String userId;
  final String username;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;
  final String avatarUrl;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.avatarUrl,
  });

  // Chuyển đổi từ UserModel sang Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  // Chuyển đổi từ Map<String, dynamic> sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
