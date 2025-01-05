class Theatre {
  final int id;
  final String name;
  final String fullAddress;
  final String? coordinates;
  final List<String> facilities;
  final List<String> availableScreens;
  final String? contactNumber;
  final String? city;
  final String? imageUrl;

  Theatre({
    required this.id,
    required this.name,
    required this.fullAddress,
    this.coordinates,
    this.facilities = const [], // Cung cấp giá trị mặc định là mảng rỗng
    this.availableScreens = const [], // Cung cấp giá trị mặc định là mảng rỗng
    this.contactNumber,
    this.city,
    this.imageUrl,
  });

  factory Theatre.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "http://10.0.2.2:5130";

    return Theatre(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? 'Unknown',
      fullAddress: json['FullAddress'] ?? '',
      coordinates: json['Coordinates'],
      facilities: (json['FacilityList'] as List?)
              ?.map((e) => e.toString().trim())
              .toList() ??
          [],
      availableScreens: (json['AvailableScreensList'] as List?)
              ?.map((e) => e.toString().trim())
              .toList() ??
          [],
      contactNumber: json['ContactNumber'],
      city: json['City'],
      imageUrl: json['ImageUrl'] != null
          ? Uri.parse(baseUrl).resolve(json['ImageUrl']).toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'FullAddress': fullAddress,
      'Coordinates': coordinates,
      'FacilityList': facilities,
      'AvailableScreensList': availableScreens,
      'ContactNumber': contactNumber,
      'City': city,
      'ImageUrl': imageUrl,
    };
  }
}
