class Comment {
  final int id;
  final int movieId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  // Chuyển đổi từ JSON sang Comment
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['Id'] ?? 0,
      movieId: json['MovieId'] ?? 0,
      userId: json['UserId'] ?? "",
      username: json['Username'] ?? "Ẩn danh",
      content: json['Content']?.toString().trim() ?? "Không có nội dung",
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? "") ?? DateTime.now(),
    );
  }

  // Chuyển đổi từ Comment sang JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'MovieId': movieId,
      'UserId': userId,
      'Username': username,
      'Content': content,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }
}
