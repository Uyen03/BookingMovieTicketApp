class Actor {
  final int id;
  final String name;
  final String profilePictureUrl;
  final String role;

  Actor({
    required this.id,
    required this.name,
    required this.profilePictureUrl,
    required this.role,
  });

  // Tạo từ JSON
  factory Actor.fromJson(Map<String, dynamic> json) {
    String profileUrl = json['ProfilePictureUrl'];

    // Thay localhost bằng 10.0.2.2 nếu chạy trên Android Emulator
    profileUrl = profileUrl.replaceFirst('localhost', '10.0.2.2');

    return Actor(
      id: json['Id'],
      name: json['Name'],
      profilePictureUrl: Uri.encodeFull(profileUrl),
      role: json['Role'],
    );
  }

  // Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'ProfilePictureUrl': profilePictureUrl,
      'Role': role,
    };
  }
}
