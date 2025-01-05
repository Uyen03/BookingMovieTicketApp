class ApiConfig {
  static String get baseUrl {
    // Base URL (Ngrok hoặc server của bạn)
    return "http://b68e-2405-4803-d75f-df20-c50e-ced9-b97d-95f5.ngrok-free.app/api";
  }

  // Endpoint cho các tài nguyên
  static String get showtimesEndpoint => "$baseUrl/showtimes";
  static String get seatEndpoint => "$baseUrl/seat";
  static String get bookingEndpoint => "$baseUrl/Booking";
  static String get snackPackagesEndpoint => "$baseUrl/snackpackages";
  static String get userSyncEndpoint => "$baseUrl/UserSync/sync";
  static String get zaloPayEndpoint => "$baseUrl/ZaloPay/create-payment";
}
